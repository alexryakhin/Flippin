//
//  VocabularyGrowthChart.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/28/25.
//

import SwiftUI
import Charts

struct VocabularyGrowthChart: View {
    let data: [VocabularyGrowthPoint]
    let tintColor: Color
    
    var body: some View {
        if data.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundColor(.secondary)
                Text(LocalizationKeys.General.noGrowthDataAvailable.localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(height: 100)
        } else {
            Chart(data) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date, unit: .day),
                    y: .value("Mastered Cards", dataPoint.masteredCards)
                )
                .foregroundStyle(tintColor.gradient)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Date", dataPoint.date, unit: .day),
                    y: .value("Mastered Cards", dataPoint.masteredCards)
                )
                .foregroundStyle(tintColor.opacity(0.1))
            }
            .frame(height: 100)
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let count = value.as(Int.self) {
                            Text("\(count)")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Empty Data") {
    VocabularyGrowthChart(
        data: [],
        tintColor: .blue
    )
    .padding(16)
    .background(Color(.systemGroupedBackground))
}

#Preview("Growing Vocabulary - Week") {
    let calendar = Calendar.current
    let today = Date()
    let sampleData: [VocabularyGrowthPoint] = (0..<7).map { dayOffset in
        let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
        let masteredCards = 10 + (7 - dayOffset) * 2 // Growing from 10 to 24 cards
        return VocabularyGrowthPoint(
            date: date,
            masteredCards: masteredCards,
            totalCards: 50
        )
    }.reversed()
    
    VocabularyGrowthChart(
        data: Array(sampleData),
        tintColor: .green
    )
    .padding(16)
    .background(Color(.systemGroupedBackground))
}

#Preview("Growing Vocabulary - Month") {
    let calendar = Calendar.current
    let today = Date()
    let sampleData: [VocabularyGrowthPoint] = (0..<30).map { dayOffset in
        let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
        let masteredCards = 5 + (30 - dayOffset) * 1 // Growing from 5 to 35 cards
        return VocabularyGrowthPoint(
            date: date,
            masteredCards: masteredCards,
            totalCards: 100
        )
    }.reversed()
    
    VocabularyGrowthChart(
        data: Array(sampleData),
        tintColor: .blue
    )
    .padding(16)
    .background(Color(.systemGroupedBackground))
}

#Preview("Steady Growth") {
    let calendar = Calendar.current
    let today = Date()
    let sampleData: [VocabularyGrowthPoint] = (0..<14).map { dayOffset in
        let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
        let masteredCards = 15 + (14 - dayOffset) * 1 // Steady growth from 15 to 29 cards
        return VocabularyGrowthPoint(
            date: date,
            masteredCards: masteredCards,
            totalCards: 75
        )
    }.reversed()
    
    VocabularyGrowthChart(
        data: Array(sampleData),
        tintColor: .orange
    )
    .padding(16)
    .background(Color(.systemGroupedBackground))
}

#Preview("Rapid Growth") {
    let calendar = Calendar.current
    let today = Date()
    let sampleData: [VocabularyGrowthPoint] = (0..<21).map { dayOffset in
        let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
        let masteredCards = 5 + (21 - dayOffset) * 3 // Rapid growth from 5 to 68 cards
        return VocabularyGrowthPoint(
            date: date,
            masteredCards: masteredCards,
            totalCards: 150
        )
    }.reversed()
    
    VocabularyGrowthChart(
        data: Array(sampleData),
        tintColor: .purple
    )
    .padding(16)
    .background(Color(.systemGroupedBackground))
} 