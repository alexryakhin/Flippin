//
//  SyncIndicator.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import SwiftUI

enum SyncState {
    case syncing
    case synced
    case error
    case idle
}

struct SyncIndicator: View {
    let state: SyncState
    let size: CGFloat
    
    @State private var rotationAngle: Double = 0
    
    init(state: SyncState, size: CGFloat = 16) {
        self.state = state
        self.size = size
    }
    
    var body: some View {
        Group {
            switch state {
            case .syncing:
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: size))
                    .foregroundStyle(.accent)
                    .rotationEffect(.degrees(rotationAngle))
                    .onAppear {
                        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                            rotationAngle = 360
                        }
                    }
                    .onDisappear {
                        rotationAngle = 0
                    }
                
            case .synced:
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: size))
                    .foregroundStyle(.green)
                    .transition(.scale.combined(with: .opacity))
                
            case .error:
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: size))
                    .foregroundStyle(.red)
                    .transition(.scale.combined(with: .opacity))
                
            case .idle:
                EmptyView()
            }
        }
//        .animation(.easeInOut(duration: 0.2), value: state)
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 10) {
            SyncIndicator(state: .syncing)
            Text("Syncing...")
        }
        
        HStack(spacing: 10) {
            SyncIndicator(state: .synced)
            Text("Synced")
        }
        
        HStack(spacing: 10) {
            SyncIndicator(state: .error)
            Text("Sync Error")
        }
        
        HStack(spacing: 10) {
            SyncIndicator(state: .idle)
            Text("Idle")
        }
    }
    .padding(.all)
} 
