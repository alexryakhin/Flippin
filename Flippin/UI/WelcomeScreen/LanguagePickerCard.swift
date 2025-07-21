//
//  LanguagePickerCard.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/21/25.
//
import SwiftUI

struct LanguagePickerCard: View {
    let title: String
    let subtitle: String
    @Binding var selection: String
    let animateContent: Bool
    let delay: Double
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .offset(x: animateContent ? 0 : -20)
                    .opacity(animateContent ? 1 : 0)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .offset(x: animateContent ? 0 : -20)
                    .opacity(animateContent ? 1 : 0)
            }

            Spacer()

            Picker(title, selection: $selection) {
                ForEach(Language.allCases) { lang in
                    Text(lang.displayName).tag(lang.rawValue)
                }
            }
            .pickerStyle(.menu)
            .scaleEffect(animateContent ? 1 : 0.9)
            .opacity(animateContent ? 1 : 0)
        }
        .padding(20)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .animation(.easeInOut(duration: 0.4).delay(delay), value: animateContent)
    }
}
