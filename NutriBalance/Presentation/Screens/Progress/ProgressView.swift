import SwiftUI

/// Main progress/weight tracking view.
struct WeightProgressView: View {
    @StateObject private var viewModel: ProgressViewModel
    @State private var showLogWeight = false
    @State private var selectedTimeRange: TimeRange = .month

    init(container: DependencyContainer) {
        _viewModel = StateObject(wrappedValue: ProgressViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Current weight card
                    CurrentWeightCard(
                        currentWeight: viewModel.currentWeight,
                        targetWeight: viewModel.targetWeight,
                        startWeight: viewModel.startWeight,
                        trend: viewModel.weightTrend,
                        onLogTap: { showLogWeight = true }
                    )

                    // Time range selector
                    TimeRangePicker(selection: $selectedTimeRange) {
                        Task { await viewModel.loadHistory(for: selectedTimeRange) }
                    }

                    // Weight chart
                    WeightChartCard(
                        entries: viewModel.chartData,
                        targetWeight: viewModel.targetWeight,
                        startWeight: viewModel.startWeight
                    )

                    // Statistics
                    WeightStatisticsCard(
                        stats: viewModel.statistics
                    )

                    // BMI card
                    BMICard(
                        bmi: viewModel.bmi,
                        height: viewModel.userHeight
                    )

                    // History list
                    WeightHistorySection(
                        entries: viewModel.recentEntries,
                        onDelete: { entry in
                            Task { await viewModel.deleteEntry(entry) }
                        }
                    )
                }
                .padding(AppTheme.Spacing.standard)
            }
            .background(ColorPalette.backgroundSecondary)
            .navigationTitle(L("progress.title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showLogWeight = true }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel(L("accessibility.addButton"))
                }
            }
            .refreshable {
                await viewModel.loadData()
            }
            .task {
                await viewModel.loadData()
            }
            .sheet(isPresented: $showLogWeight) {
                LogWeightView(container: viewModel.container) {
                    Task { await viewModel.loadData() }
                }
            }
        }
    }
}

/// Time range options.
enum TimeRange: String, CaseIterable, Identifiable {
    case week
    case month
    case threeMonths
    case year

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .week: return L("period.week")
        case .month: return L("period.month")
        case .threeMonths: return L("period.3months")
        case .year: return L("period.year")
        }
    }

    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        case .year: return 365
        }
    }
}

/// Time range picker.
struct TimeRangePicker: View {
    @Binding var selection: TimeRange
    let onChange: () -> Void

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            ForEach(TimeRange.allCases) { range in
                Button(action: {
                    selection = range
                    onChange()
                }) {
                    Text(range.displayName)
                        .font(Typography.caption1)
                        .foregroundColor(selection == range ? .white : ColorPalette.textSecondary)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(selection == range ? ColorPalette.primary : ColorPalette.inputBackground)
                        .cornerRadius(AppTheme.CornerRadius.small)
                }
            }
        }
    }
}

/// Current weight display card.
struct CurrentWeightCard: View {
    let currentWeight: Double
    let targetWeight: Double
    let startWeight: Double
    let trend: WeightTrend
    let onLogTap: () -> Void

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
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(L("progress.currentWeight"))
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.textSecondary)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f", currentWeight))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(ColorPalette.textPrimary)

                        Text(L("common.kg"))
                            .font(Typography.title3)
                            .foregroundColor(ColorPalette.textSecondary)
                    }

                    // Trend indicator
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: trend.iconName)
                        Text(trend.displayName)
                    }
                    .font(Typography.caption1)
                    .foregroundColor(trend.color)
                }

                Spacer()

                // Progress ring
                ZStack {
                    Circle()
                        .stroke(ColorPalette.divider, lineWidth: 10)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(ColorPalette.primary, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(Int(progress * 100))%")
                            .font(Typography.numberSmall)
                            .foregroundColor(ColorPalette.textPrimary)

                        Text(L("ui.goal"))
                            .font(Typography.caption2)
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                }
                .frame(width: 80, height: 80)
            }

            // Target info
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L("progress.target"))
                        .font(Typography.caption2)
                        .foregroundColor(ColorPalette.textTertiary)

                    Text("\(String(format: "%.1f", targetWeight)) kg")
                        .font(Typography.callout)
                        .foregroundColor(ColorPalette.primary)
                }

                Spacer()

                if remaining > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(L("progress.remaining"))
                            .font(Typography.caption2)
                            .foregroundColor(ColorPalette.textTertiary)

                        Text("\(String(format: "%.1f", remaining)) kg")
                            .font(Typography.callout)
                            .foregroundColor(ColorPalette.textPrimary)
                    }
                } else {
                    Text(L("progress.goalReached"))
                        .font(Typography.callout)
                        .foregroundColor(ColorPalette.success)
                }
            }

            // Log weight button
            PrimaryButton(
                title: L("progress.logWeight"),
                icon: "scalemass",
                action: onLogTap
            )
        }
        .padding(AppTheme.Spacing.standard)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}

/// Weight chart card.
struct WeightChartCard: View {
    let entries: [WeightChartData]
    let targetWeight: Double
    let startWeight: Double

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(L("progress.weightTrend"))
                .font(Typography.headline)
                .foregroundColor(ColorPalette.textPrimary)

            if entries.isEmpty {
                Text(L("progress.noData"))
                    .font(Typography.body)
                    .foregroundColor(ColorPalette.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.xl)
            } else {
                WeightTrendChart(entries: entries, targetWeight: targetWeight)
                    .frame(height: 200)
            }
        }
        .padding(AppTheme.Spacing.standard)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}

/// Weight statistics card.
struct WeightStatisticsCard: View {
    let stats: WeightStatistics

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(L("progress.statistics"))
                .font(Typography.headline)
                .foregroundColor(ColorPalette.textPrimary)

            HStack(spacing: AppTheme.Spacing.lg) {
                StatisticItem(
                    title: L("progress.totalLost"),
                    value: String(format: "%.1f", stats.totalLost),
                    unit: "kg",
                    color: stats.totalLost > 0 ? ColorPalette.success : ColorPalette.error
                )

                StatisticItem(
                    title: L("progress.weeklyAvg"),
                    value: String(format: "%.2f", stats.weeklyAverage),
                    unit: "kg/week",
                    color: ColorPalette.textPrimary
                )

                StatisticItem(
                    title: L("progress.daysTracked"),
                    value: "\(stats.daysTracked)",
                    unit: L("ui.days"),
                    color: ColorPalette.textPrimary
                )
            }
        }
        .padding(AppTheme.Spacing.standard)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}

struct StatisticItem: View {
    let title: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text(value)
                .font(Typography.numberSmall)
                .foregroundColor(color)

            Text(unit)
                .font(Typography.caption2)
                .foregroundColor(ColorPalette.textSecondary)

            Text(title)
                .font(Typography.caption2)
                .foregroundColor(ColorPalette.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

/// BMI display card.
struct BMICard: View {
    let bmi: Double
    let height: Double

    private var category: BMICategory {
        BMICategory.from(bmi: bmi)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text(L("bmi.title"))
                    .font(Typography.headline)
                    .foregroundColor(ColorPalette.textPrimary)

                Spacer()

                Text(String(format: "%.1f", bmi))
                    .font(Typography.numberMedium)
                    .foregroundColor(category.color)
            }

            // BMI scale
            BMIScaleView(bmi: bmi)

            HStack {
                Text(category.name)
                    .font(Typography.callout)
                    .foregroundColor(category.color)

                Spacer()

                Text(String(format: L("bmi.height"), Int(height)))
                    .font(Typography.caption1)
                    .foregroundColor(ColorPalette.textSecondary)
            }
        }
        .padding(AppTheme.Spacing.standard)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}

enum BMICategory {
    case underweight
    case normal
    case overweight
    case obese

    var name: String {
        switch self {
        case .underweight: return L("bmi.underweight")
        case .normal: return L("bmi.normal")
        case .overweight: return L("bmi.overweight")
        case .obese: return L("bmi.obese")
        }
    }

    var color: Color {
        switch self {
        case .underweight: return ColorPalette.water
        case .normal: return ColorPalette.success
        case .overweight: return ColorPalette.warning
        case .obese: return ColorPalette.error
        }
    }

    static func from(bmi: Double) -> BMICategory {
        switch bmi {
        case ..<18.5: return .underweight
        case 18.5..<25: return .normal
        case 25..<30: return .overweight
        default: return .obese
        }
    }
}

/// BMI scale visualization.
struct BMIScaleView: View {
    let bmi: Double

    private var indicatorPosition: CGFloat {
        // Map BMI 15-40 to 0-1
        let normalized = (bmi - 15) / 25
        return min(1, max(0, normalized))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Scale background
                HStack(spacing: 0) {
                    Rectangle().fill(ColorPalette.water)
                    Rectangle().fill(ColorPalette.success)
                    Rectangle().fill(ColorPalette.warning)
                    Rectangle().fill(ColorPalette.error)
                }
                .frame(height: 8)
                .cornerRadius(4)

                // Indicator
                Circle()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
                    .shadow(radius: 2)
                    .offset(x: geometry.size.width * indicatorPosition - 8)
            }
        }
        .frame(height: 16)
    }
}

/// Weight history list section.
struct WeightHistorySection: View {
    let entries: [WeightEntry]
    let onDelete: (WeightEntry) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(L("progress.recentEntries"))
                .font(Typography.headline)
                .foregroundColor(ColorPalette.textPrimary)

            if entries.isEmpty {
                Text(L("progress.noEntries"))
                    .font(Typography.body)
                    .foregroundColor(ColorPalette.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        let previousWeight = index < entries.count - 1 ? entries[index + 1].weight : nil

                        WeightEntryRow(entry: entry, previousWeight: previousWeight)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    onDelete(entry)
                                } label: {
                                    Label(L("common.delete"), systemImage: "trash")
                                }
                            }

                        if entry.id != entries.last?.id {
                            Divider()
                                .padding(.leading, AppTheme.Spacing.standard)
                        }
                    }
                }
                .background(ColorPalette.cardBackground)
                .cornerRadius(AppTheme.CornerRadius.medium)
            }
        }
    }
}

/// Log weight view.
struct LogWeightView: View {
    let container: DependencyContainer
    let onComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var weight: Double = 80.0
    @State private var date: Date = Date()
    @State private var notes: String = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Weight input
                    VStack(spacing: AppTheme.Spacing.lg) {
                        Text(L("progress.enterWeight"))
                            .font(Typography.headline)
                            .foregroundColor(ColorPalette.textPrimary)

                        HStack {
                            Button(action: { weight = max(30, weight - 0.1) }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(ColorPalette.primary)
                            }

                            Text(String(format: "%.1f", weight))
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundColor(ColorPalette.textPrimary)
                                .frame(width: 180)

                            Button(action: { weight = min(300, weight + 0.1) }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(ColorPalette.primary)
                            }
                        }

                        Text(L("common.kg"))
                            .font(Typography.title2)
                            .foregroundColor(ColorPalette.textSecondary)

                        // Quick adjust buttons
                        HStack(spacing: AppTheme.Spacing.md) {
                            ForEach([-1.0, -0.5, 0.5, 1.0], id: \.self) { adjustment in
                                Button(action: { weight += adjustment }) {
                                    Text(adjustment > 0 ? "+\(String(format: "%.1f", adjustment))" : String(format: "%.1f", adjustment))
                                        .font(Typography.caption1)
                                        .foregroundColor(ColorPalette.primary)
                                        .padding(.horizontal, AppTheme.Spacing.md)
                                        .padding(.vertical, AppTheme.Spacing.sm)
                                        .background(ColorPalette.primary.opacity(0.1))
                                        .cornerRadius(AppTheme.CornerRadius.small)
                                }
                            }
                        }
                    }

                    // Date picker
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text(L("progress.date"))
                            .font(Typography.caption1)
                            .foregroundColor(ColorPalette.textSecondary)

                        DatePicker("", selection: $date, in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(AppTheme.Spacing.md)
                    .background(ColorPalette.cardBackground)
                    .cornerRadius(AppTheme.CornerRadius.medium)

                    // Notes
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text(L("progress.notes"))
                            .font(Typography.caption1)
                            .foregroundColor(ColorPalette.textSecondary)

                        TextField(L("progress.notesPlaceholder"), text: $notes, axis: .vertical)
                            .font(Typography.body)
                            .lineLimit(3...6)
                            .padding(AppTheme.Spacing.md)
                            .background(ColorPalette.inputBackground)
                            .cornerRadius(AppTheme.CornerRadius.small)
                    }

                    // Save button
                    PrimaryButton(
                        title: L("common.save"),
                        action: saveWeight,
                        isLoading: isSaving
                    )
                }
                .padding(AppTheme.Spacing.standard)
            }
            .background(ColorPalette.backgroundSecondary)
            .navigationTitle(L("progress.logWeight"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("common.cancel")) {
                        dismiss()
                    }
                }
            }
            .task {
                await loadLastWeight()
            }
        }
    }

    private func loadLastWeight() async {
        let useCase = container.makeGetWeightHistoryUseCase()
        if let entries = try? await useCase.execute(days: 1),
           let lastEntry = entries.first {
            weight = lastEntry.weight
        }
    }

    private func saveWeight() {
        isSaving = true

        Task {
            let entry = WeightEntry(
                id: UUID(),
                date: date,
                weight: weight,
                notes: notes.isEmpty ? nil : notes
            )

            let useCase = container.makeLogWeightUseCase()
            try? await useCase.execute(entry: entry)

            isSaving = false
            ToastManager.shared.showSuccess(L("toast.saved"))
            onComplete()
            dismiss()
        }
    }
}

#Preview {
    WeightProgressView(container: DependencyContainer.preview)
}
