import SwiftUI

/// Card displaying daily calorie summary with progress ring.
struct CalorieSummaryCard: View {
    let consumed: Int
    let goal: Int
    let protein: Double
    let carbs: Double
    let fat: Double

    private var remaining: Int {
        max(0, goal - consumed)
    }

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(1.0, Double(consumed) / Double(goal))
    }

    private var isOverGoal: Bool {
        consumed > goal
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            HStack(spacing: AppTheme.Spacing.xl) {
                // Progress ring
                CalorieProgressRing(
                    progress: progress,
                    consumed: consumed,
                    goal: goal
                )
                .frame(width: 120, height: 120)

                // Stats
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    StatRow(
                        title: isOverGoal ? "Over" : "Remaining",
                        value: isOverGoal ? "\(consumed - goal)" : "\(remaining)",
                        unit: "kcal",
                        color: isOverGoal ? ColorPalette.error : ColorPalette.primary
                    )

                    StatRow(title: "Goal", value: "\(goal)", unit: "kcal", color: ColorPalette.textSecondary)
                }
            }

            // Macro breakdown
            HStack(spacing: AppTheme.Spacing.lg) {
                MacroIndicator(title: "Protein", value: protein, color: Color.red.opacity(0.8))
                MacroIndicator(title: "Carbs", value: carbs, color: Color.orange.opacity(0.8))
                MacroIndicator(title: "Fat", value: fat, color: Color.yellow.opacity(0.8))
            }
        }
        .padding(AppTheme.Spacing.standard)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
        .shadow(
            color: ColorPalette.shadow,
            radius: AppTheme.Shadow.card.radius,
            x: AppTheme.Shadow.card.x,
            y: AppTheme.Shadow.card.y
        )
    }
}

/// Progress ring for calorie display.
struct CalorieProgressRing: View {
    let progress: Double
    let consumed: Int
    let goal: Int

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(ColorPalette.divider, lineWidth: 12)

            // Progress ring
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    progress > 1.0 ? ColorPalette.error : ColorPalette.primary,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            // Center text
            VStack(spacing: 2) {
                Text("\(consumed)")
                    .font(Typography.numberMedium)
                    .foregroundColor(ColorPalette.textPrimary)

                Text("kcal")
                    .font(Typography.caption1)
                    .foregroundColor(ColorPalette.textSecondary)
            }
        }
    }
}

/// Single stat row for summary cards.
struct StatRow: View {
    let title: String
    let value: String
    let unit: String
    var color: Color = ColorPalette.textPrimary

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Text(title)
                .font(Typography.caption1)
                .foregroundColor(ColorPalette.textSecondary)

            Spacer()

            Text(value)
                .font(Typography.numberSmall)
                .foregroundColor(color)
            + Text(" \(unit)")
                .font(Typography.caption1)
                .foregroundColor(ColorPalette.textSecondary)
        }
    }
}

/// Macro nutrient indicator.
struct MacroIndicator: View {
    let title: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text(String(format: "%.0f", value))
                .font(Typography.numberSmall)
                .foregroundColor(ColorPalette.textPrimary)
            + Text("g")
                .font(Typography.caption2)
                .foregroundColor(ColorPalette.textSecondary)

            Text(title)
                .font(Typography.caption2)
                .foregroundColor(ColorPalette.textSecondary)

            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(height: 4)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Hydration summary card.
struct HydrationSummaryCard: View {
    let intake: Double // in ml
    let goal: Double // in ml

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return intake / goal
    }

    private var remaining: Double {
        max(0, goal - intake)
    }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Water drop icon with progress
            ZStack {
                Circle()
                    .fill(ColorPalette.water.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: progress >= 1.0 ? "drop.fill" : "drop.halffull")
                    .font(.system(size: 28))
                    .foregroundColor(ColorPalette.water)
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("Hydration")
                    .font(Typography.headline)
                    .foregroundColor(ColorPalette.textPrimary)

                if progress >= 1.0 {
                    Text("Goal completed!")
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.success)
                } else {
                    Text("\(Int(remaining))ml remaining")
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.textSecondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                Text("\(Int(intake))")
                    .font(Typography.numberSmall)
                    .foregroundColor(ColorPalette.textPrimary)
                + Text(" / \(Int(goal))ml")
                    .font(Typography.caption1)
                    .foregroundColor(ColorPalette.textSecondary)

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(ColorPalette.divider)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(ColorPalette.water)
                            .frame(width: geometry.size.width * min(progress, 1.0))
                    }
                }
                .frame(width: 80, height: 8)
            }
        }
        .padding(AppTheme.Spacing.standard)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
        .shadow(
            color: ColorPalette.shadow,
            radius: AppTheme.Shadow.card.radius,
            x: AppTheme.Shadow.card.x,
            y: AppTheme.Shadow.card.y
        )
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            CalorieSummaryCard(
                consumed: 1250,
                goal: 1800,
                protein: 65,
                carbs: 120,
                fat: 45
            )

            HydrationSummaryCard(intake: 1500, goal: 2500)
            HydrationSummaryCard(intake: 2600, goal: 2500)
        }
        .padding()
    }
    .background(ColorPalette.backgroundSecondary)
}
