import Foundation

/// Couche 1 (registre) — gère les contractions familières selon le profil.
///
/// - En registre `standard` : propose l'EXPANSION d'une contraction connue
///   (`chu` -> `je suis`) à titre de suggestion.
/// - En registre familier (QC/FR) : ne propose RIEN — la contraction fait
///   partie du registre voulu et est protégée par ailleurs (CorrectionEngine
///   consulte `profile.isProtected`).
///
/// C'est le pivot de l'exigence « préserver le registre familier ».
public struct ContractionLayer: CorrectionLayer {
    public let id = "contraction"

    public init() {}

    public func suggest(_ ctx: WordContext, _ deps: LayerContext) -> [Suggestion] {
        guard deps.profile.registre == .standard else { return [] }
        let lower = ctx.word.lowercased()
        guard let expansion = deps.profile.contractions[lower] else { return [] }
        return [Suggestion(text: TextNormalizer.applyCasing(of: ctx.word, to: expansion),
                           kind: .contraction, confidence: 0.6, layerID: id)]
    }
}
