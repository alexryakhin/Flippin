//
//  FeatureRow.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/21/25.
//
import SwiftUI

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let animateContent: Bool
    let delay: Double
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 32)
                .scaleEffect(animateContent ? 1 : 0.5)
                .opacity(animateContent ? 1 : 0)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .offset(x: animateContent ? 0 : -20)
                    .opacity(animateContent ? 1 : 0)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .offset(x: animateContent ? 0 : -20)
                    .opacity(animateContent ? 1 : 0)
            }
            
            Spacer()
        }
        .animation(.easeInOut(duration: 0.4).delay(delay), value: animateContent)
    }
}
