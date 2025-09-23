//
//  View+Extension.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/11/25.
//

import SwiftUI

extension View {
    func editModeDisablingLayerView() -> some View {
        self.background(
            VStack {
                Spacer()
                    .frame(
                        width: UIScreen.main.bounds.width - 32,
                        height: UIScreen.main.bounds.height
                    )
            }
                .background(Color.black.opacity(0.00000001)) // a hack so clear color would still be touchable
                .editModeDisabling()
        )
    }

    func editModeDisabling() -> some View {
        self
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
    }

    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden()
        case false: self
        }
    }

    func padding(
        vertical: CGFloat,
        horizontal: CGFloat
    ) -> some View {
        self
            .padding(.vertical, vertical)
            .padding(.horizontal, horizontal)
    }

    func backgroundColor(_ color: Color) -> some View {
        self.background(color)
    }

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func ifLet<T, Result: View>(_ value: T?, transform: (Self, T) -> Result) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }

    func onTap(_ onTap: @escaping () -> Void) -> some View {
        Button {
            onTap()
        } label: {
            self
        }
    }

    func errorReceived(title: String = Loc.Errors.unknownError, _ error: Error) {
        Task { @MainActor in
            AlertCenter.shared.showAlert(
                with: .info(
                    title: title,
                    message: error.localizedDescription
                )
            )
        }
    }

    func showAlertWithMessage(_ message: String) {
        Task { @MainActor in
            AlertCenter.shared.showAlert(
                with: .info(
                    title: Loc.Errors.unknownError,
                    message: message
                )
            )
        }
    }

    func groupedBackground() -> some View {
        self.background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

extension Image {
    func frame(sideLength: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(width: sideLength, height: sideLength)
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func clippedWithBackground(
        _ color: Color = Color(.secondarySystemGroupedBackground),
        in shape: some Shape = RoundedRectangle(cornerRadius: 24),
        showShadow: Bool = false
    ) -> some View {
        self
            .background(color)
            .clipShape(shape)
            .if(showShadow) {
                $0.shadow(color: Color(.separator), radius: 2)
            }
    }

    func clippedWithBackgroundMaterial(
        _ material: Material = .thinMaterial,
        in shape: some Shape = RoundedRectangle(cornerRadius: 24),
        showShadow: Bool = false
    ) -> some View {
        self
            .background(material)
            .clipShape(shape)
            .if(showShadow) {
                $0.shadow(color: Color(.separator), radius: 2)
            }
    }

    func clippedWithPaddingAndBackground(
        _ color: Color = Color(.secondarySystemGroupedBackground),
        in shape: some Shape = RoundedRectangle(cornerRadius: 24),
        showShadow: Bool = false
    ) -> some View {
        self
            .padding(16)
            .background(color)
            .clipShape(shape)
            .if(showShadow) {
                $0.shadow(color: Color(.separator), radius: 2)
            }
    }

    func clippedWithPaddingAndBackgroundMaterial(
        _ material: Material = .thinMaterial,
        in shape: some Shape = RoundedRectangle(cornerRadius: 24),
        showShadow: Bool = false
    ) -> some View {
        self
            .padding(16)
            .background(material)
            .clipShape(shape)
            .if(showShadow) {
                $0.shadow(color: Color(.separator), radius: 2)
            }
    }
}

enum GlassEffect {
    case regular
    case clear
    case identity
    case tint(Color?)
    case interactive(Bool)

    @available(macOS 26.0, *)
    @available(iOS 26.0, *)
    var glass: Glass {
        switch self {
        case .regular:
            return .regular
        case .clear:
            return .clear
        case .identity:
            return .identity
        case .tint(let color):
            return Glass.regular.tint(color)
        case let .interactive(isEnabled):
            return Glass.regular.interactive(isEnabled)
        }
    }
}

extension View {
    @ViewBuilder
    func glassEffectIfAvailable(
        _ glass: GlassEffect = .regular,
        in shape: some Shape = RoundedRectangle(cornerRadius: 16)
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self.glassEffect(glass.glass, in: shape)
        } else {
            self
        }
    }

    @ViewBuilder
    func glassBackgroundEffectIfAvailable(
        _ glass: GlassEffect = .regular,
        in shape: some Shape = RoundedRectangle(cornerRadius: 16)
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self
                .background(
                    Color.clear
                        .glassEffect(glass.glass, in: shape)
                )
        } else {
            self
        }
    }

    @ViewBuilder
    func glassEffectIfAvailableWithBackup(
        _ glass: GlassEffect = .regular,
        in shape: some Shape = RoundedRectangle(cornerRadius: 16)
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self.glassEffect(glass.glass, in: shape)
        } else {
            self
                .clippedWithBackgroundMaterial(.regular, in: shape)
        }
    }

    @ViewBuilder
    func glassBackgroundEffectIfAvailableWithBackup(
        _ glass: GlassEffect = .regular,
        in shape: some Shape = RoundedRectangle(cornerRadius: 16)
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self
                .background(
                    Color.clear
                        .glassEffect(glass.glass, in: shape)
                )
        } else {
            self
                .clippedWithBackgroundMaterial(.regular, in: shape)
        }
    }
}

var isGlassAvailable: Bool {
    if #available(iOS 26.0, macOS 26.0, *) {
        return true
    } else {
        return false
    }
}
