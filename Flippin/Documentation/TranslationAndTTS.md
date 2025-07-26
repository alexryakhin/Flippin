# Translation & TTS System

## Overview

The translation and text-to-speech (TTS) system provides real-time translation capabilities and high-quality speech synthesis for language learning. It integrates Google Translate API for translations and offers both online and offline TTS options with automatic fallback mechanisms.

## Architecture

### 1. TranslationService
Handles real-time translation using Google Translate API:
- **Google Translate API**: Free translation service
- **Error Handling**: Comprehensive error management
- **Analytics Integration**: Translation success/failure tracking
- **URL Encoding**: Proper text encoding for API calls

### 2. TTSPlayer
Provides text-to-speech functionality:
- **Online TTS**: Google Translate TTS for high quality
- **Offline TTS**: AVSpeechSynthesizer fallback
- **Voice Selection**: Language-specific voice mapping
- **Audio Session Management**: Proper audio handling

## Translation Service

### Core Translation Function
```swift
static func translate(text: String, from sourceLang: String, to targetLang: String) async throws -> String {
    guard let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
        AnalyticsService.trackErrorEvent(.translationFailed, errorMessage: "Invalid URL encoding")
        throw TranslationServiceError.invalidURL
    }
    
    let urlString = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=\(sourceLang)&tl=\(targetLang)&dt=t&q=\(encodedText)"
    guard let url = URL(string: urlString) else {
        AnalyticsService.trackErrorEvent(.translationFailed, errorMessage: "Invalid URL")
        throw TranslationServiceError.invalidURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        AnalyticsService.trackErrorEvent(.translationFailed, errorMessage: "HTTP \(statusCode)")
        throw TranslationServiceError.invalidResponse
    }
    
    // Parse nested JSON response
    if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [Any],
       let translations = jsonArray[0] as? [[Any]],
       let firstTranslation = translations.first,
       let translated = firstTranslation.first as? String,
       let detectedLanguage = jsonArray[2] as? String {
        print("Detected language:", detectedLanguage)
        return translated
    }
    
    AnalyticsService.trackErrorEvent(.translationFailed, errorMessage: "Decoding error")
    throw TranslationServiceError.decodingError
}
```

### Error Types
```swift
enum TranslationServiceError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)
}
```

### API Response Structure
The Google Translate API returns a nested JSON array:
```json
[
  [
    ["translated_text", "original_text", null, null, 3]
  ],
  null,
  "detected_language_code",
  null,
  null,
  null,
  null,
  []
]
```

## TTS Player

### Core TTS Function
```swift
func play(_ text: String, language: Language) async throws {
    guard !text.isEmpty else { return }

    // Try online TTS first, fallback to offline if it fails
    do {
        try await playOnlineTTS(text, language: language)
    } catch {
        // Fallback to offline TTS
        try await playOfflineTTS(text, language: language)
    }
}
```

### Online TTS (Google Translate)
```swift
private func playOnlineTTS(_ text: String, language: Language) async throws {
    let escapedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed).orEmpty
    let urlString = "https://translate.google.com/translate_tts?ie=UTF-8&client=gtx&q=\(escapedText)&tl=\(language.voiceOverCode)"
    guard let url = URL(string: urlString) else { 
        throw TTSError.invalidURL 
    }

    guard player?.isPlaying == false || player == nil else { 
        throw TTSError.alreadyPlaying 
    }

    #if os(iOS)
    let _ = try setupAudioSession()
    #endif
    
    let temporaryDownloadURL = try await temporaryDownloadURL(for: url)
    try await play(from: temporaryDownloadURL)
}
```

### Offline TTS (AVSpeechSynthesizer)
```swift
private func playOfflineTTS(_ text: String, language: Language) async throws {
    guard let synthesizer = speechSynthesizer else {
        throw TTSError.synthesizerNotAvailable
    }

    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(identifier: getVoiceIdentifier(for: language))
    utterance.rate = 0.5
    utterance.pitchMultiplier = 1.0
    utterance.volume = 1.0

    synthesizer.speak(utterance)
}
```

### Voice Mapping
```swift
private func getVoiceIdentifier(for language: Language) -> String {
    switch language {
    case .english:
        return "com.apple.ttsbundle.siri_female_en-US_compact"
    case .spanish:
        return "com.apple.ttsbundle.Monica-compact"
    case .french:
        return "com.apple.ttsbundle.Aurelie-compact"
    case .german:
        return "com.apple.ttsbundle.Anna-compact"
    case .italian:
        return "com.apple.ttsbundle.Alice-compact"
    case .portuguese:
        return "com.apple.ttsbundle.Joana-compact"
    case .dutch:
        return "com.apple.ttsbundle.Xander-compact"
    case .swedish:
        return "com.apple.ttsbundle.Alva-compact"
    case .chinese:
        return "com.apple.ttsbundle.Ting-Ting-compact"
    case .japanese:
        return "com.apple.ttsbundle.Kyoko-compact"
    case .korean:
        return "com.apple.ttsbundle.Yuna-compact"
    case .vietnamese:
        return "com.apple.ttsbundle.Lan-compact"
    case .russian:
        return "com.apple.ttsbundle.Katya-compact"
    case .arabic:
        return "com.apple.ttsbundle.Tarik-compact"
    case .hindi:
        return "com.apple.ttsbundle.Lekha-compact"
    case .croatian:
        return "com.apple.ttsbundle.Petra-compact"
    case .ukranian:
        return "com.apple.ttsbundle.Lesya-compact"
    }
}
```

### Language Code Mapping
```swift
private func getLanguageCode(for language: Language) -> String {
    switch language {
    case .english: return "en-US"
    case .spanish: return "es-ES"
    case .french: return "fr-FR"
    case .german: return "de-DE"
    case .italian: return "it-IT"
    case .portuguese: return "pt-BR"
    case .dutch: return "nl-NL"
    case .swedish: return "sv-SE"
    case .chinese: return "zh-CN"
    case .japanese: return "ja-JP"
    case .korean: return "ko-KR"
    case .vietnamese: return "vi-VN"
    case .russian: return "ru-RU"
    case .arabic: return "ar-SA"
    case .hindi: return "hi-IN"
    case .croatian: return "hr-HR"
    case .ukranian: return "uk-UA"
    }
}
```

## Integration with UI

### Translation Pipeline (AddCardSheetViewModel)
```swift
private func setupTranslationPipeline() {
    $nativeText
        .dropFirst(2)
        .debounce(for: .seconds(1), scheduler: RunLoop.main)
        .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        .removeDuplicates()
        .sink { [weak self] text in
            Task { @MainActor in
                await self?.translateText(text)
            }
        }
        .store(in: &cancellables)
}

private func translateText(_ text: String) async {
    guard !isTranslating else { return }

    isTranslating = true

    do {
        let translated = try await TranslationService.translate(
            text: text,
            from: languageManager.userLanguage.rawValue,
            to: languageManager.targetLanguage.rawValue
        )
        targetText = translated
        
        // Haptic feedback for translation completion
        HapticService.shared.translationCompleted()
    } catch {
        print("Translation failed: \(error)")
        AnalyticsService.trackErrorEvent(.translationFailed, errorMessage: error.localizedDescription)
    }

    isTranslating = false
}
```

### TTS Integration (Card Views)
```swift
private func playTTS() {
    // Haptic feedback for TTS start
    HapticService.shared.ttsStarted()

    isPlayingTTS = true
    Task {
        do {
            guard let text = displayText.isEmpty ? nil : displayText,
                  let language = displayLanguage else { return }
            try await TTSPlayer.shared.play(text, language: language)
        } catch {
            print("TTS error: \(error)")
        }
        isPlayingTTS = false
    }
}
```

## Error Handling

### TTS Errors
```swift
enum TTSError: Error, LocalizedError {
    case invalidURL
    case alreadyPlaying
    case synthesizerNotAvailable
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid TTS URL"
        case .alreadyPlaying:
            return "TTS is already playing"
        case .synthesizerNotAvailable:
            return "Speech synthesizer not available"
        case .networkError:
            return "Network error occurred"
        }
    }
}
```

### Audio Session Management
```swift
#if os(iOS)
private func setupAudioSession() throws -> AVAudioSession {
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(.playback)
    try session.setActive(true)
    return session
}
#endif
```

## Analytics Integration

### Translation Analytics
```swift
// Track translation failures
AnalyticsService.trackErrorEvent(.translationFailed, errorMessage: error.localizedDescription)

// Track TTS failures
AnalyticsService.trackErrorEvent(.ttsFailed, errorMessage: error.localizedDescription)
```

### Success Tracking
```swift
// Track successful translations
AnalyticsService.trackEvent(.translationCompleted)

// Track TTS usage
AnalyticsService.trackEvent(.cardPlayed)
```

## Performance Optimizations

### Translation Optimizations
- **Debouncing**: 1-second delay to avoid excessive API calls
- **Duplicate Filtering**: Avoid translating same text multiple times
- **Empty Text Filtering**: Skip empty or whitespace-only text
- **URL Encoding**: Proper encoding for special characters

### TTS Optimizations
- **Fallback Strategy**: Online TTS with offline fallback
- **Audio Session Management**: Proper audio session setup
- **Temporary Downloads**: Efficient audio file handling
- **Voice Caching**: Reuse voice objects when possible

## Supported Languages

### Translation Support
All 18 supported languages can be translated between each other:
- **Western**: English, Spanish, French, German, Italian, Portuguese, Dutch, Swedish
- **Asian**: Chinese, Japanese, Korean, Vietnamese
- **Other**: Russian, Arabic, Hindi, Croatian, Ukrainian

### TTS Support
Each language has specific voice mapping:
- **High Quality**: Online Google TTS for best pronunciation
- **Offline Fallback**: System voices for offline usage
- **Voice Selection**: Language-appropriate voice selection

## Best Practices

### Translation
- Implement proper debouncing to avoid API rate limits
- Handle network errors gracefully
- Provide user feedback during translation
- Cache translations when appropriate

### TTS
- Always provide offline fallback
- Use appropriate voice selection
- Handle audio session properly
- Provide visual feedback during playback

### Error Handling
- Implement comprehensive error handling
- Provide user-friendly error messages
- Log errors for debugging
- Implement retry mechanisms

## Future Enhancements

- **Translation Caching**: Cache translations to reduce API calls
- **Offline Translation**: Local translation models
- **Voice Customization**: User-selectable voices
- **Pronunciation Guides**: IPA pronunciation display
- **Translation Quality**: Multiple translation service support
- **Audio Export**: Export TTS audio files
- **Batch Translation**: Translate multiple cards at once 
