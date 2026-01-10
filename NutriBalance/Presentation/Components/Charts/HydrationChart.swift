import SwiftUI
import Charts

/// Ring chart for daily hydration progress.
struct HydrationRingChart: View {
    let intake: Double // in ml
    let goal: Double // in ml
    var size: CGFloat = 120

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(intake / goal, 1.0)
    }

    private var isComplete: Bool {
        intake >= goal
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(ColorPalette.water.opacity(0.2), lineWidth: size * 0.12)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    ColorPalette.water,
                    style: StrokeStyle(lineWidth: size * 0.12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            // Center content
            VStack(spacing: 2) {
                if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: size * 0.25))
                        .foregroundColor(ColorPalette.success)
                } else {
                    Image(systemName: "drop.fill")
                        .font(.system(size: size * 0.2))
                        .foregroundColor(ColorPalette.water)
                }

                Text("\(Int(intake))")
                    .font(.system(size: size * 0.15, weight: .bold, design: .rounded))
                    .foregroundColor(ColorPalette.textPrimary)

                Text("/ \(Int(goal))ml")
                    .font(.system(size: size * 0.08))
                    .foregroundColor(ColorPalette.textSecondary)
            }
        }
        .frame(width: size, height: size)
    }
}

/// Bar chart for weekly hydration.
struct HydrationBarChart: View {
    let data: [DailyHydrationData]
    var goal: Double = 2000

    var body: some View {
        Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value("Day", item.dayLabel),
                    y: .value("Intake", item.intake)
                )
                .foregroundStyle(item.intake >= goal ? ColorPalette.water : ColorPalette.water.opacity(0.6))
                .cornerRadius(4)
            }

            if goal > 0 {
                RuleMark(y: .value("Goal", goal))
                    .foregroundStyle(ColorPalette.water.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue / 1000)L")
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

struct DailyHydrationData: Identifiable {
    let id = UUID()
    let date: Date
    let dayLabel: String
    let intake: Double // in ml
}

/// Water glass visualization.
struct WaterGlassView: View {
    let fillLevel: Double // 0.0 to 1.0
    var size: CGFloat = 60

    var body: some View {
        ZStack(alignment: .bottom) {
            // Glass outline
            RoundedRectangle(cornerRadius: 4)
                .stroke(ColorPalette.water.opacity(0.5), lineWidth: 2)
                .frame(width: size * 0.6, height: size)

            // Water fill
            RoundedRectangle(cornerRadius: 2)
                .fill(ColorPalette.water.opacity(0.7))
                .frame(width: size * 0.5, height: size * 0.9 * min(fillLevel, 1.0))
                .padding(.bottom, 2)
        }
    }
}

/// Drink type breakdown chart.
struct DrinkTypeChart: View {
    let data: [DrinkTypeData]

    var body: some View {
        Chart(data) { item in
            SectorMark(
                angle: .value("Amount", item.amount),
                innerRadius: .ratio(0.5),
                angularInset: 2
            )
            .foregroundStyle(item.color)
            .cornerRadius(4)
        }
    }
}

struct DrinkTypeData: Identifiable {
    let id = UUID()
    let type: String
    let amount: Double
    let color: Color
}

/// Quick add drink buttons.
struct QuickDrinkButtons: View {
    let onAdd: (Double) -> Void

    private let sizes: [(label: String, amount: Double)] = [
        ("200ml", 200),
        ("250ml", 250),
        ("500ml", 500),
        ("750ml", 750)
    ]

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            ForEach(sizes, id: \.amount) { size in
                Button(action: { onAdd(size.amount) }) {
                    VStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 20))
                            .foregroundColor(ColorPalette.water)

                        Text(size.label)
                            .font(Typography.caption1)
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(ColorPalette.water.opacity(0.1))
                    .cornerRadius(AppTheme.CornerRadius.medium)
                }
            }
        }
    }
}

/// Hydration timeline view.
struct HydrationTimelineView: View {
    let entries: [HydrationTimelineEntry]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(entries) { entry in
                HStack(spacing: AppTheme.Spacing.md) {
                    // Time
                    Text(entry.time, style: .time)
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.textSecondary)
                        .frame(width: 60, alignment: .leading)

                    // Dot and line
                    VStack(spacing: 0) {
                        Circle()
                            .fill(ColorPalette.water)
                            .frame(width: 10, height: 10)

                        if entry.id != entries.last?.id {
                            Rectangle()
                                .fill(ColorPalette.water.opacity(0.3))
                                .frame(width: 2, height: 30)
                        }
                    }

                    // Content
                    HStack {
                        Text(entry.drinkType)
                            .font(Typography.body)
                            .foregroundColor(ColorPalette.textPrimary)

                        Spacer()

                        Text("\(Int(entry.amount))ml")
                            .font(Typography.callout)
                            .foregroundColor(ColorPalette.water)
                    }
                }
            }
        }
    }
}

struct HydrationTimelineEntry: Identifiable {
    let id = UUID()
    let time: Date
    let drinkType: String
    let amount: Double
}

#Preview {
    ScrollView {
        VStack(spacing: 32) {
            HStack(spacing: 20) {
                HydrationRingChart(intake: 1500, goal: 2500, size: 100)
                HydrationRingChart(intake: 2500, goal: 2500, size: 100)
            }

            HydrationBarChart(
                data: [
                    DailyHydrationData(date: Date(), dayLabel: "Mon", intake: 2200),
                    DailyHydrationData(date: Date(), dayLabel: "Tue", intake: 1800),
                    DailyHydrationData(date: Date(), dayLabel: "Wed", intake: 2500),
                    DailyHydrationData(date: Date(), dayLabel: "Thu", intake: 2100),
                    DailyHydrationData(date: Date(), dayLabel: "Fri", intake: 1900),
                    DailyHydrationData(date: Date(), dayLabel: "Sat", intake: 2300),
                    DailyHydrationData(date: Date(), dayLabel: "Sun", intake: 2000)
                ],
                goal: 2000
            )
            .frame(height: 200)

            HStack(spacing: 16) {
                WaterGlassView(fillLevel: 0.3)
                WaterGlassView(fillLevel: 0.6)
                WaterGlassView(fillLevel: 1.0)
            }

            QuickDrinkButtons { amount in
                print("Add \(amount)ml")
            }

            HydrationTimelineView(entries: [
                HydrationTimelineEntry(time: Date(), drinkType: "Water", amount: 250),
                HydrationTimelineEntry(time: Date().addingTimeInterval(-3600), drinkType: "Coffee", amount: 200),
                HydrationTimelineEntry(time: Date().addingTimeInterval(-7200), drinkType: "Water", amount: 500)
            ])
        }
        .padding()
    }
}
