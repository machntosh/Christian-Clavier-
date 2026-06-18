import Foundation

/// Couche 1 — élisions manquantes : `lami` -> `l'ami`, `jai` -> `j'ai`,
/// `cest` -> `c'est`, `dun` -> `d'un`, `quil` -> `qu'il`.
///
/// Principe : si le mot n'est pas dans le lexique, on teste les préfixes
/// élidables ; on ne propose la forme apostrophée que si le reste est lui-même
/// un mot valide. Le garde "mot déjà valide" évite les faux positifs
/// (`dans`, `ces`, `mes`… restent intacts car présents au lexique).
public struct ApostropheLayer: CorrectionLayer {
    public let id = "apostrophe"

    // Préfixes élidables, "qu" testé avant "q"/"c" (plus spécifique d'abord).
    private let prefixes = ["qu", "c", "d", "j", "l", "m", "n", "s", "t"]

    public init() {}

    public func suggest(_ ctx: WordContext, _ deps: LayerContext) -> [Suggestion] {
        let word = ctx.word
        let lower = word.lowercased()
        guard lower.count >= 3 else { return [] }
        // Ne touche pas un mot déjà valide ni déjà apostrophé.
        guard !deps.lexicon.contains(lower), !lower.contains("'") else { return [] }

        for p in prefixes where lower.hasPrefix(p) {
            let rest = String(lower.dropFirst(p.count))
            guard let firstRest = rest.first else { continue }
            let startsVowelOrH = "aeiouyhàâäéèêëîïôöùûü".contains(firstRest)
            guard rest.count >= 2, startsVowelOrH else { continue }
            // Reste doit être un mot valide pour valider l'élision.
            guard deps.lexicon.contains(rest) else { continue }

            let candidate = "\(p)'\(rest)"
            let cased = TextNormalizer.applyCasing(of: word, to: candidate)
            return [Suggestion(text: cased, kind: .apostrophe,
                               confidence: 0.92, layerID: id)]
        }
        return []
    }
}
