import Foundation

/// Données de départ embarquées (MVP). Volontairement modestes et lisibles :
/// elles servent à faire tourner et tester le moteur sans dépendre d'un gros
/// dictionnaire. Le dico complet (format binaire/mmap) est une évolution
/// pilotée par POC-DICT/POC-MEM — l'API `Lexicon` ne change pas. Voir
/// docs/architecture.md §4.
public enum SeedData {

    /// Mots corrects fréquents, incluant des formes accentuées (indexées
    /// automatiquement par leur version sans accents) et des cibles d'élision.
    public static let lexiconWords: [String] = [
        // formes courtes / cibles d'élision et homophones
        "ami", "amie", "amis", "un", "une", "il", "elle", "on", "est", "ai",
        "as", "a", "en", "y", "eau", "ici", "homme", "heure", "idée", "objet",
        "école", "élève", "élèves", "être", "étudiant", "étudiante", "étude",
        "écrire", "éviter", "écouter", "élément", "énergie", "égal", "épée",
        // mots fréquents standard
        "le", "la", "les", "des", "du", "de", "et", "ou", "où", "à", "ce",
        "se", "ces", "ses", "mais", "donc", "car", "ne", "pas", "plus",
        "très", "bien", "mal", "tout", "tous", "rien", "avec", "sans", "pour",
        "dans", "sur", "sous", "chez", "vers", "par", "entre", "aujourd'hui",
        "demain", "hier", "maintenant", "toujours", "jamais", "parfois",
        "bonjour", "merci", "oui", "non", "peut-être", "voilà", "déjà",
        "français", "française", "québécois", "québécoise", "café", "thé",
        "fenêtre", "porte", "maison", "voiture", "travail", "famille",
        "mère", "père", "frère", "sœur", "enfant", "ville", "pays", "monde",
        "problème", "système", "modèle", "près", "après", "près", "forêt",
        "bête", "tête", "fête", "rêve", "même", "août", "hôtel", "hôpital",
        "garçon", "leçon", "façon", "ça", "là", "voilà", "manger", "boire",
        "parler", "penser", "aller", "venir", "faire", "dire", "voir",
        "savoir", "pouvoir", "vouloir", "vais", "vas", "va", "content",
        "contente", "heureux", "fatigué", "fatiguée", "botte", "côté",
        "pâte", "tâche", "âge", "mûr", "sûr", "dû"
    ]

    /// Fréquences (pour classer les suggestions). Plus le nombre est grand,
    /// plus le mot est privilégié à distance d'édition égale.
    public static let frequency: [String: Int] = [
        "le": 1000, "la": 990, "les": 980, "de": 970, "et": 960, "est": 950,
        "un": 940, "une": 930, "à": 920, "il": 910, "elle": 900, "que": 890,
        "école": 500, "être": 600, "ami": 400, "très": 550, "bien": 560,
        "aujourd'hui": 300, "français": 250, "québécois": 120, "content": 200
    ]

    /// Corrections orthographiques sûres (faute -> forme correcte).
    public static let spellingFixes: [String: String] = [
        "aujourdhui": "aujourd'hui",
        "aujourd'huit": "aujourd'hui",
        "parmis": "parmi",
        "malgrés": "malgré",
        "quelque chose": "quelque chose",
        "biensur": "bien sûr",
        "bientot": "bientôt",
        "peutetre": "peut-être",
        "quelquefois": "quelquefois",
        "entout cas": "en tout cas",
        "voilas": "voilà",
        "developper": "développer",
        "language": "langage",
        "connection": "connexion",
        "apres": "après",
        "tres": "très",
        "etre": "être",
        "meme": "même"
    ]

    /// Signalements d'usage informatifs (tournure -> recommandation).
    /// Confiance basse côté moteur : jamais imposés.
    public static let usageHints: [String: String] = [
        "malgré que": "bien que",
        "au jour d'aujourd'hui": "aujourd'hui",
        "pallier à": "pallier",
        "se rappeler de": "se rappeler"
    ]

    // MARK: - Profils

    public static func profile(for registre: Registre,
                               intensity: CorrectionIntensity = .suggest) -> Profile {
        switch registre {
        case .familierQC:
            return Profile(
                registre: .familierQC,
                protectedLexicon: [
                    "chu", "tsé", "pis", "ben", "faque", "pantoute", "icitte",
                    "frette", "niaiser", "magasiner", "char", "blonde", "chum",
                    "dépanneur", "poutine", "tabarouette", "pogner", "jaser",
                    "céduler", "écœurant", "correct", "ouain", "asteure"
                ],
                contractions: ["chu": "je suis", "ptet": "peut-être", "ouain": "oui"],
                intensity: intensity
            )
        case .familierFR:
            return Profile(
                registre: .familierFR,
                protectedLexicon: [
                    "ouais", "ptet", "chais", "grave", "relou", "chelou", "wesh",
                    "bouffer", "kiffer", "mec", "meuf", "truc", "bagnole", "ouf",
                    "chelou", "zarbi", "vénère", "chanmé", "frérot"
                ],
                contractions: ["chais": "je sais", "ptet": "peut-être", "ouais": "oui"],
                intensity: intensity
            )
        case .standard:
            return Profile(
                registre: .standard,
                protectedLexicon: [],
                contractions: [
                    "chu": "je suis", "ptet": "peut-être", "ouais": "oui",
                    "chais": "je sais", "faut": "il faut"
                ],
                intensity: intensity
            )
        }
    }

    /// Lexique standard prêt à l'emploi.
    public static func makeLexicon() -> Lexicon {
        Lexicon(words: lexiconWords, frequency: frequency)
    }
}
