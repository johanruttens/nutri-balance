import SwiftUI

/// Main today view showing daily food log by meal category.
struct TodayView: View {
    @StateObject private var viewModel: TodayViewModel
    @State private var selectedMealCategory: MealCategory?
    @State private var showAddFood = false

    init(container: DependencyContainer) {
        _viewModel = StateObject(wrappedValue: TodayViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
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
                                Task { await viewModel.deleteEntry(entry) }
                            }
                        )
                    }
                }
                .padding(AppTheme.Spacing.standard)
            }
            .background(ColorPalette.backgroundSecondary)
            .navigationTitle(String(localized: "today.title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddFood = true }) {
                        Image(systemName: "plus")
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
        }
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
                    Text(String(localized: "common.today"))
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.primary)
                }

                Text(selectedDate, format: .dateTime.weekday(.wide).month().day())
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
                MacroRow(name: "Protein", value: protein, color: .red.opacity(0.8))
                MacroRow(name: "Carbs", value: carbs, color: .orange.opacity(0.8))
                MacroRow(name: "Fat", value: fat, color: .yellow.opacity(0.8))
            }

            Spacer()

            // Remaining
            VStack(spacing: AppTheme.Spacing.xs) {
                Text("\(remaining)")
                    .font(Typography.numberMedium)
                    .foregroundColor(consumed > goal ? ColorPalette.error : ColorPalette.success)
                Text("remaining")
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
                    Image(systemName: category.icon)
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
                                    Label(String(localized: "common.delete"), systemImage: "trash")
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
                Text("Tap to add \(category.displayName.lowercased())")
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

#Preview {
    TodayView(container: DependencyContainer.preview)
}
