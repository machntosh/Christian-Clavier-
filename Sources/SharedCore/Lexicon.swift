import Foundation

/// Outils de normalisation partagés par les couches.
public enum TextNormalizer {

    /// Retire les diacritiques (é -> e). Utilisé pour indexer les variantes
    /// accentuées et pour comparer de façon tolérante aux accents.
    public static func fold(_ s: String) -> String {
        s.folding(options: .diacriticInsensitive, locale: Locale(identifier: "fr_FR"))
         .lowercased()
    }

    public static func lower(_ s: String) -> String { s.lowercased() }

    /// Reporte la casse du mot source sur une suggestion
    /// (Bonjour -> Bonjour, BONJOUR -> ÉCOLE, ecole -> école).
    public static func applyCasing(of source: String, to candidate: String) -> String {
        guard let first = source.first else { return candidate }
        if source.count > 1, source == source.uppercased(),
           source.rangeOfCharacter(from: .letters) != nil {
            return candidate.uppercased()
        }
        if first.isUppercase {
            return candidate.prefix(1).uppercased() + String(candidate.dropFirst())
        }
        return candidate
    }
}

/// Vérification d'appartenance lexicale + variantes accentuées.
///
/// Implémentation MVP : en mémoire à partir de listes de départ (voir
/// SeedData). Le format binaire compact / mmap est une optimisation ultérieure
/// pilotée par POC-DICT / POC-MEM (voir docs/issues.md) — l'API reste la même.
public final class Lexicon: @unchecked Sendable {

    private let words: Set<String>                 // formes correctes (minuscules)
    private let foldedIndex: [String: [String]]    // sansAccents -> [formes accentuées]
    private let frequency: [String: Int]           // pour classer les suggestions

    public init(words: [String], frequency: [String: Int] = [:]) {
        var set = Set<String>()
        var index: [String: [String]] = [:]
        for raw in words {
            let w = raw.lowercased()
            set.insert(w)
            let folded = TextNormalizer.fold(w)
            if folded != w {
                index[folded, default: []].append(w)
            }
        }
        self.words = set
        self.foldedIndex = index
        self.frequency = frequency
    }

    public func contains(_ word: String) -> Bool {
        words.contains(word.lowercased())
    }

    /// Formes accentuées correspondant à un mot sans accents (école pour ecole).
    public func accentVariants(ofFolded folded: String) -> [String] {
        foldedIndex[folded] ?? []
    }

    public func freq(_ word: String) -> Int { frequency[word.lowercased()] ?? 0 }

    /// Candidats partageant une longueur proche (filtre rapide pour la
    /// distance d'édition). Évite de scanner tout le lexique.
    public func candidates(nearLength len: Int, delta: Int = 2) -> [String] {
        words.filter { abs($0.count - len) <= delta }
    }

    public var count: Int { words.count }
}
