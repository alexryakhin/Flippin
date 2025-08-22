//
//  CustomSectionView.swift
//  RepsCount
//
//  Created by Aleksandr Riakhin on 3/21/25.
//

import SwiftUI

enum SectionBgStyle {
    case material
    case standard
}

struct CustomSectionView<Content: View, TrailingContent: View>: View {

    enum HeaderFontStyle {
        case regular
        case large

        var font: Font {
            switch self {
            case .regular:
                    .headline.weight(.semibold)
            case .large:
                    .title2.weight(.bold)
            }
        }
    }

    private var header: String
    private var headerFontStyle: HeaderFontStyle
    private var backgroundStyle: SectionBgStyle
    private var content: () -> Content
    private var trailingContent: () -> TrailingContent

    init(
        header: String,
        headerFontStyle: HeaderFontStyle = .regular,
        backgroundStyle: SectionBgStyle = .material,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() }
    ) {
        self.header = header
        self.headerFontStyle = headerFontStyle
        self.backgroundStyle = backgroundStyle
        self.content = content
        self.trailingContent = trailingContent
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 2) {
                Text(header)
                    .font(headerFontStyle.font)

                Spacer()

                trailingContent()
            }
            content()
        }
        .padding(16)
        .padding(.top, 6)
        .if(backgroundStyle == .material) { view in
            view.clippedWithBackgroundMaterial(.regularMaterial)
        }
        .if(backgroundStyle == .standard) { view in
            view.clippedWithBackground()
        }
    }
}
