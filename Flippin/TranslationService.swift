import Foundation

enum TranslationServiceError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)
}

final class TranslationService {
    static func translate(text: String, from sourceLang: String, to targetLang: String) async throws -> String {
        guard let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw TranslationServiceError.invalidURL
        }
        let urlString = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=\(sourceLang)&tl=\(targetLang)&dt=t&q=\(encodedText)"
        guard let url = URL(string: urlString) else {
            throw TranslationServiceError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TranslationServiceError.invalidResponse
        }
        // The response is a nested JSON array
        if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [Any],
           let translations = jsonArray[0] as? [[Any]],
           let firstTranslation = translations.first,
           let translated = firstTranslation.first as? String,
           let detectedLanguage = jsonArray[2] as? String {
            print("Detected language:", detectedLanguage)
            return translated
        }
        throw TranslationServiceError.decodingError
    }
} 
