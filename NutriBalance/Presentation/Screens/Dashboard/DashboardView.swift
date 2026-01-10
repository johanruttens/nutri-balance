import SwiftUI

/// Main dashboard view showing daily summary and quick actions.
struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    @State private var showAddFood = false
    @State private var showAddDrink = false
    @State private var showLogWeight = false

    init(container: DependencyContainer) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Date header
                    DateHeaderView(date: viewModel.selectedDate)

                    // Daily calorie summary
                    if let summary = viewModel.dailySummary {
                        CalorieSummaryCard(
                            consumed: summary.totalCalories,
                            goal: viewModel.calorieGoal,
                            protein: summary.totalProtein,
                            carbs: summary.totalCarbs,
                            fat: summary.totalFat
                        )
                    } else {
                        CalorieSummaryCard(
                            consumed: 0,
                            goal: viewModel.calorieGoal,
                            protein: 0,
                            carbs: 0,
                            fat: 0
                        )
                    }

                    // Hydration summary
                    HydrationSummaryCard(
                        intake: viewModel.hydrationIntake,
                        goal: viewModel.hydrationGoal
                    )

                    // Quick actions
                    QuickActionsSection(
                        onAddFood: { showAddFood = true },
                        onAddDrink: { showAddDrink = true },
                        onLogWeight: { showLogWeight = true }
                    )

                    // Streak display
                    if viewModel.currentStreak > 0 {
                        StreakDisplay(count: viewModel.currentStreak)
                    }

                    // Recent entries
                    if !viewModel.recentEntries.isEmpty {
                        RecentEntriesSection(entries: viewModel.recentEntries)
                    }

                    // Weight progress (if tracking)
                    if let weightProgress = viewModel.weightProgress {
                        WeightProgressCard(
                            currentWeight: weightProgress.current,
                            targetWeight: weightProgress.target,
                            startWeight: weightProgress.start,
                            trend: weightProgress.trend
                        )
                    }
                }
                .padding(AppTheme.Spacing.standard)
            }
            .background(ColorPalette.backgroundSecondary)
            .navigationTitle(String(localized: "dashboard.title"))
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadData()
            }
            .sheet(isPresented: $showAddFood) {
                AddFoodSheet(container: viewModel.container) {
                    Task { await viewModel.refresh() }
                }
            }
            .sheet(isPresented: $showAddDrink) {
                AddDrinkSheet(container: viewModel.container) {
                    Task { await viewModel.refresh() }
                }
            }
            .sheet(isPresented: $showLogWeight) {
                LogWeightSheet(container: viewModel.container) {
                    Task { await viewModel.refresh() }
                }
            }
        }
    }
}

/// Date header with day navigation.
struct DateHeaderView: View {
    let date: Date

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                if isToday {
                    Text(String(localized: "common.today"))
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.primary)
                }

                Text(date, format: .dateTime.weekday(.wide).month().day())
                    .font(Typography.title2)
                    .foregroundColor(ColorPalette.textPrimary)
            }

            Spacer()

            // Calendar button
            Button(action: {}) {
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .foregroundColor(ColorPalette.primary)
            }
        }
    }
}

/// Quick actions section with buttons.
struct QuickActionsSection: View {
    let onAddFood: () -> Void
    let onAddDrink: () -> Void
    let onLogWeight: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(String(localized: "dashboard.quickActions"))
                .font(Typography.headline)
                .foregroundColor(ColorPalette.textPrimary)

            HStack(spacing: AppTheme.Spacing.md) {
                QuickActionButton(
                    icon: "fork.knife",
                    title: String(localized: "common.addFood"),
                    color: ColorPalette.primary,
                    action: onAddFood
                )

                QuickActionButton(
                    icon: "drop.fill",
                    title: String(localized: "common.addDrink"),
                    color: ColorPalette.water,
                    action: onAddDrink
                )

                QuickActionButton(
                    icon: "scalemass",
                    title: String(localized: "common.logWeight"),
                    color: ColorPalette.secondary,
                    action: onLogWeight
                )
            }
        }
    }
}

/// Recent entries section.
struct RecentEntriesSection: View {
    let entries: [FoodEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            SectionHeader(
                title: String(localized: "dashboard.recentEntries"),
                actionTitle: String(localized: "common.seeAll"),
                action: {}
            )

            VStack(spacing: AppTheme.Spacing.sm) {
                ForEach(entries.prefix(3)) { entry in
                    FoodEntryRow(entry: entry)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(ColorPalette.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
    }
}

/// Placeholder sheet for adding food.
struct AddFoodSheet: View {
    let container: DependencyContainer
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Text("Add Food")
                .navigationTitle(String(localized: "common.addFood"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(String(localized: "common.cancel")) {
                            dismiss()
                        }
                    }
                }
        }
    }
}

/// Placeholder sheet for adding drink.
struct AddDrinkSheet: View {
    let container: DependencyContainer
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Text("Add Drink")
                .navigationTitle(String(localized: "common.addDrink"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(String(localized: "common.cancel")) {
                            dismiss()
                        }
                    }
                }
        }
    }
}

/// Placeholder sheet for logging weight.
struct LogWeightSheet: View {
    let container: DependencyContainer
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Text("Log Weight")
                .navigationTitle(String(localized: "common.logWeight"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(String(localized: "common.cancel")) {
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    DashboardView(container: DependencyContainer.preview)
}
