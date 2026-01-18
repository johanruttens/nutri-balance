import SwiftUI

/// Card displaying weight progress summary.
struct WeightProgressCard: View {
    let currentWeight: Double
    let targetWeight: Double
    let startWeight: Double
    let trend: WeightTrend

    private var progress: Double {
        let totalToLose = startWeight - targetWeight
        guard totalToLose > 0 else { return 1.0 }
        let lost = startWeight - currentWeight
        return min(1.0, max(0.0, lost / totalToLose))
    }

    private var remaining: Double {
        currentWeight - targetWeight
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            HStack {
                Text("Weight Progress")
                    .font(Typography.headline)
                    .foregroundColor(ColorPalette.textPrimary)

                Spacer()

                // Trend indicator
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: trend.iconName)
                        .font(.system(size: 12))
                    Text(trend.displayName)
                        .font(Typography.caption1)
                }
                .foregroundColor(trendColor)
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.xs)
                .background(trendColor.opacity(0.15))
                .cornerRadius(AppTheme.CornerRadius.small)
            }

            HStack(spacing: AppTheme.Spacing.xl) {
                // Current weight
                VStack(spacing: AppTheme.Spacing.xs) {
                    Text(String(format: "%.1f", currentWeight))
                        .font(Typography.numberLarge)
                        .foregroundColor(ColorPalette.textPrimary)
                    Text("kg current")
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.textSecondary)
                }

                Spacer()

                // Progress indicator
                CircularProgressView(progress: progress)
                    .frame(width: 80, height: 80)

                Spacer()

                // Target weight
                VStack(spacing: AppTheme.Spacing.xs) {
                    Text(String(format: "%.1f", targetWeight))
                        .font(Typography.numberLarge)
                        .foregroundColor(ColorPalette.primary)
                    Text("kg target")
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.textSecondary)
                }
            }

            // Remaining
            if remaining > 0 {
                HStack {
                    Text("\(String(format: "%.1f", remaining)) kg to go")
                        .font(Typography.callout)
                        .foregroundColor(ColorPalette.textSecondary)

                    Spacer()

                    Text("\(Int(progress * 100))% complete")
                        .font(Typography.callout)
                        .foregroundColor(ColorPalette.primary)
                }
            } else {
                Text("Goal Reached!")
                    .font(Typography.headline)
                    .foregroundColor(ColorPalette.success)
                    .frame(maxWidth: .infinity)
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

    private var trendColor: Color {
        switch trend {
        case .losing:
            return ColorPalette.success
        case .stable:
            return ColorPalette.warning
        case .gaining:
            return ColorPalette.error
        }
    }
}

/// Circular progress view for weight goal.
struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(ColorPalette.divider, lineWidth: 8)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(ColorPalette.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            Text("\(Int(progress * 100))%")
                .font(Typography.numberSmall)
                .foregroundColor(ColorPalette.textPrimary)
        }
    }
}

/// Single weight entry row.
struct WeightEntryRow: View {
    let entry: WeightEntry
    let previousWeight: Double?

    private var change: Double? {
        guard let previous = previousWeight else { return nil }
        return entry.weight - previous
    }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Date
            VStack(alignment: .leading, spacing: 2) {
                Text(LDate(entry.date, style: .medium))
                    .font(Typography.body)
                    .foregroundColor(ColorPalette.textPrimary)

                if let notes = entry.notes {
                    Text(notes)
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.textTertiary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Weight
            Text(String(format: "%.1f kg", entry.weight))
                .font(Typography.numberSmall)
                .foregroundColor(ColorPalette.textPrimary)

            // Change indicator
            if let change = change {
                HStack(spacing: 2) {
                    Image(systemName: change < 0 ? "arrow.down" : change > 0 ? "arrow.up" : "minus")
                        .font(.system(size: 10, weight: .bold))
                    Text(String(format: "%.1f", abs(change)))
                        .font(Typography.caption1)
                }
                .foregroundColor(change < 0 ? ColorPalette.success : change > 0 ? ColorPalette.error : ColorPalette.textSecondary)
                .frame(width: 50)
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
    }
}

/// Quick weight log card.
struct QuickWeightLogCard: View {
    @Binding var weight: Double
    let onLog: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text("Log Today's Weight")
                .font(Typography.headline)
                .foregroundColor(ColorPalette.textPrimary)

            HStack {
                Button(action: { weight = max(30, weight - 0.1) }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(ColorPalette.textSecondary)
                }

                Text(String(format: "%.1f", weight))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(ColorPalette.textPrimary)
                    .frame(width: 120)

                Button(action: { weight = min(300, weight + 0.1) }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(ColorPalette.textSecondary)
                }
            }

            Text("kg")
                .font(Typography.body)
                .foregroundColor(ColorPalette.textSecondary)

            PrimaryButton(title: "Log Weight", action: onLog)
        }
        .padding(AppTheme.Spacing.lg)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            WeightProgressCard(
                currentWeight: 83.5,
                targetWeight: 81.0,
                startWeight: 85.0,
                trend: .losing
            )

            WeightEntryRow(
                entry: WeightEntry.mock,
                previousWeight: 85.5
            )

            QuickWeightLogCard(weight: .constant(83.5), onLog: {})
        }
        .padding()
    }
    .background(ColorPalette.backgroundSecondary)
}
