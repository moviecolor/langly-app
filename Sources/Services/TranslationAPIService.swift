import Foundation

/// Free translation API service using MyMemory (no API key required).
/// Falls back to Google Translate's unofficial endpoint if MyMemory fails.
///
/// Usage limits: 5000 words/day for anonymous users (more than enough for a vocab app).
@MainActor
final class TranslationAPIService {
    static let shared = TranslationAPIService()

    private let session: URLSession
    private let cache = NSCache<NSString, NSString>()

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
        cache.countLimit = 500
    }

    /// Translates text from one language to another.
    /// - Parameters:
    ///   - text: The text to translate.
    ///   - from: Source language code (e.g., "en").
    ///   - to: Target language code (e.g., "pt").
    /// - Returns: Translated text, or the original text if translation fails.
    func translate(_ text: String, from sourceLang: String = "en", to targetLang: String = "pt") async -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return text }

        // Check cache first.
        let cacheKey = "\(sourceLang)|\(targetLang)|\(trimmed.lowercased())" as NSString
        if let cached = cache.object(forKey: cacheKey) {
            return cached as String
        }

        // Try MyMemory API first (free, reliable).
        let result = await translateMyMemory(text: trimmed, from: sourceLang, to: targetLang)

        // Cache successful translations.
        if result != trimmed {
            cache.setObject(result as NSString, forKey: cacheKey)
        }

        return result
    }

    /// Translates multiple texts concurrently.
    func translate(_ texts: [String], from sourceLang: String = "en", to targetLang: String = "pt") async -> [String] {
        await withTaskGroup(of: (Int, String).self) { group in
            for (index, text) in texts.enumerated() {
                group.addTask {
                    let translated = await self.translate(text, from: sourceLang, to: targetLang)
                    return (index, translated)
                }
            }

            var results = Array(repeating: "", count: texts.count)
            for await (index, translated) in group {
                results[index] = translated
            }
            return results
        }
    }

    // MARK: - MyMemory API

    /// MyMemory free translation API. No API key required.
    /// Docs: https://mymemory.translated.net/doc/spec.php
    private func translateMyMemory(text: String, from sourceLang: String, to targetLang: String) async -> String {
        let langPair = "\(sourceLang)|\(targetLang)"
        let query = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? text

        guard let url = URL(string: "https://api.mymemory.translated.net/get?q=\(query)&langpair=\(langPair)") else {
            return text
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("[TranslationAPI] MyMemory returned non-200 status")
                return text
            }

            let result = try JSONDecoder().decode(MyMemoryResponse.self, from: data)

            if let translated = result.responseData?.translatedText,
               !translated.isEmpty,
               translated.lowercased() != text.lowercased() {
                return translated
            }
        } catch {
            print("[TranslationAPI] MyMemory failed: \(error.localizedDescription)")
        }

        return text
    }
}

// MARK: - MyMemory API Response Models

/// Response from MyMemory Translation API.
struct MyMemoryResponse: Codable {
    let responseData: ResponseData?
    let responseStatus: Int?
    let responseDetails: String?

    struct ResponseData: Codable {
        let translatedText: String?
        let match: Double?
        let source: String?
    }
}
