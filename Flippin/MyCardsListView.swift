//
//  MyCardsListView.swift
//  SpeakCards
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct MyCardsListView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
            }
            .navigationTitle("My Cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
