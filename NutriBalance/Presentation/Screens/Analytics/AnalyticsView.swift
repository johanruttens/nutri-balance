import SwiftUI
import Charts
import UIKit

/// Main analytics view with weekly/monthly reports.
struct AnalyticsView: View {
    @StateObject private var viewModel: AnalyticsViewModel
    @State private var selectedPeriod: AnalyticsPeriod = .week

    init(container: DependencyContainer) {
        _viewModel = StateObject(wrappedValue: AnalyticsViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Period selector
                    PeriodPicker(selection: $selectedPeriod) {
                        Task { await viewModel.loadData(for: selectedPeriod) }
                    }

                    // Summary cards
                    AnalyticsSummarySection(summary: viewModel.summary)

                    // Calorie chart
                    CalorieChartSection(
                        data: viewModel.calorieData,
                        goal: viewModel.calorieGoal,
                        period: selectedPeriod
                    )

                    // Macro breakdown
                    MacroBreakdownSection(
                        protein: viewModel.avgProtein,
                        carbs: viewModel.avgCarbs,
                        fat: viewModel.avgFat
                    )

                    // Nutrition goals progress
                    GoalsProgressSection(
                        calorieProgress: viewModel.calorieGoalProgress,
                        proteinProgress: viewModel.proteinGoalProgress,
                        hydrationProgress: viewModel.hydrationGoalProgress
                    )

                    // Consistency streak
                    ConsistencySection(
                        streak: viewModel.currentStreak,
                        daysLogged: viewModel.daysLogged,
                        totalDays: selectedPeriod.days
                    )

                    // Export button
                    SecondaryButton(
                        title: L("analytics.exportReport"),
                        icon: "square.and.arrow.up",
                        action: { viewModel.showExport = true }
                    )
                }
                .padding(AppTheme.Spacing.standard)
            }
            .background(ColorPalette.backgroundSecondary)
            .navigationTitle(L("analytics.title"))
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.loadData(for: selectedPeriod)
            }
            .task {
                await viewModel.loadData(for: selectedPeriod)
            }
            .sheet(isPresented: $viewModel.showExport) {
                ExportView(container: viewModel.container)
            }
        }
    }
}

/// Analytics period options.
enum AnalyticsPeriod: String, CaseIterable, Identifiable {
    case week
    case month

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .week: return L("period.week")
        case .month: return L("period.month")
        }
    }

    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        }
    }
}

/// Period picker.
struct PeriodPicker: View {
    @Binding var selection: AnalyticsPeriod
    let onChange: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AnalyticsPeriod.allCases) { period in
                Button(action: {
                    selection = period
                    onChange()
                }) {
                    Text(period.displayName)
                        .font(Typography.body)
                        .foregroundColor(selection == period ? .white : ColorPalette.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(selection == period ? ColorPalette.primary : Color.clear)
                }
            }
        }
        .background(ColorPalette.inputBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
}

/// Summary cards section.
struct AnalyticsSummarySection: View {
    let summary: AnalyticsSummary

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            SummaryStatCard(
                title: L("analytics.avgCalories"),
                value: "\(summary.avgCalories)",
                unit: "kcal",
                icon: "flame.fill",
                color: ColorPalette.primary
            )

            SummaryStatCard(
                title: L("analytics.avgHydration"),
                value: "\(Int(summary.avgHydration))",
                unit: "ml",
                icon: "drop.fill",
                color: ColorPalette.water
            )
        }
    }
}

struct SummaryStatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)

                Text(title)
                    .font(Typography.caption1)
                    .foregroundColor(ColorPalette.textSecondary)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(Typography.numberMedium)
                    .foregroundColor(ColorPalette.textPrimary)

                Text(unit)
                    .font(Typography.caption1)
                    .foregroundColor(ColorPalette.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.standard)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}

/// Calorie chart section.
struct CalorieChartSection: View {
    let data: [DailyCalorieData]
    let goal: Int
    let period: AnalyticsPeriod

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(L("analytics.calorieIntake"))
                .font(Typography.headline)
                .foregroundColor(ColorPalette.textPrimary)

            if data.isEmpty {
                EmptyChartPlaceholder()
            } else {
                CalorieBarChart(data: data, goal: goal)
                    .frame(height: 200)
            }
        }
        .padding(AppTheme.Spacing.standard)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}

struct EmptyChartPlaceholder: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "chart.bar")
                .font(.system(size: 40))
                .foregroundColor(ColorPalette.textTertiary)

            Text(L("analytics.noData"))
                .font(Typography.body)
                .foregroundColor(ColorPalette.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
}

/// Macro breakdown section.
struct MacroBreakdownSection: View {
    let protein: Double
    let carbs: Double
    let fat: Double

    private var total: Double {
        protein + carbs + fat
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(L("analytics.macroBreakdown"))
                .font(Typography.headline)
                .foregroundColor(ColorPalette.textPrimary)

            HStack(spacing: AppTheme.Spacing.lg) {
                // Pie chart
                if total > 0 {
                    MacroPieChart(protein: protein, carbs: carbs, fat: fat)
                        .frame(width: 100, height: 100)
                }

                // Legend
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    MacroLegendItem(
                        name: L("macro.protein"),
                        value: protein,
                        percentage: total > 0 ? protein / total * 100 : 0,
                        color: .red.opacity(0.8)
                    )

                    MacroLegendItem(
                        name: L("macro.carbs"),
                        value: carbs,
                        percentage: total > 0 ? carbs / total * 100 : 0,
                        color: .orange.opacity(0.8)
                    )

                    MacroLegendItem(
                        name: L("macro.fat"),
                        value: fat,
                        percentage: total > 0 ? fat / total * 100 : 0,
                        color: .yellow.opacity(0.8)
                    )
                }
            }
        }
        .padding(AppTheme.Spacing.standard)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}

struct MacroLegendItem: View {
    let name: String
    let value: Double
    let percentage: Double
    let color: Color

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            Text(name)
                .font(Typography.caption1)
                .foregroundColor(ColorPalette.textSecondary)
                .frame(width: 60, alignment: .leading)

            Text("\(Int(value))g")
                .font(Typography.callout)
                .foregroundColor(ColorPalette.textPrimary)

            Text("(\(Int(percentage))%)")
                .font(Typography.caption2)
                .foregroundColor(ColorPalette.textTertiary)
        }
    }
}

/// Goals progress section.
struct GoalsProgressSection: View {
    let calorieProgress: Double
    let proteinProgress: Double
    let hydrationProgress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(L("analytics.goalProgress"))
                .font(Typography.headline)
                .foregroundColor(ColorPalette.textPrimary)

            VStack(spacing: AppTheme.Spacing.md) {
                GoalProgressRow(
                    title: L("analytics.calorieGoal"),
                    progress: calorieProgress,
                    color: ColorPalette.primary
                )

                GoalProgressRow(
                    title: L("analytics.proteinGoal"),
                    progress: proteinProgress,
                    color: .red.opacity(0.8)
                )

                GoalProgressRow(
                    title: L("analytics.hydrationGoal"),
                    progress: hydrationProgress,
                    color: ColorPalette.water
                )
            }
        }
        .padding(AppTheme.Spacing.standard)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}

struct GoalProgressRow: View {
    let title: String
    let progress: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            HStack {
                Text(title)
                    .font(Typography.caption1)
                    .foregroundColor(ColorPalette.textSecondary)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(Typography.callout)
                    .foregroundColor(progress >= 0.9 ? ColorPalette.success : ColorPalette.textPrimary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ColorPalette.divider)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * min(progress, 1.0))
                }
            }
            .frame(height: 8)
        }
    }
}

/// Consistency section.
struct ConsistencySection: View {
    let streak: Int
    let daysLogged: Int
    let totalDays: Int

    private var percentage: Int {
        guard totalDays > 0 else { return 0 }
        return Int(Double(daysLogged) / Double(totalDays) * 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(L("analytics.consistency"))
                .font(Typography.headline)
                .foregroundColor(ColorPalette.textPrimary)

            HStack(spacing: AppTheme.Spacing.xl) {
                // Streak
                VStack(spacing: AppTheme.Spacing.xs) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)

                        Text("\(streak)")
                            .font(Typography.numberLarge)
                            .foregroundColor(ColorPalette.textPrimary)
                    }

                    Text(L("analytics.dayStreak"))
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.textSecondary)
                }

                Divider()
                    .frame(height: 50)

                // Days logged
                VStack(spacing: AppTheme.Spacing.xs) {
                    Text("\(daysLogged)/\(totalDays)")
                        .font(Typography.numberMedium)
                        .foregroundColor(ColorPalette.textPrimary)

                    Text(L("analytics.daysLogged"))
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.textSecondary)
                }

                Divider()
                    .frame(height: 50)

                // Percentage
                VStack(spacing: AppTheme.Spacing.xs) {
                    Text("\(percentage)%")
                        .font(Typography.numberMedium)
                        .foregroundColor(percentage >= 80 ? ColorPalette.success : ColorPalette.textPrimary)

                    Text(L("analytics.completion"))
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(AppTheme.Spacing.standard)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}

/// Export view for generating PDF reports.
struct ExportView: View {
    let container: DependencyContainer
    @Environment(\.dismiss) private var dismiss
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var isExporting = false
    @State private var exportError: String?
    @State private var showShareSheet = false
    @State private var pdfData: Data?

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.xl) {
                // Date range
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text(L("export.dateRange"))
                        .font(Typography.headline)
                        .foregroundColor(ColorPalette.textPrimary)

                    HStack {
                        VStack(alignment: .leading) {
                            Text(L("export.from"))
                                .font(Typography.caption1)
                                .foregroundColor(ColorPalette.textSecondary)

                            DatePicker("", selection: $startDate, in: ...endDate, displayedComponents: .date)
                                .labelsHidden()
                        }

                        Spacer()

                        VStack(alignment: .leading) {
                            Text(L("export.to"))
                                .font(Typography.caption1)
                                .foregroundColor(ColorPalette.textSecondary)

                            DatePicker("", selection: $endDate, in: startDate...Date(), displayedComponents: .date)
                                .labelsHidden()
                        }
                    }
                }
                .padding(AppTheme.Spacing.standard)
                .background(ColorPalette.cardBackground)
                .cornerRadius(AppTheme.CornerRadius.large)

                // Info
                HStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "info.circle")
                        .foregroundColor(ColorPalette.primary)

                    Text(L("export.info"))
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.textSecondary)
                }
                .padding(AppTheme.Spacing.md)
                .background(ColorPalette.primary.opacity(0.1))
                .cornerRadius(AppTheme.CornerRadius.medium)

                // Error message
                if let error = exportError {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(ColorPalette.error)
                        Text(error)
                            .font(Typography.caption1)
                            .foregroundColor(ColorPalette.error)
                    }
                    .padding(AppTheme.Spacing.md)
                    .background(ColorPalette.error.opacity(0.1))
                    .cornerRadius(AppTheme.CornerRadius.medium)
                }

                Spacer()

                // Export button
                PrimaryButton(
                    title: L("export.generatePDF"),
                    icon: "doc.fill",
                    action: exportPDF,
                    isLoading: isExporting
                )
            }
            .padding(AppTheme.Spacing.standard)
            .background(ColorPalette.backgroundSecondary)
            .navigationTitle(L("export.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("common.cancel")) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let data = pdfData {
                    ShareSheet(items: [data])
                }
            }
        }
    }

    private func exportPDF() {
        isExporting = true
        exportError = nil

        Task {
            do {
                let useCase = container.makeGeneratePDFReportUseCase()
                let data = try await useCase.execute(from: startDate, to: endDate)
                pdfData = data
                showShareSheet = true
            } catch {
                exportError = error.localizedDescription
            }
            isExporting = false
        }
    }
}

/// Share sheet for exporting PDF.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    AnalyticsView(container: DependencyContainer.preview)
}
