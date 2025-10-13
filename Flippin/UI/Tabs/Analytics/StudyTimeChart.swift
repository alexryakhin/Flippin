//
//  StudyTimeChart.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/28/25.
//

import SwiftUI
import Charts

struct StudyTimeChart: View {
    let data: [(date: Date, studyTime: TimeInterval, cardsStudied: Int)]
    let timeRange: AnalyticsDashboard.TimeRange
    let tintColor: Color
    
    var body: some View {
        if data.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text(Loc.Analytics.noStudyDataAvailable)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Chart(data, id: \.date) { dataPoint in
                BarMark(
                    x: .value("Date", dataPoint.date, unit: .day),
                    y: .value("Study Time", dataPoint.studyTime / 60) // Convert to minutes
                )
                .foregroundStyle(tintColor)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: strideBy)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: axisLabelFormat)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let studyTime = value.as(Double.self) {
                            Text("\(Int(studyTime))m")
                        }
                    }
                }
            }
            .frame(height: 200)
        }
    }
    
    private var strideBy: Calendar.Component {
        switch timeRange {
        case .week:
            return .day
        case .month:
            return .weekOfYear
        case .year:
            return .month
        case .all:
            return .year
        }
    }
    
    private var axisLabelFormat: Date.FormatStyle {
        switch timeRange {
        case .week:
            return .dateTime.weekday(.abbreviated)
        case .month:
            return .dateTime.month().day()
        case .year:
            return .dateTime.month(.abbreviated)
        case .all:
            return .dateTime.year()
        }
    }
}

// MARK: - Preview Data

extension StudyTimeChart {
    static func generatePreviewData(for timeRange: AnalyticsDashboard.TimeRange) -> [(date: Date, studyTime: TimeInterval, cardsStudied: Int)] {
        let calendar = Calendar.current
        let today = Date()
        
        let numberOfDays: Int
        switch timeRange {
        case .week:
            numberOfDays = 7
        case .month:
            numberOfDays = 30
        case .year:
            numberOfDays = 365
        case .all:
            numberOfDays = Int.max
        }
        
        var data: [(date: Date, studyTime: TimeInterval, cardsStudied: Int)] = []
        
        for i in 0..<numberOfDays {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            
            // Generate realistic study data
            let hasStudied = Bool.random()
            let studyTime: TimeInterval = hasStudied ? Double.random(in: 300...3600) : 0 // 5-60 minutes
            let cardsStudied = hasStudied ? Int.random(in: 5...25) : 0
            
            data.append((date: date, studyTime: studyTime, cardsStudied: cardsStudied))
        }
        
        return data.reversed() // Sort by date ascending
    }
    
    static func generateEmptyData() -> [(date: Date, studyTime: TimeInterval, cardsStudied: Int)] {
        return []
    }
    
    static func generateConsistentData() -> [(date: Date, studyTime: TimeInterval, cardsStudied: Int)] {
        let calendar = Calendar.current
        let today = Date()
        
        var data: [(date: Date, studyTime: TimeInterval, cardsStudied: Int)] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let studyTime: TimeInterval = 1800 // 30 minutes daily
            let cardsStudied = 15
            
            data.append((date: date, studyTime: studyTime, cardsStudied: cardsStudied))
        }
        
        return data.reversed()
    }
    
    static func generateVariableData() -> [(date: Date, studyTime: TimeInterval, cardsStudied: Int)] {
        let calendar = Calendar.current
        let today = Date()
        
        var data: [(date: Date, studyTime: TimeInterval, cardsStudied: Int)] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let studyTime: TimeInterval = Double.random(in: 600...3600) // 10-60 minutes
            let cardsStudied = Int.random(in: 8...30)
            
            data.append((date: date, studyTime: studyTime, cardsStudied: cardsStudied))
        }
        
        return data.reversed()
    }
}

#Preview("Study Time Chart - Week View") {
    VStack(spacing: 20) {
        StudyTimeChart(
            data: StudyTimeChart.generatePreviewData(for: .week),
            timeRange: .week,
            tintColor: .blue
        )
        .padding(16)

        StudyTimeChart(
            data: StudyTimeChart.generateConsistentData(),
            timeRange: .week,
            tintColor: .green
        )
        .padding(16)

        StudyTimeChart(
            data: StudyTimeChart.generateVariableData(),
            timeRange: .week,
            tintColor: .purple
        )
        .padding(16)
    }
}

#Preview("Study Time Chart - Empty State") {
    StudyTimeChart(
        data: StudyTimeChart.generateEmptyData(),
        timeRange: .week,
        tintColor: .blue
    )
    .padding(16)
}

#Preview("Study Time Chart - Month View") {
    StudyTimeChart(
        data: StudyTimeChart.generatePreviewData(for: .month),
        timeRange: .month,
        tintColor: .orange
    )
    .padding(16)
}

#Preview("Study Time Chart - Year View") {
    StudyTimeChart(
        data: StudyTimeChart.generatePreviewData(for: .year),
        timeRange: .year,
        tintColor: .red
    )
    .padding(16)
}

#Preview {
    AnalyticsDashboard.ContentView()
}
