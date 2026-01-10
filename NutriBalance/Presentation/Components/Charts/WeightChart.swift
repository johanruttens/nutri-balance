import SwiftUI
import Charts

/// Line chart for weight progress over time.
struct WeightLineChart: View {
    let entries: [WeightChartData]
    var targetWeight: Double? = nil
    var startWeight: Double? = nil

    private var minWeight: Double {
        let dataMin = entries.map(\.weight).min() ?? 0
        let targetMin = targetWeight ?? dataMin
        return min(dataMin, targetMin) - 2
    }

    private var maxWeight: Double {
        let dataMax = entries.map(\.weight).max() ?? 100
        let startMax = startWeight ?? dataMax
        return max(dataMax, startMax) + 2
    }

    var body: some View {
        Chart {
            // Weight line
            ForEach(entries) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight", entry.weight)
                )
                .foregroundStyle(ColorPalette.primary)
                .lineStyle(StrokeStyle(lineWidth: 2))

                PointMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight", entry.weight)
                )
                .foregroundStyle(ColorPalette.primary)
                .symbolSize(30)
            }

            // Target weight line
            if let target = targetWeight {
                RuleMark(y: .value("Target", target))
                    .foregroundStyle(ColorPalette.success)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .annotation(position: .trailing, alignment: .leading) {
                        Text("Goal")
                            .font(Typography.caption2)
                            .foregroundColor(ColorPalette.success)
                    }
            }

            // Start weight line
            if let start = startWeight {
                RuleMark(y: .value("Start", start))
                    .foregroundStyle(ColorPalette.textTertiary)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
            }
        }
        .chartYScale(domain: minWeight...maxWeight)
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(String(format: "%.0f", doubleValue))
                            .font(Typography.caption2)
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date, format: .dateTime.day().month())
                            .font(Typography.caption2)
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                }
            }
        }
    }
}

struct WeightChartData: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
}

/// Area chart showing weight trend with gradient fill.
struct WeightTrendChart: View {
    let entries: [WeightChartData]
    var targetWeight: Double? = nil

    private var gradient: LinearGradient {
        LinearGradient(
            colors: [ColorPalette.primary.opacity(0.3), ColorPalette.primary.opacity(0.05)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        Chart {
            ForEach(entries) { entry in
                AreaMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight", entry.weight)
                )
                .foregroundStyle(gradient)

                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight", entry.weight)
                )
                .foregroundStyle(ColorPalette.primary)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }

            if let target = targetWeight {
                RuleMark(y: .value("Target", target))
                    .foregroundStyle(ColorPalette.success)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(String(format: "%.0f", doubleValue))
                            .font(Typography.caption2)
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                }
            }
        }
    }
}

/// Mini sparkline for weight in compact views.
struct WeightSparkline: View {
    let entries: [WeightChartData]
    var trendColor: Color = ColorPalette.primary

    var body: some View {
        Chart(entries) { entry in
            LineMark(
                x: .value("Date", entry.date),
                y: .value("Weight", entry.weight)
            )
            .foregroundStyle(trendColor)
            .lineStyle(StrokeStyle(lineWidth: 2))
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

/// Weight statistics summary view.
struct WeightStatsView: View {
    let currentWeight: Double
    let startWeight: Double
    let targetWeight: Double
    let lowestWeight: Double
    let highestWeight: Double
    let averageWeight: Double

    private var totalLost: Double {
        startWeight - currentWeight
    }

    private var remainingToGoal: Double {
        currentWeight - targetWeight
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.lg) {
                WeightStatItem(
                    title: "Current",
                    value: String(format: "%.1f", currentWeight),
                    unit: "kg"
                )

                WeightStatItem(
                    title: "Lost",
                    value: String(format: "%.1f", totalLost),
                    unit: "kg",
                    valueColor: totalLost > 0 ? ColorPalette.success : ColorPalette.error
                )

                WeightStatItem(
                    title: "To Goal",
                    value: String(format: "%.1f", remainingToGoal),
                    unit: "kg",
                    valueColor: remainingToGoal <= 0 ? ColorPalette.success : ColorPalette.primary
                )
            }

            Divider()

            HStack(spacing: AppTheme.Spacing.lg) {
                WeightStatItem(title: "Lowest", value: String(format: "%.1f", lowestWeight), unit: "kg")
                WeightStatItem(title: "Highest", value: String(format: "%.1f", highestWeight), unit: "kg")
                WeightStatItem(title: "Average", value: String(format: "%.1f", averageWeight), unit: "kg")
            }
        }
    }
}

struct WeightStatItem: View {
    let title: String
    let value: String
    let unit: String
    var valueColor: Color = ColorPalette.textPrimary

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text(value)
                .font(Typography.numberSmall)
                .foregroundColor(valueColor)
            + Text(" \(unit)")
                .font(Typography.caption2)
                .foregroundColor(ColorPalette.textSecondary)

            Text(title)
                .font(Typography.caption2)
                .foregroundColor(ColorPalette.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let sampleData: [WeightChartData] = [
        WeightChartData(date: Calendar.current.date(byAdding: .day, value: -30, to: Date())!, weight: 85.0),
        WeightChartData(date: Calendar.current.date(byAdding: .day, value: -25, to: Date())!, weight: 84.5),
        WeightChartData(date: Calendar.current.date(byAdding: .day, value: -20, to: Date())!, weight: 84.2),
        WeightChartData(date: Calendar.current.date(byAdding: .day, value: -15, to: Date())!, weight: 83.8),
        WeightChartData(date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, weight: 83.5),
        WeightChartData(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, weight: 83.2),
        WeightChartData(date: Date(), weight: 83.0)
    ]

    return ScrollView {
        VStack(spacing: 32) {
            WeightLineChart(
                entries: sampleData,
                targetWeight: 80.0,
                startWeight: 85.0
            )
            .frame(height: 200)

            WeightTrendChart(entries: sampleData, targetWeight: 80.0)
                .frame(height: 150)

            WeightSparkline(entries: sampleData, trendColor: ColorPalette.success)
                .frame(height: 40)

            WeightStatsView(
                currentWeight: 83.0,
                startWeight: 85.0,
                targetWeight: 80.0,
                lowestWeight: 83.0,
                highestWeight: 85.0,
                averageWeight: 83.8
            )
        }
        .padding()
    }
}
