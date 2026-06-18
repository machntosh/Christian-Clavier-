import SwiftUI
import SharedCore

/// App principale : onboarding + réglages écrits dans l'App Group (lus par
/// l'extension). Aucune logique de correction ici (D1) — uniquement de la
/// configuration partagée.
struct RootView: View {
    @State private var registre: Registre = .familierQC
    @State private var intensity: CorrectionIntensity = .suggest
    @State private var whitelistText: String = ""

    private let store = AppGroupStore()

    var body: some View {
        NavigationView {
            Form {
                Section("Activation") {
                    Text("Réglages → Général → Clavier → Claviers → Ajouter, puis activez « Allow Full Access » pour synchroniser vos préférences.")
                        .font(.footnote)
                    if store.isShortedToFallback {
                        Label("App Group inaccessible — réglages par défaut utilisés.",
                              systemImage: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                            .font(.footnote)
                    }
                }

                Section("Registre") {
                    Picker("Profil", selection: $registre) {
                        Text("Familier QC").tag(Registre.familierQC)
                        Text("Familier FR").tag(Registre.familierFR)
                        Text("Standard").tag(Registre.standard)
                    }
                }

                Section("Intensité") {
                    Picker("Correction", selection: $intensity) {
                        Text("Désactivée").tag(CorrectionIntensity.off)
                        Text("Suggérer").tag(CorrectionIntensity.suggest)
                        Text("Agressive").tag(CorrectionIntensity.aggressive)
                    }
                }

                Section("Mots protégés (un par ligne)") {
                    TextEditor(text: $whitelistText).frame(minHeight: 100)
                }

                Button("Enregistrer") { save() }
            }
            .navigationTitle("Clavier FR")
            .onAppear(perform: load)
        }
    }

    private func load() {
        registre = store.loadRegistre()
        intensity = store.loadIntensity()
        whitelistText = store.loadUserLists().whitelist.sorted().joined(separator: "\n")
    }

    private func save() {
        store.save(registre: registre)
        store.save(intensity: intensity)
        let words = whitelistText
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        store.saveWhitelist(words)
    }
}
