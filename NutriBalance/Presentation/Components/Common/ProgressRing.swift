import SwiftUI

/// Customizable progress ring component.
struct ProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 12
    var backgroundColor: Color = ColorPalette.divider
    var foregroundColor: Color = ColorPalette.primary
    var showPercentage: Bool = false

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            // Progress arc
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    foregroundColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            // Percentage text
            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(Typography.numberSmall)
                    .foregroundColor(ColorPalette.textPrimary)
            }
        }
    }
}

/// Multi-segment progress ring (e.g., for macros).
struct MultiProgressRing: View {
    let segments: [Segment]
    var lineWidth: CGFloat = 12
    var gap: Double = 0.02

    struct Segment: Identifiable {
        let id = UUID()
        let value: Double
        let color: Color
    }

    private var total: Double {
        segments.reduce(0) { $0 + $1.value }
    }

    var body: some View {
        ZStack {
            // Background
            Circle()
                .stroke(ColorPalette.divider, lineWidth: lineWidth)

            // Segments
            ForEach(Array(segments.enumerated()), id: \.element.id) { index, segment in
                Circle()
                    .trim(from: startAngle(for: index), to: endAngle(for: index))
                    .stroke(
                        segment.color,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
        }
    }

    private func startAngle(for index: Int) -> Double {
        guard total > 0 else { return 0 }
        let preceding = segments.prefix(index).reduce(0) { $0 + $1.value }
        return (preceding / total) + (Double(index) * gap)
    }

    private func endAngle(for index: Int) -> Double {
        guard total > 0 else { return 0 }
        let including = segments.prefix(index + 1).reduce(0) { $0 + $1.value }
        return (including / total) - gap
    }
}

/// Horizontal progress bar.
struct ProgressBar: View {
    let progress: Double
    var height: CGFloat = 8
    var backgroundColor: Color = ColorPalette.divider
    var foregroundColor: Color = ColorPalette.primary
    var cornerRadius: CGFloat = 4

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)

                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(foregroundColor)
                    .frame(width: geometry.size.width * min(progress, 1.0))
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: height)
    }
}

/// Animated streak counter display.
struct StreakDisplay: View {
    let count: Int
    var label: String = "day streak"

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "flame.fill")
                .font(.system(size: 24))
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(count)")
                    .font(Typography.numberMedium)
                    .foregroundColor(ColorPalette.textPrimary)

                Text(label)
                    .font(Typography.caption1)
                    .foregroundColor(ColorPalette.textSecondary)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
}

/// Goal completion indicator.
struct GoalIndicator: View {
    let title: String
    let current: Double
    let goal: Double
    var unit: String = ""
    var color: Color = ColorPalette.primary

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return current / goal
    }

    private var isComplete: Bool {
        progress >= 1.0
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Progress ring
            ZStack {
                ProgressRing(
                    progress: progress,
                    lineWidth: 6,
                    foregroundColor: color
                )
                .frame(width: 50, height: 50)

                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(color)
                }
            }

            // Label
            Text(title)
                .font(Typography.caption1)
                .foregroundColor(ColorPalette.textSecondary)

            // Value
            Text("\(Int(current))\(unit.isEmpty ? "" : " \(unit)")")
                .font(Typography.caption2)
                .foregroundColor(ColorPalette.textTertiary)
        }
    }
}

#Preview {
    VStack(spacing: 32) {
        HStack(spacing: 20) {
            ProgressRing(progress: 0.65, showPercentage: true)
                .frame(width: 80, height: 80)

            ProgressRing(progress: 1.0, foregroundColor: ColorPalette.success)
                .frame(width: 80, height: 80)

            ProgressRing(progress: 0.3, lineWidth: 8, foregroundColor: ColorPalette.water)
                .frame(width: 60, height: 60)
        }

        MultiProgressRing(segments: [
            .init(value: 30, color: .red),
            .init(value: 40, color: .orange),
            .init(value: 30, color: .yellow)
        ])
        .frame(width: 100, height: 100)

        VStack(spacing: 8) {
            ProgressBar(progress: 0.75)
            ProgressBar(progress: 0.45, foregroundColor: ColorPalette.water)
            ProgressBar(progress: 1.2, foregroundColor: ColorPalette.error)
        }

        StreakDisplay(count: 7)

        HStack(spacing: 16) {
            GoalIndicator(title: "Calories", current: 1500, goal: 2000, color: ColorPalette.primary)
            GoalIndicator(title: "Protein", current: 120, goal: 100, unit: "g", color: .red)
            GoalIndicator(title: "Water", current: 1800, goal: 2500, unit: "ml", color: ColorPalette.water)
        }
    }
    .padding()
}
