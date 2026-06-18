import Foundation

// MARK: - Résultats de correction

/// Nature d'une suggestion produite par une couche du moteur.
public enum SuggestionKind: String, Equatable, Sendable {
    case apostrophe      // élision manquante: lami -> l'ami
    case accent          // accent manquant: ecole -> école
    case spelling        // faute par distance d'édition: bote -> botte
    case usage           // faute d'usage (informationnelle): "malgré que"
    case homophone       // homophone contextuel: il et -> il est
    case contraction     // expansion d'une contraction (profil standard)
}

/// Une suggestion ordonnable. `confidence` ∈ [0,1].
public struct Suggestion: Equatable, Sendable {
    public let text: String
    public let kind: SuggestionKind
    public let confidence: Double
    public let layerID: String

    public init(text: String, kind: SuggestionKind, confidence: Double, layerID: String) {
        self.text = text
        self.kind = kind
        self.confidence = confidence
        self.layerID = layerID
    }
}

/// Résultat complet pour un mot, garanti non bloquant.
/// Si aucune couche n'a rien à dire, `suggestions` est vide — jamais une erreur.
public struct CorrectionResult: Equatable, Sendable {
    public let original: String
    public let suggestions: [Suggestion]
    public let protectedByUser: Bool      // mot dans la whitelist utilisateur
    public let protectedByProfile: Bool   // mot dans le lexique du registre actif

    public init(original: String,
                suggestions: [Suggestion],
                protectedByUser: Bool,
                protectedByProfile: Bool) {
        self.original = original
        self.suggestions = suggestions
        self.protectedByUser = protectedByUser
        self.protectedByProfile = protectedByProfile
    }

    public static func none(_ original: String) -> CorrectionResult {
        CorrectionResult(original: original, suggestions: [],
                         protectedByUser: false, protectedByProfile: false)
    }
}

// MARK: - Contexte d'entrée

/// Contexte minimal fourni par l'extension. `leftWords` peut être vide
/// (le proxy iOS ne garantit pas le contexte). Le moteur doit dégrader
/// proprement dans ce cas.
public struct WordContext: Equatable, Sendable {
    public let word: String
    public let leftWords: [String]

    public init(word: String, leftWords: [String] = []) {
        self.word = word
        self.leftWords = leftWords
    }

    /// Découpe un fragment de texte (ex. documentContextBeforeInput) en
    /// contexte exploitable : dernier token = mot courant, le reste à gauche.
    public static func from(textBeforeCursor text: String) -> WordContext? {
        let tokens = text
            .components(separatedBy: CharacterSet(charactersIn: " \n\t"))
            .filter { !$0.isEmpty }
        guard let last = tokens.last else { return nil }
        return WordContext(word: last, leftWords: Array(tokens.dropLast()))
    }
}
