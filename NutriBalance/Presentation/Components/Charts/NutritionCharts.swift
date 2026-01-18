import SwiftUI
import Charts

/// Bar chart for daily calorie intake.
struct CalorieBarChart: View {
    let data: [DailyCalorieData]
    var goal: Int = 0

    var body: some View {
        Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value("Day", item.dayLabel),
                    y: .value("Calories", item.calories)
                )
                .foregroundStyle(item.calories > goal && goal > 0 ? ColorPalette.error : ColorPalette.primary)
                .cornerRadius(4)
            }

            if goal > 0 {
                RuleMark(y: .value("Goal", goal))
                    .foregroundStyle(ColorPalette.textSecondary)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Goal")
                            .font(Typography.caption2)
                            .foregroundColor(ColorPalette.textSecondary)
                    }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)")
                            .font(Typography.caption2)
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let label = value.as(String.self) {
                        Text(label)
                            .font(Typography.caption2)
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                }
            }
        }
    }
}

struct DailyCalorieData: Identifiable {
    let id = UUID()
    let date: Date
    let dayLabel: String
    let calories: Int
}

/// Stacked bar chart for macro breakdown.
struct MacroStackedChart: View {
    let data: [DailyMacroData]

    var body: some View {
        Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value("Day", item.dayLabel),
                    y: .value("Protein", item.protein)
                )
                .foregroundStyle(by: .value("Macro", "Protein"))

                BarMark(
                    x: .value("Day", item.dayLabel),
                    y: .value("Carbs", item.carbs)
                )
                .foregroundStyle(by: .value("Macro", "Carbs"))

                BarMark(
                    x: .value("Day", item.dayLabel),
                    y: .value("Fat", item.fat)
                )
                .foregroundStyle(by: .value("Macro", "Fat"))
            }
        }
        .chartForegroundStyleScale([
            "Protein": Color.red.opacity(0.8),
            "Carbs": Color.orange.opacity(0.8),
            "Fat": Color.yellow.opacity(0.8)
        ])
        .chartLegend(position: .bottom, alignment: .center)
    }
}

struct DailyMacroData: Identifiable {
    let id = UUID()
    let date: Date
    let dayLabel: String
    let protein: Double
    let carbs: Double
    let fat: Double
}

/// Bar chart for macro distribution (iOS 16 compatible).
struct MacroPieChart: View {
    let protein: Double
    let carbs: Double
    let fat: Double

    private var total: Double {
        protein + carbs + fat
    }

    private var data: [MacroSlice] {
        guard total > 0 else { return [] }
        return [
            MacroSlice(name: "Protein", value: protein, color: Color.red.opacity(0.8)),
            MacroSlice(name: "Carbs", value: carbs, color: Color.orange.opacity(0.8)),
            MacroSlice(name: "Fat", value: fat, color: Color.yellow.opacity(0.8))
        ]
    }

    var body: some View {
        Chart(data) { slice in
            BarMark(
                x: .value("Value", slice.value),
                y: .value("Macro", slice.name)
            )
            .foregroundStyle(slice.color)
            .cornerRadius(4)
        }
        .chartXAxis(.hidden)
    }
}

struct MacroSlice: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
    let color: Color
}

/// Horizontal bar for comparing actual vs goal.
struct ComparisonBar: View {
    let title: String
    let actual: Double
    let goal: Double
    var unit: String = "g"
    var color: Color = ColorPalette.primary

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return actual / goal
    }

    private var isOver: Bool {
        actual > goal && goal > 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            HStack {
                Text(title)
                    .font(Typography.caption1)
                    .foregroundColor(ColorPalette.textSecondary)

                Spacer()

                Text("\(Int(actual)) / \(Int(goal)) \(unit)")
                    .font(Typography.caption1)
                    .foregroundColor(isOver ? ColorPalette.error : ColorPalette.textPrimary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ColorPalette.divider)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(isOver ? ColorPalette.error : color)
                        .frame(width: geometry.size.width * min(progress, 1.0))

                    if goal > 0 && !isOver {
                        // Goal marker
                        Rectangle()
                            .fill(ColorPalette.textSecondary)
                            .frame(width: 2)
                            .offset(x: geometry.size.width - 2)
                    }
                }
            }
            .frame(height: 8)
        }
    }
}

/// Nutrition summary bars group.
struct NutritionBarsView: View {
    let calories: (actual: Int, goal: Int)
    let protein: (actual: Double, goal: Double)
    let carbs: (actual: Double, goal: Double)
    let fat: (actual: Double, goal: Double)

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ComparisonBar(
                title: "Calories",
                actual: Double(calories.actual),
                goal: Double(calories.goal),
                unit: "kcal",
                color: ColorPalette.primary
            )

            ComparisonBar(
                title: "Protein",
                actual: protein.actual,
                goal: protein.goal,
                unit: "g",
                color: Color.red.opacity(0.8)
            )

            ComparisonBar(
                title: "Carbs",
                actual: carbs.actual,
                goal: carbs.goal,
                unit: "g",
                color: Color.orange.opacity(0.8)
            )

            ComparisonBar(
                title: "Fat",
                actual: fat.actual,
                goal: fat.goal,
                unit: "g",
                color: Color.yellow.opacity(0.8)
            )
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 32) {
            CalorieBarChart(
                data: [
                    DailyCalorieData(date: Date(), dayLabel: "Mon", calories: 1650),
                    DailyCalorieData(date: Date(), dayLabel: "Tue", calories: 1800),
                    DailyCalorieData(date: Date(), dayLabel: "Wed", calories: 2100),
                    DailyCalorieData(date: Date(), dayLabel: "Thu", calories: 1750),
                    DailyCalorieData(date: Date(), dayLabel: "Fri", calories: 1900),
                    DailyCalorieData(date: Date(), dayLabel: "Sat", calories: 2200),
                    DailyCalorieData(date: Date(), dayLabel: "Sun", calories: 1850)
                ],
                goal: 1800
            )
            .frame(height: 200)

            MacroPieChart(protein: 120, carbs: 200, fat: 80)
                .frame(width: 150, height: 150)

            NutritionBarsView(
                calories: (1500, 1800),
                protein: (85, 100),
                carbs: (180, 200),
                fat: (55, 60)
            )
        }
        .padding()
    }
}
