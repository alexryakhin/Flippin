//
//  NebulaView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct NebulaView: View {

    struct Nebula: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let opacity: Double
        let color: Color
    }

    let nebula: Nebula
    
    var body: some View {
        Circle()
            .fill(nebula.color)
            .frame(width: nebula.size, height: nebula.size)
            .opacity(nebula.opacity)
            .blur(radius: 30)
            .position(
                x: nebula.x * UIScreen.main.bounds.width,
                y: nebula.y * UIScreen.main.bounds.height
            )
    }
} 
