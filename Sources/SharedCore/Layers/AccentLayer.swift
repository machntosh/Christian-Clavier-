import Foundation

/// Couche 1 — accents manquants : `ecole` -> `école`, `etre` -> `être`,
/// `eleve` -> `élève`. Piloté par les données : on replie le mot saisi (sans
/// accents) et on cherche les formes accentuées correspondantes au lexique.
///
/// Avantage : aucune table d'accents à maintenir à la main — toute forme
/// accentuée présente au lexique devient automatiquement une cible.
public struct AccentLayer: CorrectionLayer {
    public let id = "accent"

    public init() {}

    public func suggest(_ ctx: WordContext, _ deps: LayerContext) -> [Suggestion] {
        let word = ctx.word
        let lower = word.lowercased()
        // Si le mot est déjà valide tel quel, rien à faire.
        guard !deps.lexicon.contains(lower) else { return [] }

        let folded = TextNormalizer.fold(lower)
        // Si le mot saisi a déjà des accents et n'est pas valide, le repli peut
        // quand même retrouver la bonne forme (ex. faute d'accent inversée).
        let variants = deps.lexicon.accentVariants(ofFolded: folded)
            .filter { $0 != lower }
        guard !variants.isEmpty else { return [] }

        return variants
            .sorted { deps.lexicon.freq($0) > deps.lexicon.freq($1) }
            .prefix(2)
            .map { variant in
                Suggestion(text: TextNormalizer.applyCasing(of: word, to: variant),
                           kind: .accent, confidence: 0.9, layerID: id)
            }
    }
}
