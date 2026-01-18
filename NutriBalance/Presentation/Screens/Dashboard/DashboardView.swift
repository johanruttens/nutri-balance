import SwiftUI

/// Main dashboard view showing daily summary and quick actions.
struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    @State private var showAddFood = false
    @State private var showAddDrink = false
    @State private var showLogWeight = false
    @State private var showDatePicker = false

    init(container: DependencyContainer) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Date header
                    DateHeaderView(
                        date: viewModel.selectedDate,
                        onCalendarTap: { showDatePicker = true }
                    )

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
            .navigationTitle(L("dashboard.title"))
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadData()
            }
            .sheet(isPresented: $showAddFood) {
                AddFoodView(
                    container: viewModel.container,
                    mealCategory: .lunch,
                    date: viewModel.selectedDate
                ) {
                    Task { await viewModel.refresh() }
                }
            }
            .sheet(isPresented: $showAddDrink) {
                AddDrinkView(container: viewModel.container) {
                    Task { await viewModel.refresh() }
                }
            }
            .sheet(isPresented: $showLogWeight) {
                DashboardLogWeightView(container: viewModel.container) {
                    Task { await viewModel.refresh() }
                }
            }
            .sheet(isPresented: $showDatePicker) {
                DatePickerSheet(
                    selectedDate: $viewModel.selectedDate,
                    onDateSelected: {
                        showDatePicker = false
                        Task { await viewModel.refresh() }
                    }
                )
            }
        }
    }
}

/// Date header with day navigation.
struct DateHeaderView: View {
    let date: Date
    let onCalendarTap: () -> Void

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                if isToday {
                    Text(L("common.today"))
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.primary)
                }

                Text(LDate(date, style: .full))
                    .font(Typography.title2)
                    .foregroundColor(ColorPalette.textPrimary)
            }

            Spacer()

            // Calendar button
            Button(action: onCalendarTap) {
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .foregroundColor(ColorPalette.primary)
                    .padding(AppTheme.Spacing.sm)
                    .background(ColorPalette.primary.opacity(0.1))
                    .clipShape(Circle())
            }
            .accessibilityLabel(L("accessibility.calendarButton"))
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
            Text(L("dashboard.quickActions"))
                .font(Typography.headline)
                .foregroundColor(ColorPalette.textPrimary)

            HStack(spacing: AppTheme.Spacing.md) {
                QuickActionButton(
                    title: L("common.addFood"),
                    systemName: "fork.knife",
                    color: ColorPalette.primary,
                    action: onAddFood
                )

                QuickActionButton(
                    title: L("common.addDrink"),
                    systemName: "drop.fill",
                    color: ColorPalette.water,
                    action: onAddDrink
                )

                QuickActionButton(
                    title: L("common.logWeight"),
                    systemName: "scalemass",
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
                title: L("dashboard.recentEntries"),
                actionTitle: L("common.seeAll"),
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

/// Date picker sheet for selecting a date.
struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    let onDateSelected: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.lg) {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(ColorPalette.primary)

                PrimaryButton(
                    title: L("common.select"),
                    action: onDateSelected
                )
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle(L("common.selectDate"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("common.cancel")) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

/// Sheet for logging weight entry.
struct DashboardLogWeightView: View {
    let container: DependencyContainer
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var weight: Double = 75.0
    @State private var notes: String = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Weight input
                    VStack(spacing: AppTheme.Spacing.lg) {
                        Text(L("weight.currentWeight"))
                            .font(Typography.headline)
                            .foregroundColor(ColorPalette.textPrimary)

                        HStack {
                            Button(action: { weight = max(30, weight - 0.1) }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(ColorPalette.secondary)
                            }

                            VStack(spacing: 4) {
                                Text(String(format: "%.1f", weight))
                                    .font(.system(size: 56, weight: .bold, design: .rounded))
                                    .foregroundColor(ColorPalette.textPrimary)
                                Text("kg")
                                    .font(Typography.title3)
                                    .foregroundColor(ColorPalette.textSecondary)
                            }
                            .frame(width: 150)

                            Button(action: { weight = min(300, weight + 0.1) }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(ColorPalette.secondary)
                            }
                        }

                        // Quick adjust buttons
                        HStack(spacing: AppTheme.Spacing.sm) {
                            ForEach([-1.0, -0.5, 0.5, 1.0], id: \.self) { adjustment in
                                Button(action: {
                                    weight = max(30, min(300, weight + adjustment))
                                }) {
                                    Text(adjustment > 0 ? "+\(String(format: "%.1f", adjustment))" : String(format: "%.1f", adjustment))
                                        .font(Typography.caption1)
                                        .foregroundColor(ColorPalette.secondary)
                                        .padding(.horizontal, AppTheme.Spacing.md)
                                        .padding(.vertical, AppTheme.Spacing.sm)
                                        .background(ColorPalette.secondary.opacity(0.15))
                                        .cornerRadius(AppTheme.CornerRadius.small)
                                }
                            }
                        }
                    }
                    .padding(AppTheme.Spacing.lg)
                    .background(ColorPalette.cardBackground)
                    .cornerRadius(AppTheme.CornerRadius.large)

                    // Notes
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text(L("common.notes"))
                            .font(Typography.headline)
                            .foregroundColor(ColorPalette.textPrimary)

                        TextField(L("weight.notesPlaceholder"), text: $notes, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    }

                    // Save button
                    PrimaryButton(
                        title: L("weight.logWeight"),
                        icon: "scalemass",
                        action: saveWeight,
                        isLoading: isSaving
                    )
                }
                .padding(AppTheme.Spacing.standard)
            }
            .background(ColorPalette.backgroundSecondary)
            .navigationTitle(L("common.logWeight"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("common.cancel")) {
                        dismiss()
                    }
                }
            }
            .task {
                await loadCurrentWeight()
            }
        }
    }

    private func loadCurrentWeight() async {
        let repository = container.userRepository
        if let user = try? await repository.getCurrentUser() {
            weight = user.currentWeight
        }
    }

    private func saveWeight() {
        isSaving = true

        Task {
            let entry = WeightEntry(
                id: UUID(),
                date: Date(),
                weight: weight,
                notes: notes.isEmpty ? nil : notes,
                createdAt: Date()
            )

            let useCase = container.makeLogWeightUseCase()
            try? await useCase.execute(entry: entry)

            isSaving = false
            onComplete()
            dismiss()
        }
    }
}

#Preview {
    DashboardView(container: DependencyContainer.preview)
}
