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

    @Published var backgroundStyle: BgStyle = .gradient
    @Published var userColor: Color = .blue
    @Published var userColorSchemePreference: ColorSchemeInternal = .system

    @Published private(set) var tintColor: Color = .blue
    @Published private(set) var foregroundColor: Color = .blue
    @Published private(set) var colorScheme: ColorScheme? = nil

    var borderedProminentForegroundColor: Color {
        let isBlackForeground: Bool = colorScheme == .dark && userColor.isLight
        return isBlackForeground ? .black : .white
    }

    static let shared = ColorManager()

    // MARK: - Private properties

    private let colorSchemePublisher = CurrentValueSubject<ColorScheme?, Never>(nil)
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Init

    private init() {
        // Initialize all values from UserDefaults using the new extension
        let savedRGBA: RGBAColor = UserDefaults.standard.getCodable(RGBAColor.self, forKey: UserDefaultsKey.userColor, default: .blue)
        let savedBackgroundStyle: BgStyle = UserDefaults.standard.getCodable(BgStyle.self, forKey: UserDefaultsKey.backgroundStyle, default: .gradient)
        let savedColorSchemePreference: ColorSchemeInternal = UserDefaults.standard.getCodable(ColorSchemeInternal.self, forKey: UserDefaultsKey.colorSchemePreference, default: .system)

        self.tintColor = savedRGBA.notTransparentColor
        self.userColor = savedRGBA.color
        self.backgroundStyle = savedBackgroundStyle
        self.userColorSchemePreference = savedColorSchemePreference

        setupBindings()
    }

    // MARK: - Public methods

    /// Updates the current color scheme
    /// This method should be called from views that have access to @Environment(\.colorScheme)
    func updateColorsForColorScheme(_ colorScheme: ColorScheme?) {
        // Use user preference if set, otherwise use system color scheme
        colorSchemePublisher.send(colorScheme)
    }

    // MARK: - Private methods

    private func setupBindings() {
        colorSchemePublisher
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newColorScheme in
                guard let self else { return }
                colorScheme = newColorScheme
                tintColor = adjustedTintColor()
                foregroundColor = adjustedForegroundColor()
            }
            .store(in: &cancellables)

        $userColor
            .removeDuplicates()
            .throttle(for: .seconds(0.2), scheduler: RunLoop.main, latest: true)
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
                
                // Track background color change
                AnalyticsService.trackEvent(.backgroundColorChanged)
            }
            .store(in: &cancellables)

        $backgroundStyle
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] newStyle in
                guard let self else { return }
                UserDefaults.standard.setCodable(
                    newStyle,
                    forKey: UserDefaultsKey.backgroundStyle,
                    default: .gradient
                )
                backgroundStyle = newStyle
                tintColor = adjustedTintColor()
                foregroundColor = adjustedForegroundColor()
                HapticService.shared.selection()
            }
            .store(in: &cancellables)

        $userColorSchemePreference
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] newPreference in
                guard let self else { return }
                UserDefaults.standard.setCodable(
                    newPreference,
                    forKey: UserDefaultsKey.colorSchemePreference,
                    default: nil
                )
                updateColorsForColorScheme(newPreference.systemColorScheme)
                tintColor = adjustedTintColor()
                foregroundColor = adjustedForegroundColor()
                HapticService.shared.selection()
            }
            .store(in: &cancellables)
    }

    private func adjustedTintColor() -> Color {
        switch (colorSchemePublisher.value, userColor.isLight) {
        case (.dark, false):
            // Dark mode with dark color - make it more vibrant
            return userColor.lighter(by: 70).saturated(by: 0)
        case (.dark, true):
            // Dark mode with light color - make it more muted
            return userColor.darker(by: 20).desaturated(by: 10)
        case (.light, true):
            // Light mode with light color - make it more visible
            return userColor.darker(by: 40).saturated(by: 15)
        case (.light, false):
            // Light mode with dark color - make it more vibrant
            return userColor.lighter(by: 20).saturated(by: 25)
        default:
            return userColor
        }
    }

    private func adjustedForegroundColor() -> Color {
        guard !backgroundStyle.isAlwaysDark else { return Color(.white) }
        
        switch (colorSchemePublisher.value, userColor.isLight) {
        case (.light, false):
            // Light mode with dark color - use white for good contrast
            return Color(.white)
        case (.dark, false):
            // Dark mode with dark color - use white for good contrast
            return Color(.white)
        case (.light, true):
            // Light mode with light color - use black for good contrast
            return Color(.black)
        case (.dark, true):
            // Dark mode with light color - use black for good contrast
            return Color(.black)
        default:
            // Fallback to system label color
            return Color(.label)
        }
    }
}
