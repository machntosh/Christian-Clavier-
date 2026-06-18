import Foundation

/// Couche 3 — homophones contextuels (best-effort, désactivable).
///
/// Limite assumée : sans analyse grammaticale ni contexte droit fiable (V3),
/// on n'implémente que des règles à HAUTE précision déclenchées par le mot
/// précédent. Si le contexte gauche est vide, la couche ne propose rien — c'est
/// la dégradation gracieuse attendue. Confiance volontairement modérée.
///
/// Règles couvertes (précises) :
///  - pronom sujet (il/elle/on/qui/ça/c') + "et"  -> "est"
///  - pronom sujet (il/elle/on/qui)        + "à"   -> "a"
///  - pronom sujet (ils/elles)             + "ont" conservé ; "on" -> "ont" si sujet pluriel implicite (non couvert, trop ambigu)
public struct HomophoneLayer: CorrectionLayer {
    public let id = "homophone"

    private let subjectPronouns: Set<String> = ["il", "elle", "on", "qui", "ça", "c'", "ç'"]

    public init() {}

    public func suggest(_ ctx: WordContext, _ deps: LayerContext) -> [Suggestion] {
        guard let prevRaw = ctx.leftWords.last else { return [] } // contexte requis
        let prev = prevRaw.lowercased()
        let w = ctx.word.lowercased()

        // "il et" -> "il est"
        if w == "et", subjectPronouns.contains(prev) {
            return [Suggestion(text: TextNormalizer.applyCasing(of: ctx.word, to: "est"),
                               kind: .homophone, confidence: 0.7, layerID: id)]
        }
        // "il à" -> "il a"
        if w == "à", subjectPronouns.contains(prev) {
            return [Suggestion(text: TextNormalizer.applyCasing(of: ctx.word, to: "a"),
                               kind: .homophone, confidence: 0.7, layerID: id)]
        }
        return []
    }
}
