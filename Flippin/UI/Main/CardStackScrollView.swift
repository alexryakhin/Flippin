//
//  CardStackScrollView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct CardStackScrollView: View {
    @EnvironmentObject private var colorManager: ColorManager
    private let items: [CardItem]

    init(items: [CardItem]) {
        self.items = items
    }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(items, id: \.id) { item in
                        CardView(item: item)
                            .environmentObject(colorManager)
                            .frame(width: size.width)
                            .visualEffect { content, geometryProxy in
                                content
                                    .scaleEffect(scale(geometryProxy))
                                    .offset(x: minX(geometryProxy))
                                    .offset(x: excessMinX(geometryProxy, offset: isPad ? 40 : 16))
                            }
                            .zIndex(items.zIndex(item))
                    }
                }
            }
            .scrollTargetBehavior(.paging)
            .scrollClipDisabled()
        }
    }

    /// Stacked Cards Animation
    func minX(_ proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
        return minX < 0 ? 0 : -minX
    }

    func progress(_ proxy: GeometryProxy, limit: CGFloat = 2) -> CGFloat {
        let maxX = proxy.frame(in: .scrollView(axis: .horizontal)).maxX
        let width = proxy.bounds(of: .scrollView(axis: .horizontal))?.width ?? 0
        // Converting into Progress
        let progress = (maxX / width) - 1.0
        let cappedProgress = min(progress, limit)
        return cappedProgress
    }

    func scale(_ proxy: GeometryProxy, scale: CGFloat = 0.05) -> CGFloat {
        let progress = progress(proxy)
        return 1 - (progress * scale)
    }

    func excessMinX(_ proxy: GeometryProxy, offset: CGFloat = 16) -> CGFloat {
        let progress = progress(proxy)
        return progress * offset
    }
}

extension Array where Element: Identifiable {
    func zIndex(_ element: Element) -> CGFloat {
        if let index = firstIndex(where: { $0.id == element.id }) {
            return CGFloat(count) - CGFloat(index)
        }
        return .zero
    }
}
