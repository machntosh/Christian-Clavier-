import Foundation

/// Couche 1 — fautes usuelles par table (orthographe figée et tournures).
/// Deux types :
///  - corrections orthographiques sûres (`aujourdhui` -> `aujourd'hui`),
///  - signalements d'usage informatifs (`malgré que` -> `bien que`), à plus
///    faible confiance car ce sont des choix de style, jamais imposés.
public struct CommonMistakeLayer: CorrectionLayer {
    public let id = "common_mistake"

    private let spellingFixes: [String: String]
    private let usageHints: [String: String]

    public init(spellingFixes: [String: String] = SeedData.spellingFixes,
                usageHints: [String: String] = SeedData.usageHints) {
        // Normalise les clés en minuscules.
        self.spellingFixes = Dictionary(uniqueKeysWithValues:
            spellingFixes.map { ($0.key.lowercased(), $0.value) })
        self.usageHints = Dictionary(uniqueKeysWithValues:
            usageHints.map { ($0.key.lowercased(), $0.value) })
    }

    public func suggest(_ ctx: WordContext, _ deps: LayerContext) -> [Suggestion] {
        let lower = ctx.word.lowercased()
        var out: [Suggestion] = []

        if let fix = spellingFixes[lower] {
            out.append(Suggestion(text: TextNormalizer.applyCasing(of: ctx.word, to: fix),
                                  kind: .spelling, confidence: 0.95, layerID: id))
        }
        // Usage : on regarde aussi le bigramme (mot précédent + mot courant)
        // pour des tournures comme "malgré que".
        if let prev = ctx.leftWords.last {
            let bigram = "\(prev.lowercased()) \(lower)"
            if let hint = usageHints[bigram] {
                out.append(Suggestion(text: hint, kind: .usage,
                                      confidence: 0.5, layerID: id))
            }
        }
        if let hint = usageHints[lower] {
            out.append(Suggestion(text: hint, kind: .usage,
                                  confidence: 0.5, layerID: id))
        }
        return out
    }
}
