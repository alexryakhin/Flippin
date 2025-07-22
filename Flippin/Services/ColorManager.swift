//
//  ColorManager.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI
import Combine
import Foundation

@MainActor
final class ColorManager: ObservableObject {

    // MARK: - Public properties

    @Published var backgroundStyle: BackgroundStyle = .gradient
    @Published var userColor: Color = .blue

    @Published private(set) var tintColor: Color = .blue
    @Published private(set) var foregroundColor: Color = .blue
    @Published private(set) var colorScheme: ColorScheme = .light

    static let shared = ColorManager()

    // MARK: - Private properties

    private let colorSchemePublisher = CurrentValueSubject<ColorScheme, Never>(.light)
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Init

    private init() {
        // Initialize all values from UserDefaults using the new extension
        let savedRGBA: RGBAColor = UserDefaults.standard.getCodable(RGBAColor.self, forKey: UserDefaultsKey.userColor, default: .blue)
        let savedBackgroundStyle: BackgroundStyle = UserDefaults.standard.getCodable(BackgroundStyle.self, forKey: UserDefaultsKey.backgroundStyle, default: .gradient)
        
        self.tintColor = savedRGBA.notTransparentColor
        self.userColor = savedRGBA.color
        self.backgroundStyle = savedBackgroundStyle

        setupBindings()
    }

    // MARK: - Public methods

    /// Updates the current color scheme
    /// This method should be called from views that have access to @Environment(\.colorScheme)
    func updateColorsForColorScheme(_ colorScheme: ColorScheme) {
        colorSchemePublisher.send(colorScheme)
    }

    // MARK: - Private methods

    private func setupBindings() {
        colorSchemePublisher
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newColorScheme in
                self?.colorScheme = newColorScheme
            }
            .store(in: &cancellables)

        $userColor
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] newColor in
                guard let self else { return }
                let rgbaColor = RGBAColor(color: newColor)
                UserDefaults.standard.setCodable(
                    rgbaColor,
                    forKey: UserDefaultsKey.userColor,
                    default: .blue
                )
                userColor = rgbaColor.color
                tintColor = adjustedTintColor()
                foregroundColor = adjustedForegroundColor()
            }
            .store(in: &cancellables)

        $backgroundStyle
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] newStyle in
                UserDefaults.standard.setCodable(
                    newStyle,
                    forKey: UserDefaultsKey.backgroundStyle,
                    default: .gradient
                )
                self?.backgroundStyle = newStyle
                HapticService.shared.selection()
            }
            .store(in: &cancellables)
    }

    private func adjustedTintColor() -> Color {
        switch (colorSchemePublisher.value, userColor.isLight) {
        case (.dark, false): return userColor.lighter(by: 50)
        case (.dark, true): return userColor.darker(by: 10)
        case (.light, true): return userColor.darker(by: 30)
        case (.light, false): return userColor.darker(by: 10)
        default: return userColor
        }
    }

    private func adjustedForegroundColor() -> Color {
        guard !backgroundStyle.isAlwaysDark else { return Color(.white) }
        switch (colorSchemePublisher.value, userColor.isLight) {
        case (.light, false): return Color(.white)
        case (.dark, false): return Color(.white)
        case (.light, true): return Color(.black)
        case (.dark, true): return Color(.black)
        default: return Color(.label)
        }
    }
}
