import SwiftUI
import SwiftData

/// Pre-loaded vocabulary content for Langly.
/// Multiple themed blocks with common Portuguese words.
struct VocabularyContent {

    struct WordPair {
        let native: String
        let translated: String
        let phonetic: String
    }

    struct BlockContent {
        let name: String
        let words: [WordPair]
    }

    /// All starter blocks available on first launch.
    static let starterBlocks: [BlockContent] = [
        // MARK: - Essentials
        BlockContent(name: "Essentials", words: [
            WordPair(native: "yes", translated: "sim", phonetic: "séeng"),
            WordPair(native: "no", translated: "não", phonetic: "náung"),
            WordPair(native: "please", translated: "por favor", phonetic: "poor fah-VÓR"),
            WordPair(native: "thank you", translated: "obrigado", phonetic: "oh-bree-GAH-doo"),
            WordPair(native: "sorry", translated: "desculpe", phonetic: "desh-COOL-peh"),
            WordPair(native: "hello", translated: "olá", phonetic: "oh-LAH"),
            WordPair(native: "goodbye", translated: "adeus", phonetic: "ah-DAY-oosh"),
            WordPair(native: "good morning", translated: "bom dia", phonetic: "bohm JEE-ah"),
            WordPair(native: "good night", translated: "boa noite", phonetic: "BOH-ah NOY-chee"),
            WordPair(native: "excuse me", translated: "com licença", phonetic: "kohm lee-SEN-sah"),
            WordPair(native: "help", translated: "ajuda", phonetic: "ah-ZHOO-dah"),
            WordPair(native: "great", translated: "ótimo", phonetic: "ÓH-chee-moo"),
            WordPair(native: "always", translated: "sempre", phonetic: "SEM-preh"),
            WordPair(native: "sometimes", translated: "às vezes", phonetic: "ahs VAY-zahs"),
            WordPair(native: "never", translated: "nunca", phonetic: "NOON-kah"),
        ]),

        // MARK: - Questions
        BlockContent(name: "Questions", words: [
            WordPair(native: "who", translated: "quem", phonetic: "kayng"),
            WordPair(native: "what", translated: "o que", phonetic: "oo kay"),
            WordPair(native: "where", translated: "onde", phonetic: "ON-jee"),
            WordPair(native: "when", translated: "quando", phonetic: "KWAN-doo"),
            WordPair(native: "why", translated: "por quê", phonetic: "poor keh"),
            WordPair(native: "how", translated: "como", phonetic: "KOH-moo"),
            WordPair(native: "how much", translated: "quanto", phonetic: "KWAN-too"),
            WordPair(native: "how many", translated: "quantos", phonetic: "KWAN-toosh"),
            WordPair(native: "which", translated: "qual", phonetic: "kwahl"),
            WordPair(native: "can I", translated: "posso", phonetic: "POH-soo"),
            WordPair(native: "do you have", translated: "você tem", phonetic: "voh-SEH tayng"),
            WordPair(native: "is it", translated: "é", phonetic: "eh"),
            WordPair(native: "where is", translated: "onde está", phonetic: "ON-jee eh-STAH"),
            WordPair(native: "what time", translated: "que horas", phonetic: "kay OH-rahs"),
            WordPair(native: "why", translated: "por que", phonetic: "poor kay"),
        ]),

        // MARK: - People & Family
        BlockContent(name: "People & Family", words: [
            WordPair(native: "he", translated: "ele", phonetic: "EH-lee"),
            WordPair(native: "she", translated: "ela", phonetic: "EH-lah"),
            WordPair(native: "I", translated: "eu", phonetic: "AY-oo"),
            WordPair(native: "you", translated: "você", phonetic: "voh-SEH"),
            WordPair(native: "we", translated: "nós", phonetic: "nohs"),
            WordPair(native: "they", translated: "eles", phonetic: "EH-leesh"),
            WordPair(native: "friend", translated: "amigo", phonetic: "ah-MEE-goo"),
            WordPair(native: "family", translated: "família", phonetic: "fah-MEE-lee-ah"),
            WordPair(native: "mother", translated: "mãe", phonetic: "myng"),
            WordPair(native: "father", translated: "pai", phonetic: "pah-ee"),
            WordPair(native: "brother", translated: "irmão", phonetic: "eer-MOWNG"),
            WordPair(native: "sister", translated: "irmã", phonetic: "eer-MANG"),
            WordPair(native: "child", translated: "criança", phonetic: "kree-AN-sah"),
            WordPair(native: "baby", translated: "bebê", phonetic: "beh-BEH"),
            WordPair(native: "person", translated: "pessoa", phonetic: "peh-SOH-ah"),
        ]),

        // MARK: - Numbers
        BlockContent(name: "Numbers", words: [
            WordPair(native: "one", translated: "um", phonetic: "oong"),
            WordPair(native: "two", translated: "dois", phonetic: "doysh"),
            WordPair(native: "three", translated: "três", phonetic: "trehsh"),
            WordPair(native: "four", translated: "quatro", phonetic: "KWAH-troo"),
            WordPair(native: "five", translated: "cinco", phonetic: "SEEN-koo"),
            WordPair(native: "six", translated: "seis", phonetic: "saysh"),
            WordPair(native: "seven", translated: "sete", phonetic: "SEH-chee"),
            WordPair(native: "eight", translated: "oito", phonetic: "OY-too"),
            WordPair(native: "nine", translated: "nove", phonetic: "NOH-vee"),
            WordPair(native: "ten", translated: "dez", phonetic: "desh"),
            WordPair(native: "twenty", translated: "vinte", phonetic: "VEEN-chee"),
            WordPair(native: "thirty", translated: "trinta", phonetic: "TREEN-tah"),
            WordPair(native: "fifty", translated: "cinquenta", phonetic: "seen-KWEN-tah"),
            WordPair(native: "hundred", translated: "cem", phonetic: "sayng"),
            WordPair(native: "thousand", translated: "mil", phonetic: "meeo"),
        ]),

        // MARK: - Time & Days
        BlockContent(name: "Time & Days", words: [
            WordPair(native: "today", translated: "hoje", phonetic: "OH-zhee"),
            WordPair(native: "tomorrow", translated: "amanhã", phonetic: "ah-mah-NYANG"),
            WordPair(native: "yesterday", translated: "ontem", phonetic: "ON-tayng"),
            WordPair(native: "now", translated: "agora", phonetic: "ah-GOH-rah"),
            WordPair(native: "later", translated: "mais tarde", phonetic: "mish TAR-jee"),
            WordPair(native: "morning", translated: "manhã", phonetic: "mah-NYANG"),
            WordPair(native: "afternoon", translated: "tarde", phonetic: "TAR-jee"),
            WordPair(native: "night", translated: "noite", phonetic: "NOY-chee"),
            WordPair(native: "Monday", translated: "segunda-feira", phonetic: "seh-GOON-dah FAY-rah"),
            WordPair(native: "Tuesday", translated: "terça-feira", phonetic: "TAYR-sah FAY-rah"),
            WordPair(native: "Wednesday", translated: "quarta-feira", phonetic: "KWAR-tah FAY-rah"),
            WordPair(native: "Thursday", translated: "quinta-feira", phonetic: "KEEN-tah FAY-rah"),
            WordPair(native: "Friday", translated: "sexta-feira", phonetic: "SEX-tah FAY-rah"),
            WordPair(native: "Saturday", translated: "sábado", phonetic: "SAH-bah-doo"),
            WordPair(native: "Sunday", translated: "domingo", phonetic: "doh-MEEN-goo"),
        ]),

        // MARK: - Food & Drinks
        BlockContent(name: "Food & Drinks", words: [
            WordPair(native: "water", translated: "água", phonetic: "AH-gwah"),
            WordPair(native: "coffee", translated: "café", phonetic: "kah-FEH"),
            WordPair(native: "bread", translated: "pão", phonetic: "powng"),
            WordPair(native: "rice", translated: "arroz", phonetic: "ah-HOSH"),
            WordPair(native: "meat", translated: "carne", phonetic: "KAR-nee"),
            WordPair(native: "chicken", translated: "frango", phonetic: "FRANG-goo"),
            WordPair(native: "fish", translated: "peixe", phonetic: "PAY-shee"),
            WordPair(native: "egg", translated: "ovo", phonetic: "OH-voo"),
            WordPair(native: "milk", translated: "leite", phonetic: "LAY-chee"),
            WordPair(native: "fruit", translated: "fruta", phonetic: "FROO-tah"),
            WordPair(native: "apple", translated: "maçã", phonetic: "mah-SANG"),
            WordPair(native: "banana", translated: "banana", phonetic: "bah-NAH-nah"),
            WordPair(native: "orange", translated: "laranja", phonetic: "lah-RAN-zhah"),
            WordPair(native: "beer", translated: "cerveja", phonetic: "ser-VAY-zhah"),
            WordPair(native: "wine", translated: "vinho", phonetic: "VEE-nyoo"),
        ]),

        // MARK: - Travel & Directions
        BlockContent(name: "Travel & Directions", words: [
            WordPair(native: "airport", translated: "aeroporto", phonetic: "ah-eh-roh-POR-too"),
            WordPair(native: "hotel", translated: "hotel", phonetic: "oh-TEL"),
            WordPair(native: "restaurant", translated: "restaurante", phonetic: "hes-tow-RAN-chee"),
            WordPair(native: "beach", translated: "praia", phonetic: "PRI-ah"),
            WordPair(native: "street", translated: "rua", phonetic: "HOO-ah"),
            WordPair(native: "left", translated: "esquerda", phonetic: "esh-KER-dah"),
            WordPair(native: "right", translated: "direita", phonetic: "jee-RAY-tah"),
            WordPair(native: "straight", translated: "em frente", phonetic: "ayng FREN-chee"),
            WordPair(native: "here", translated: "aqui", phonetic: "ah-KEE"),
            WordPair(native: "there", translated: "lá", phonetic: "lah"),
            WordPair(native: "far", translated: "longe", phonetic: "LON-zhee"),
            WordPair(native: "near", translated: "perto", phonetic: "PER-too"),
            WordPair(native: "map", translated: "mapa", phonetic: "MAH-pah"),
            WordPair(native: "taxi", translated: "táxi", phonetic: "TAH-shee"),
            WordPair(native: "bus", translated: "ônibus", phonetic: "OH-nee-boosh"),
        ]),

        // MARK: - Shopping
        BlockContent(name: "Shopping", words: [
            WordPair(native: "how much", translated: "quanto custa", phonetic: "KWAN-too KOOSH-tah"),
            WordPair(native: "expensive", translated: "caro", phonetic: "KAH-roo"),
            WordPair(native: "cheap", translated: "barato", phonetic: "bah-RAH-too"),
            WordPair(native: "sale", translated: "promoção", phonetic: "proh-moh-SOWNG"),
            WordPair(native: "money", translated: "dinheiro", phonetic: "jee-NYAY-roo"),
            WordPair(native: "card", translated: "cartão", phonetic: "kar-TOWNG"),
            WordPair(native: "cash", translated: "dinheiro", phonetic: "jee-NYAY-roo"),
            WordPair(native: "receipt", translated: "recibo", phonetic: "reh-SEE-boo"),
            WordPair(native: "size", translated: "tamanho", phonetic: "tah-MAH-nyoo"),
            WordPair(native: "color", translated: "cor", phonetic: "kor"),
            WordPair(native: "shop", translated: "loja", phonetic: "LOH-zhah"),
            WordPair(native: "market", translated: "mercado", phonetic: "mer-KAH-doo"),
            WordPair(native: "buy", translated: "comprar", phonetic: "kohm-PRAR"),
            WordPair(native: "pay", translated: "pagar", phonetic: "pah-GAR"),
            WordPair(native: "change", translated: "troco", phonetic: "TROH-koo"),
        ]),

        // MARK: - Common Phrases
        BlockContent(name: "Common Phrases", words: [
            WordPair(native: "I don't understand", translated: "não entendo", phonetic: "náung en-TEN-doo"),
            WordPair(native: "I don't speak Portuguese", translated: "não falo português", phonetic: "náung FAH-loo por-too-GAYSH"),
            WordPair(native: "do you speak English", translated: "você fala inglês", phonetic: "voh-SEH FAH-lah een-GLESH"),
            WordPair(native: "I need help", translated: "preciso de ajuda", phonetic: "preh-SEE-zoo jee ah-ZHOO-dah"),
            WordPair(native: "where is the bathroom", translated: "onde fica o banheiro", phonetic: "ON-jee FEE-kah oo bahn-YAY-roo"),
            WordPair(native: "I'm lost", translated: "estou perdido", phonetic: "eh-SHOW per-JEE-doo"),
            WordPair(native: "I'm hungry", translated: "estou com fome", phonetic: "eh-SHOW kohm FOH-mee"),
            WordPair(native: "I'm thirsty", translated: "estou com sede", phonetic: "eh-SHOW kohm SEH-jee"),
            WordPair(native: "I'm tired", translated: "estou cansado", phonetic: "eh-SHOW kahn-SAH-doo"),
            WordPair(native: "I'm fine", translated: "estou bem", phonetic: "eh-SHOW bayng"),
            WordPair(native: "nice to meet you", translated: "prazer em conhecê-lo", phonetic: "prah-ZER ayng koh-nye-SEH-loo"),
            WordPair(native: "see you later", translated: "até mais", phonetic: "ah-TEH mish"),
            WordPair(native: "take care", translated: "se cuide", phonetic: "see KWEE-jee"),
            WordPair(native: "no problem", translated: "sem problema", phonetic: "sayng proh-BLEH-mah"),
            WordPair(native: "of course", translated: "claro", phonetic: "KLAH-roo"),
        ]),
    ]
}
