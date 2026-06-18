import Foundation

/// Couche 2 — suggestions par distance d'édition (Damerau-Levenshtein bornée
/// à 2 : insertion, suppression, substitution, transposition). Filtre rapide
/// par longueur pour ne pas scanner tout le lexique.
///
/// N'intervient qu'en dernier recours : si les couches 1 (apostrophe/accent/
/// faute usuelle) ont déjà répondu, le moteur ne sollicite pas forcément
/// celle-ci. Reste robuste sur petit lexique ; l'index optimisé est une
/// évolution (POC-DICT).
public struct EditDistanceLayer: CorrectionLayer {
    public let id = "edit_distance"

    private let maxDistance: Int
    private let maxResults: Int

    public init(maxDistance: Int = 2, maxResults: Int = 3) {
        self.maxDistance = maxDistance
        self.maxResults = maxResults
    }

    public func suggest(_ ctx: WordContext, _ deps: LayerContext) -> [Suggestion] {
        let lower = ctx.word.lowercased()
        guard lower.count >= 3, !deps.lexicon.contains(lower) else { return [] }

        let target = Array(lower)
        var scored: [(word: String, dist: Int)] = []

        for cand in deps.lexicon.candidates(nearLength: lower.count, delta: maxDistance) {
            let d = Self.damerauLevenshtein(target, Array(cand), max: maxDistance)
            if d <= maxDistance { scored.append((cand, d)) }
        }

        return scored
            .sorted {
                if $0.dist != $1.dist { return $0.dist < $1.dist }
                return deps.lexicon.freq($0.word) > deps.lexicon.freq($1.word)
            }
            .prefix(maxResults)
            .map { item in
                // Plus la distance est grande, plus la confiance baisse.
                let conf = max(0.4, 0.8 - 0.2 * Double(item.dist - 1))
                return Suggestion(text: TextNormalizer.applyCasing(of: ctx.word, to: item.word),
                                  kind: .spelling, confidence: conf, layerID: id)
            }
    }

    /// Distance de Damerau-Levenshtein avec borne (early-exit si min de ligne > max).
    static func damerauLevenshtein(_ a: [Character], _ b: [Character], max: Int) -> Int {
        let n = a.count, m = b.count
        if abs(n - m) > max { return max + 1 }
        if n == 0 { return m }
        if m == 0 { return n }

        var prevPrev = [Int](repeating: 0, count: m + 1)
        var prev = Array(0...m)
        var curr = [Int](repeating: 0, count: m + 1)

        for i in 1...n {
            curr[0] = i
            var rowMin = curr[0]
            for j in 1...m {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                var best = Swift.min(
                    prev[j] + 1,        // suppression
                    curr[j - 1] + 1,    // insertion
                    prev[j - 1] + cost  // substitution
                )
                if i > 1, j > 1, a[i - 1] == b[j - 2], a[i - 2] == b[j - 1] {
                    best = Swift.min(best, prevPrev[j - 2] + 1) // transposition
                }
                curr[j] = best
                rowMin = Swift.min(rowMin, best)
            }
            if rowMin > max { return max + 1 } // borne : inutile de continuer
            prevPrev = prev
            prev = curr
            curr = [Int](repeating: 0, count: m + 1)
        }
        return prev[m]
    }
}
