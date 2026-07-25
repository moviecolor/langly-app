import SwiftUI
import SwiftData

/// Pre-loaded vocabulary content for Langly.
/// Multiple themed blocks with common Portuguese words.
struct VocabularyContent {

    struct WordPair {
        let native: String
        let translated: String
    }

    struct BlockContent {
        let name: String
        let words: [WordPair]
    }

    /// All starter blocks available on first launch.
    static let starterBlocks: [BlockContent] = [
        // MARK: - Essentials
        BlockContent(name: "Essentials", words: [
            WordPair(native: "yes", translated: "sim"),
            WordPair(native: "no", translated: "não"),
            WordPair(native: "please", translated: "por favor"),
            WordPair(native: "thank you", translated: "obrigado"),
            WordPair(native: "sorry", translated: "desculpe"),
            WordPair(native: "hello", translated: "olá"),
            WordPair(native: "goodbye", translated: "adeus"),
            WordPair(native: "good morning", translated: "bom dia"),
            WordPair(native: "good night", translated: "boa noite"),
            WordPair(native: "excuse me", translated: "com licença"),
            WordPair(native: "help", translated: "ajuda"),
            WordPair(native: "great", translated: "ótimo"),
            WordPair(native: "always", translated: "sempre"),
            WordPair(native: "sometimes", translated: "às vezes"),
            WordPair(native: "never", translated: "nunca"),
        ]),

        // MARK: - Questions
        BlockContent(name: "Questions", words: [
            WordPair(native: "who", translated: "quem"),
            WordPair(native: "what", translated: "o que"),
            WordPair(native: "where", translated: "onde"),
            WordPair(native: "when", translated: "quando"),
            WordPair(native: "why", translated: "por quê"),
            WordPair(native: "how", translated: "como"),
            WordPair(native: "how much", translated: "quanto"),
            WordPair(native: "how many", translated: "quantos"),
            WordPair(native: "which", translated: "qual"),
            WordPair(native: "can I", translated: "posso"),
            WordPair(native: "do you have", translated: "você tem"),
            WordPair(native: "is it", translated: "é"),
            WordPair(native: "where is", translated: "onde está"),
            WordPair(native: "what time", translated: "que horas"),
            WordPair(native: "why", translated: "por que"),
        ]),

        // MARK: - People & Family
        BlockContent(name: "People & Family", words: [
            WordPair(native: "he", translated: "ele"),
            WordPair(native: "she", translated: "ela"),
            WordPair(native: "I", translated: "eu"),
            WordPair(native: "you", translated: "você"),
            WordPair(native: "we", translated: "nós"),
            WordPair(native: "they", translated: "eles"),
            WordPair(native: "friend", translated: "amigo"),
            WordPair(native: "family", translated: "família"),
            WordPair(native: "mother", translated: "mãe"),
            WordPair(native: "father", translated: "pai"),
            WordPair(native: "brother", translated: "irmão"),
            WordPair(native: "sister", translated: "irmã"),
            WordPair(native: "child", translated: "criança"),
            WordPair(native: "baby", translated: "bebê"),
            WordPair(native: "person", translated: "pessoa"),
        ]),

        // MARK: - Numbers
        BlockContent(name: "Numbers", words: [
            WordPair(native: "one", translated: "um"),
            WordPair(native: "two", translated: "dois"),
            WordPair(native: "three", translated: "três"),
            WordPair(native: "four", translated: "quatro"),
            WordPair(native: "five", translated: "cinco"),
            WordPair(native: "six", translated: "seis"),
            WordPair(native: "seven", translated: "sete"),
            WordPair(native: "eight", translated: "oito"),
            WordPair(native: "nine", translated: "nove"),
            WordPair(native: "ten", translated: "dez"),
            WordPair(native: "twenty", translated: "vinte"),
            WordPair(native: "thirty", translated: "trinta"),
            WordPair(native: "fifty", translated: "cinquenta"),
            WordPair(native: "hundred", translated: "cem"),
            WordPair(native: "thousand", translated: "mil"),
        ]),

        // MARK: - Time & Days
        BlockContent(name: "Time & Days", words: [
            WordPair(native: "today", translated: "hoje"),
            WordPair(native: "tomorrow", translated: "amanhã"),
            WordPair(native: "yesterday", translated: "ontem"),
            WordPair(native: "now", translated: "agora"),
            WordPair(native: "later", translated: "mais tarde"),
            WordPair(native: "morning", translated: "manhã"),
            WordPair(native: "afternoon", translated: "tarde"),
            WordPair(native: "night", translated: "noite"),
            WordPair(native: "Monday", translated: "segunda-feira"),
            WordPair(native: "Tuesday", translated: "terça-feira"),
            WordPair(native: "Wednesday", translated: "quarta-feira"),
            WordPair(native: "Thursday", translated: "quinta-feira"),
            WordPair(native: "Friday", translated: "sexta-feira"),
            WordPair(native: "Saturday", translated: "sábado"),
            WordPair(native: "Sunday", translated: "domingo"),
        ]),

        // MARK: - Food & Drinks
        BlockContent(name: "Food & Drinks", words: [
            WordPair(native: "water", translated: "água"),
            WordPair(native: "coffee", translated: "café"),
            WordPair(native: "bread", translated: "pão"),
            WordPair(native: "rice", translated: "arroz"),
            WordPair(native: "meat", translated: "carne"),
            WordPair(native: "chicken", translated: "frango"),
            WordPair(native: "fish", translated: "peixe"),
            WordPair(native: "egg", translated: "ovo"),
            WordPair(native: "milk", translated: "leite"),
            WordPair(native: "fruit", translated: "fruta"),
            WordPair(native: "apple", translated: "maçã"),
            WordPair(native: "banana", translated: "banana"),
            WordPair(native: "orange", translated: "laranja"),
            WordPair(native: "beer", translated: "cerveja"),
            WordPair(native: "wine", translated: "vinho"),
        ]),

        // MARK: - Travel & Directions
        BlockContent(name: "Travel & Directions", words: [
            WordPair(native: "airport", translated: "aeroporto"),
            WordPair(native: "hotel", translated: "hotel"),
            WordPair(native: "restaurant", translated: "restaurante"),
            WordPair(native: "beach", translated: "praia"),
            WordPair(native: "street", translated: "rua"),
            WordPair(native: "left", translated: "esquerda"),
            WordPair(native: "right", translated: "direita"),
            WordPair(native: "straight", translated: "em frente"),
            WordPair(native: "here", translated: "aqui"),
            WordPair(native: "there", translated: "lá"),
            WordPair(native: "far", translated: "longe"),
            WordPair(native: "near", translated: "perto"),
            WordPair(native: "map", translated: "mapa"),
            WordPair(native: "taxi", translated: "táxi"),
            WordPair(native: "bus", translated: "ônibus"),
        ]),

        // MARK: - Shopping
        BlockContent(name: "Shopping", words: [
            WordPair(native: "how much", translated: "quanto custa"),
            WordPair(native: "expensive", translated: "caro"),
            WordPair(native: "cheap", translated: "barato"),
            WordPair(native: "sale", translated: "promoção"),
            WordPair(native: "money", translated: "dinheiro"),
            WordPair(native: "card", translated: "cartão"),
            WordPair(native: "cash", translated: "dinheiro"),
            WordPair(native: "receipt", translated: "recibo"),
            WordPair(native: "size", translated: "tamanho"),
            WordPair(native: "color", translated: "cor"),
            WordPair(native: "shop", translated: "loja"),
            WordPair(native: "market", translated: "mercado"),
            WordPair(native: "buy", translated: "comprar"),
            WordPair(native: "pay", translated: "pagar"),
            WordPair(native: "change", translated: "troco"),
        ]),

        // MARK: - Common Phrases
        BlockContent(name: "Common Phrases", words: [
            WordPair(native: "I don't understand", translated: "não entendo"),
            WordPair(native: "I don't speak Portuguese", translated: "não falo português"),
            WordPair(native: "do you speak English", translated: "você fala inglês"),
            WordPair(native: "I need help", translated: "preciso de ajuda"),
            WordPair(native: "where is the bathroom", translated: "onde fica o banheiro"),
            WordPair(native: "I'm lost", translated: "estou perdido"),
            WordPair(native: "I'm hungry", translated: "estou com fome"),
            WordPair(native: "I'm thirsty", translated: "estou com sede"),
            WordPair(native: "I'm tired", translated: "estou cansado"),
            WordPair(native: "I'm fine", translated: "estou bem"),
            WordPair(native: "nice to meet you", translated: "prazer em conhecê-lo"),
            WordPair(native: "see you later", translated: "até mais"),
            WordPair(native: "take care", translated: "se cuide"),
            WordPair(native: "no problem", translated: "sem problema"),
            WordPair(native: "of course", translated: "claro"),
        ]),
    ]
}
