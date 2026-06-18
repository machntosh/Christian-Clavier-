import Foundation

/// Dépendances injectées dans chaque couche.
public struct LayerContext {
    public let profile: Profile
    public let lexicon: Lexicon
    public let userLists: UserLists

    public init(profile: Profile, lexicon: Lexicon, userLists: UserLists) {
        self.profile = profile
        self.lexicon = lexicon
        self.userLists = userLists
    }
}

/// Une couche de correction. Contrat strict :
/// - PURE et SANS effet de bord,
/// - ne lève JAMAIS d'exception vers l'appelant,
/// - retourne `[]` si elle n'a rien à proposer ou si une garde interne échoue.
///
/// C'est ce contrat qui rend la dégradation gracieuse possible (D3) : le moteur
/// peut désactiver ou ignorer n'importe quelle couche sans casser les autres.
public protocol CorrectionLayer {
    var id: String { get }
    func suggest(_ ctx: WordContext, _ deps: LayerContext) -> [Suggestion]
}
