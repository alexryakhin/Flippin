//
//  SpeechifyListeningChart.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import SwiftUI
import Charts

struct SpeechifyListeningChart: View {
    let usageHistory: [SpeechifyUsage]
    @StateObject private var colorManager = ColorManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Listening Time Trend")
                .font(.headline)
                .foregroundStyle(.primary)
            
            if usageHistory.isEmpty {
                ContentUnavailableView(
                    "No Data",
                    systemImage: "chart.line.uptrend.xyaxis",
                    description: Text("Start using Speechify TTS to see your listening statistics")
                )
            } else {
                Chart(usageHistory, id: \.monthYear) { usage in
                    LineMark(
                        x: .value("Month", usage.monthYear),
                        y: .value("Minutes", usage.listeningTimeMinutes)
                    )
                    .foregroundStyle(colorManager.tintColor)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    AreaMark(
                        x: .value("Month", usage.monthYear),
                        y: .value("Minutes", usage.listeningTimeMinutes)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                colorManager.tintColor.opacity(0.3),
                                colorManager.tintColor.opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    PointMark(
                        x: .value("Month", usage.monthYear),
                        y: .value("Minutes", usage.listeningTimeMinutes)
                    )
                    .foregroundStyle(colorManager.tintColor)
                    .symbolSize(50)
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let monthYear = value.as(String.self) {
                                Text(formatMonthYear(monthYear))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let minutes = value.as(Double.self) {
                                Text(formatMinutes(minutes))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .frame(height: 200)
                
                // Summary Stats
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Listening")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatTotalListeningTime())
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Average/Month")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatAverageListeningTime())
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Helper Methods
    
    private func formatMonthYear(_ monthYear: String) -> String {
        let components = monthYear.split(separator: "-")
        if components.count == 2 {
            let month = String(components[0])
            let year = String(components[1])
            return "\(month.prefix(3)) '\(year.suffix(2))"
        }
        return monthYear
    }
    
    private func formatMinutes(_ minutes: Double) -> String {
        if minutes < 1 {
            return "\(Int(minutes * 60))s"
        } else if minutes < 60 {
            return "\(Int(minutes))m"
        } else {
            let hours = Int(minutes / 60)
            return "\(hours)h"
        }
    }
    
    private func formatTotalListeningTime() -> String {
        let totalMinutes = usageHistory.reduce(0) { $0 + $1.listeningTimeMinutes }
        return formatMinutes(totalMinutes)
    }
    
    private func formatAverageListeningTime() -> String {
        guard !usageHistory.isEmpty else { return "0m" }
        let totalMinutes = usageHistory.reduce(0) { $0 + $1.listeningTimeMinutes }
        let average = totalMinutes / Double(usageHistory.count)
        return formatMinutes(average)
    }
}

#Preview {
    SpeechifyListeningChart(usageHistory: [])
}
