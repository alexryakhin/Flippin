//
//  AccuracyTrendsChart.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/28/25.
//

import SwiftUI
import Charts

struct AccuracyTrendsChart: View {
    let data: [AccuracyDataPoint]
    let tintColor: Color
    
    var body: some View {
        if data.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundColor(.secondary)
                Text(Loc.SubscriptionManagement.noAccuracyDataAvailable)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(height: 200)
        } else {
            Chart(data) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date, unit: .day),
                    y: .value("Accuracy", dataPoint.accuracy * 100)
                )
                .foregroundStyle(tintColor.gradient)
                .interpolationMethod(.catmullRom)
            }
            .frame(height: 200)
            .chartYScale(domain: 0...100)
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let accuracy = value.as(Double.self) {
                            Text(Int(accuracy).asPercentage)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Empty Data") {
    AccuracyTrendsChart(
        data: [],
        tintColor: .blue
    )
    .padding(16)
    .groupedBackground()
}

#Preview("Sample Data - Week") {
    let calendar = Calendar.current
    let today = Date()
    let sampleData = (0..<7).map { dayOffset in
        let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
        let accuracy = Double.random(in: 0.6...0.9) // 60-90% accuracy
        return AccuracyDataPoint(date: date, accuracy: accuracy)
    }.reversed()
    
    AccuracyTrendsChart(
        data: Array(sampleData),
        tintColor: .blue
    )
    .padding(16)
    .groupedBackground()
}

#Preview("Sample Data - Month") {
    let calendar = Calendar.current
    let today = Date()
    let sampleData: [AccuracyDataPoint] = (0..<30).map { dayOffset in
        let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
        let accuracy = Double.random(in: 0.5...0.95) // 50-95% accuracy
        return AccuracyDataPoint(date: date, accuracy: accuracy)
    }.reversed()
    
    AccuracyTrendsChart(
        data: Array(sampleData),
        tintColor: .green
    )
    .padding(16)
    .groupedBackground()
}

#Preview("Sample Data - Year") {
    let calendar = Calendar.current
    let today = Date()
    let sampleData: [AccuracyDataPoint] = (0..<365).compactMap { dayOffset in
        let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
        // Only show data for every 7th day to avoid overcrowding
        guard dayOffset % 7 == 0 else { return nil }
        let accuracy = Double.random(in: 0.4...0.9) // 40-90% accuracy
        return AccuracyDataPoint(date: date, accuracy: accuracy)
    }.reversed()
    
    AccuracyTrendsChart(
        data: Array(sampleData),
        tintColor: .purple
    )
    .padding(16)
    .groupedBackground()
}

#Preview("Improving Trend") {
    let calendar = Calendar.current
    let today = Date()
    let sampleData = (0..<14).map { dayOffset in
        let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
        // Simulate improving accuracy over time (newer dates have higher accuracy)
        let baseAccuracy = 0.5 + (Double(13 - dayOffset) * 0.03) // Starts at 50%, improves to 89%
        let accuracy = min(0.9, baseAccuracy + Double.random(in: -0.05...0.05)) // Add some noise
        return AccuracyDataPoint(date: date, accuracy: accuracy)
    }.reversed()
    
    AccuracyTrendsChart(
        data: Array(sampleData),
        tintColor: .orange
    )
    .padding(16)
    .groupedBackground()
}

#Preview("Declining Trend") {
    let calendar = Calendar.current
    let today = Date()
    let sampleData = (0..<14).map { dayOffset in
        let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
        // Simulate declining accuracy over time (newer dates have lower accuracy)
        let baseAccuracy = 0.9 - (Double(13 - dayOffset) * 0.02) // Starts at 90%, declines to 64%
        let accuracy = max(0.3, baseAccuracy + Double.random(in: -0.05...0.05)) // Add some noise
        return AccuracyDataPoint(date: date, accuracy: accuracy)
    }.reversed()
    
    AccuracyTrendsChart(
        data: Array(sampleData),
        tintColor: .red
    )
    .padding(16)
    .groupedBackground()
}

#Preview("Consistent Performance") {
    let calendar = Calendar.current
    let today = Date()
    let sampleData: [AccuracyDataPoint] = (0..<21).map { dayOffset in
        let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
        // Simulate consistent accuracy around 75%
        let accuracy = 0.75 + Double.random(in: -0.1...0.1) // 65-85% range
        return AccuracyDataPoint(date: date, accuracy: accuracy)
    }.reversed()
    
    AccuracyTrendsChart(
        data: Array(sampleData),
        tintColor: .teal
    )
    .padding(16)
    .groupedBackground()
} 
