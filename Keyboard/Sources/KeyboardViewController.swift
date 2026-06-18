import UIKit
import SharedCore

/// Keyboard Extension. Architecture en deux plans (D3) :
///  - Plan 0 (frappe brute) : insertText/deleteBackward — ne dépend d'AUCUNE
///    couche de correction. Si tout le reste échoue, on tape quand même.
///  - Plan correction : barre de suggestions alimentée par CorrectionEngine,
///    enveloppé pour ne jamais propager d'erreur au plan 0.
final class KeyboardViewController: UIInputViewController {

    private var suggestionBar: SuggestionBarView!
    private var engine: CorrectionEngine?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureEngineSafely()
        buildUI()
    }

    // MARK: - Moteur (chargé défensivement)

    private func configureEngineSafely() {
        // Lecture des réglages via App Group, repli embarqué sinon (D4).
        let store: SettingsStore = AppGroupStore()
        let lexicon = SeedData.makeLexicon()
        let profile = SeedData.profile(for: store.loadRegistre(),
                                       intensity: store.loadIntensity())
        engine = CorrectionEngine(lexicon: lexicon,
                                  profile: profile,
                                  userLists: store.loadUserLists())
    }

    // MARK: - UI

    private func buildUI() {
        suggestionBar = SuggestionBarView()
        suggestionBar.onSelect = { [weak self] suggestion in
            self?.apply(suggestion)
        }
        suggestionBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(suggestionBar)

        let keyboard = SimpleKeyboardView()
        keyboard.onKey = { [weak self] key in self?.handle(key) }
        keyboard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyboard)

        NSLayoutConstraint.activate([
            suggestionBar.topAnchor.constraint(equalTo: view.topAnchor),
            suggestionBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            suggestionBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            suggestionBar.heightAnchor.constraint(equalToConstant: 44),

            keyboard.topAnchor.constraint(equalTo: suggestionBar.bottomAnchor),
            keyboard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboard.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Frappe (Plan 0 — toujours sûr)

    private func handle(_ key: KeyEvent) {
        switch key {
        case .char(let c): textDocumentProxy.insertText(c)
        case .space:       textDocumentProxy.insertText(" ")
        case .backspace:   textDocumentProxy.deleteBackward()
        case .returnKey:   textDocumentProxy.insertText("\n")
        }
        refreshSuggestions()
    }

    // MARK: - Plan correction (enveloppé, jamais bloquant)

    private func refreshSuggestions() {
        guard let engine else { suggestionBar.show([]); return }
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        guard let ctx = WordContext.from(textBeforeCursor: before) else {
            suggestionBar.show([]); return
        }
        let result = engine.process(ctx)
        suggestionBar.show(result.suggestions)
    }

    private func apply(_ suggestion: Suggestion) {
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        guard let ctx = WordContext.from(textBeforeCursor: before) else { return }
        // Remplace le mot courant : on efface puis on réinsère.
        for _ in 0..<ctx.word.count { textDocumentProxy.deleteBackward() }
        textDocumentProxy.insertText(suggestion.text)
        suggestionBar.show([])
    }
}
