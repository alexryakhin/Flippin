//
//  TTSPlayer.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 3/9/25.
//

import Foundation
import AVFoundation

protocol TTSPlayerInterface {
    func play(_ text: String, language: Language) async throws
}

final class TTSPlayer: TTSPlayerInterface {

    static let shared: TTSPlayerInterface = TTSPlayer()

    private var player: AVAudioPlayer?

    private init() {}

    func play(_ text: String, language: Language) async throws {
        guard !text.isEmpty else { return }

        let escapedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=\(escapedText)&tl=\(language.voiceOverCode)"
        guard let url = URL(string: urlString) else { return }

        guard player?.isPlaying == false || player == nil else { return }

        #if os(iOS)
        let _ = try setupAudioSession()
        #endif
        let temporaryDownloadURL = try await temporaryDownloadURL(for: url)
        try await play(from: temporaryDownloadURL)
    }

    #if os(iOS)
    private func setupAudioSession() throws -> AVAudioSession {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback)
        try session.setActive(true)
        return session
    }
    #endif

    private func temporaryDownloadURL(for url: URL) async throws -> URL {
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        let (url, _) = try await URLSession.shared.download(for: request)
        return url
    }

    @MainActor
    private func play(from url: URL) throws {
        player = try AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        player?.play()
    }
}
