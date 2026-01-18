import SwiftUI

/// Main today view showing daily food log by meal category.
struct TodayView: View {
    @StateObject private var viewModel: TodayViewModel
    @State private var selectedMealCategory: MealCategory?
    @State private var showAddFood = false
    @State private var showAddDrink = false
    @State private var showDeleteConfirmation = false
    @State private var entryToDelete: FoodEntry?

    init(container: DependencyContainer) {
        _viewModel = StateObject(wrappedValue: TodayViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Date selector
                        DateSelectorView(
                            selectedDate: $viewModel.selectedDate,
                            onDateChange: { date in
                                Task { await viewModel.loadEntries() }
                            }
                        )

                    // Daily summary
                    DailySummaryHeader(
                        consumed: viewModel.totalCalories,
                        goal: viewModel.calorieGoal,
                        protein: viewModel.totalProtein,
                        carbs: viewModel.totalCarbs,
                        fat: viewModel.totalFat
                    )

                    // Hydration quick summary
                    HydrationQuickView(
                        intake: viewModel.hydrationIntake,
                        goal: viewModel.hydrationGoal,
                        onAddDrink: { showAddDrink = true }
                    )

                    // Meal categories
                    ForEach(MealCategory.allCases) { category in
                        MealCategorySection(
                            category: category,
                            entries: viewModel.entriesForCategory(category),
                            onAddTap: {
                                selectedMealCategory = category
                                showAddFood = true
                            },
                            onEntryTap: { entry in
                                viewModel.selectedEntry = entry
                            },
                            onDeleteEntry: { entry in
                                entryToDelete = entry
                                showDeleteConfirmation = true
                            }
                        )
                    }
                    }
                    .padding(AppTheme.Spacing.standard)
                }
                .background(ColorPalette.backgroundSecondary)

                // Loading overlay
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
            .navigationTitle(L("today.title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: AppTheme.Spacing.md) {
                        Button(action: { showAddDrink = true }) {
                            Image(systemName: "drop.fill")
                                .foregroundColor(ColorPalette.water)
                        }
                        .accessibilityLabel(L("accessibility.waterButton"))

                        Button(action: { showAddFood = true }) {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel(L("accessibility.addButton"))
                    }
                }
            }
            .refreshable {
                await viewModel.loadEntries()
            }
            .task {
                await viewModel.loadEntries()
            }
            .sheet(isPresented: $showAddFood) {
                AddFoodView(
                    container: viewModel.container,
                    mealCategory: selectedMealCategory ?? .lunch,
                    date: viewModel.selectedDate
                ) {
                    Task { await viewModel.loadEntries() }
                }
            }
            .sheet(item: $viewModel.selectedEntry) { entry in
                FoodEntryDetailView(
                    entry: entry,
                    container: viewModel.container
                ) {
                    Task { await viewModel.loadEntries() }
                }
            }
            .sheet(isPresented: $showAddDrink) {
                AddDrinkView(container: viewModel.container) {
                    Task { await viewModel.loadEntries() }
                }
            }
            .alert(
                L("common.confirmDelete"),
                isPresented: $showDeleteConfirmation,
                presenting: entryToDelete
            ) { entry in
                Button(L("common.cancel"), role: .cancel) {
                    entryToDelete = nil
                }
                Button(L("common.delete"), role: .destructive) {
                    Task {
                        await viewModel.deleteEntry(entry)
                        entryToDelete = nil
                    }
                }
            } message: { entry in
                Text(L("common.deleteEntryMessage") + " \(entry.foodName)")
            }
        }
    }
}

/// Compact hydration view for Today screen.
struct HydrationQuickView: View {
    let intake: Double
    let goal: Double
    let onAddDrink: () -> Void

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return intake / goal
    }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Progress indicator
            ZStack {
                Circle()
                    .stroke(ColorPalette.water.opacity(0.2), lineWidth: 6)
                    .frame(width: 50, height: 50)

                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(ColorPalette.water, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 50, height: 50)

                Image(systemName: "drop.fill")
                    .font(.system(size: 16))
                    .foregroundColor(ColorPalette.water)
            }

            // Info
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(L("hydration.title"))
                    .font(Typography.headline)
                    .foregroundColor(ColorPalette.textPrimary)

                Text("\(Int(intake)) / \(Int(goal)) ml")
                    .font(Typography.callout)
                    .foregroundColor(ColorPalette.textSecondary)
            }

            Spacer()

            // Add button
            Button(action: onAddDrink) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(ColorPalette.water)
            }
            .accessibilityLabel(L("accessibility.waterButton"))
        }
        .padding(AppTheme.Spacing.md)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
}

/// Date selector with prev/next navigation.
struct DateSelectorView: View {
    @Binding var selectedDate: Date
    let onDateChange: (Date) -> Void

    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    var body: some View {
        HStack {
            Button(action: previousDay) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ColorPalette.primary)
            }

            Spacer()

            VStack(spacing: AppTheme.Spacing.xs) {
                if isToday {
                    Text(L("common.today"))
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.primary)
                }

                Text(LDate(selectedDate, style: .full))
                    .font(Typography.headline)
                    .foregroundColor(ColorPalette.textPrimary)
            }

            Spacer()

            Button(action: nextDay) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isToday ? ColorPalette.textTertiary : ColorPalette.primary)
            }
            .disabled(isToday)
        }
        .padding(.vertical, AppTheme.Spacing.sm)
    }

    private func previousDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = newDate
            onDateChange(newDate)
        }
    }

    private func nextDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate),
           newDate <= Date() {
            selectedDate = newDate
            onDateChange(newDate)
        }
    }
}

/// Daily summary header.
struct DailySummaryHeader: View {
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
        return Double(consumed) / Double(goal)
    }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.lg) {
            // Calories circle
            ZStack {
                Circle()
                    .stroke(ColorPalette.divider, lineWidth: 8)

                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        progress > 1.0 ? ColorPalette.error : ColorPalette.primary,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(consumed)")
                        .font(Typography.numberMedium)
                        .foregroundColor(ColorPalette.textPrimary)
                    Text("/ \(goal)")
                        .font(Typography.caption2)
                        .foregroundColor(ColorPalette.textSecondary)
                }
            }
            .frame(width: 80, height: 80)

            // Macros
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                MacroRow(name: L("macro.protein"), value: protein, color: .red.opacity(0.8))
                MacroRow(name: L("macro.carbs"), value: carbs, color: .orange.opacity(0.8))
                MacroRow(name: L("macro.fat"), value: fat, color: .yellow.opacity(0.8))
            }

            Spacer()

            // Remaining
            VStack(spacing: AppTheme.Spacing.xs) {
                Text("\(remaining)")
                    .font(Typography.numberMedium)
                    .foregroundColor(consumed > goal ? ColorPalette.error : ColorPalette.success)
                Text(L("ui.remaining"))
                    .font(Typography.caption2)
                    .foregroundColor(ColorPalette.textSecondary)
            }
        }
        .padding(AppTheme.Spacing.standard)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}

struct MacroRow: View {
    let name: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(name)
                .font(Typography.caption1)
                .foregroundColor(ColorPalette.textSecondary)

            Text("\(Int(value))g")
                .font(Typography.caption1)
                .foregroundColor(ColorPalette.textPrimary)
        }
    }
}

/// Meal category section.
struct MealCategorySection: View {
    let category: MealCategory
    let entries: [FoodEntry]
    let onAddTap: () -> Void
    let onEntryTap: (FoodEntry) -> Void
    let onDeleteEntry: (FoodEntry) -> Void

    private var totalCalories: Int {
        entries.compactMap(\.calories).reduce(0, +)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: category.iconName)
                        .font(.system(size: 16))
                        .foregroundColor(category.color)

                    Text(category.displayName)
                        .font(Typography.headline)
                        .foregroundColor(ColorPalette.textPrimary)
                }

                Spacer()

                if !entries.isEmpty {
                    Text("\(totalCalories) kcal")
                        .font(Typography.callout)
                        .foregroundColor(ColorPalette.textSecondary)
                }

                Button(action: onAddTap) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(category.color)
                }
                .accessibilityLabel(L("accessibility.addButton"))
            }
            .padding(AppTheme.Spacing.md)
            .background(ColorPalette.cardBackground)

            // Entries
            if entries.isEmpty {
                EmptyMealView(category: category, onAddTap: onAddTap)
            } else {
                VStack(spacing: 0) {
                    ForEach(entries) { entry in
                        FoodEntryRow(entry: entry)
                            .contentShape(Rectangle())
                            .onTapGesture { onEntryTap(entry) }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    onDeleteEntry(entry)
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
            }
        }
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
}

/// Empty meal placeholder.
struct EmptyMealView: View {
    let category: MealCategory
    let onAddTap: () -> Void

    var body: some View {
        Button(action: onAddTap) {
            HStack {
                Text(String(format: L("ui.tapToAddMeal"), category.displayName.lowercased()))
                    .font(Typography.body)
                    .foregroundColor(ColorPalette.textTertiary)

                Spacer()

                Image(systemName: "plus")
                    .font(.system(size: 14))
                    .foregroundColor(ColorPalette.textTertiary)
            }
            .padding(AppTheme.Spacing.md)
            .background(ColorPalette.cardBackground.opacity(0.5))
        }
    }
}

/// Food entry row for displaying in meal sections.
struct FoodEntryRow: View {
    let entry: FoodEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(entry.foodName)
                    .font(Typography.body)
                    .foregroundColor(ColorPalette.textPrimary)

                Text(entry.portionString)
                    .font(Typography.caption2)
                    .foregroundColor(ColorPalette.textTertiary)
            }

            Spacer()

            if let calories = entry.calories {
                Text("\(calories)")
                    .font(Typography.numberSmall)
                    .foregroundColor(ColorPalette.textPrimary)
                + Text(" kcal")
                    .font(Typography.caption2)
                    .foregroundColor(ColorPalette.textSecondary)
            }
        }
        .padding(AppTheme.Spacing.md)
    }
}

/// Loading overlay for async operations.
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.md) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(ColorPalette.primary)

                Text(L("common.loading"))
                    .font(Typography.caption1)
                    .foregroundColor(ColorPalette.textSecondary)
            }
            .padding(AppTheme.Spacing.xl)
            .background(ColorPalette.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .shadow(color: Color.black.opacity(0.1), radius: 10)
        }
    }
}

#Preview {
    TodayView(container: DependencyContainer.preview)
}
