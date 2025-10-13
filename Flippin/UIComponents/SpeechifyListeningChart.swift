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
        CustomSectionView(header: Loc.Tts.Analytics.listeningTimeTrend, backgroundStyle: .standard) {
            if usageHistory.isEmpty {
                ContentUnavailableView(
                    Loc.Tts.Analytics.noData,
                    systemImage: "chart.line.uptrend.xyaxis",
                    description: Text(Loc.Tts.Analytics.noDataDescription)
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
                        Text(Loc.Tts.Analytics.totalListening)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatTotalListeningTime())
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(Loc.Tts.Analytics.averagePerMonth)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatAverageListeningTime())
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatMonthYear(_ monthYear: String) -> String {
        let components = monthYear.split(separator: "-")
        guard components.count == 2,
              let monthInt = Int(components[0]),
              let yearInt = Int(components[1]) else {
            return monthYear
        }
        
        var dateComponents = DateComponents()
        dateComponents.year = 2000 + yearInt
        dateComponents.month = monthInt
        
        guard let date = Calendar.current.date(from: dateComponents) else {
            return monthYear
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM ''yy"
        return formatter.string(from: date)
    }
    
    private func formatMinutes(_ minutes: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = minutes < 60 ? [.minute, .second] : [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        
        let timeInterval = TimeInterval(minutes * 60)
        return formatter.string(from: timeInterval) ?? "0"
    }
    
    private func formatTotalListeningTime() -> String {
        let totalMinutes = usageHistory.reduce(0) { $0 + $1.listeningTimeMinutes }
        return formatMinutes(totalMinutes)
    }
    
    private func formatAverageListeningTime() -> String {
        guard !usageHistory.isEmpty else {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute]
            formatter.unitsStyle = .abbreviated
            return formatter.string(from: 0) ?? "0"
        }
        let totalMinutes = usageHistory.reduce(0) { $0 + $1.listeningTimeMinutes }
        let average = totalMinutes / Double(usageHistory.count)
        return formatMinutes(average)
    }
}

#Preview {
    SpeechifyListeningChart(usageHistory: [])
}
