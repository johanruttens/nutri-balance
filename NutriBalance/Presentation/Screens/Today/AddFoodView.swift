import SwiftUI

/// View for adding a new food entry.
struct AddFoodView: View {
    @StateObject private var viewModel: AddFoodViewModel
    @Environment(\.dismiss) private var dismiss

    let onComplete: () -> Void

    init(container: DependencyContainer, mealCategory: MealCategory, date: Date, onComplete: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: AddFoodViewModel(
            container: container,
            mealCategory: mealCategory,
            date: date
        ))
        self.onComplete = onComplete
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Search bar
                    SearchField(
                        text: $viewModel.searchQuery,
                        placeholder: String(localized: "food.searchPlaceholder"),
                        onSubmit: { Task { await viewModel.search() } }
                    )

                    // Meal category selector
                    MealCategoryPicker(selection: $viewModel.selectedCategory)

                    // Recent foods
                    if viewModel.searchQuery.isEmpty && !viewModel.recentFoods.isEmpty {
                        FoodSectionView(
                            title: String(localized: "food.recent"),
                            foods: viewModel.recentFoods,
                            onSelect: { food in viewModel.selectFood(food) }
                        )
                    }

                    // Favorites
                    if viewModel.searchQuery.isEmpty && !viewModel.favorites.isEmpty {
                        FoodSectionView(
                            title: String(localized: "food.favorites"),
                            foods: viewModel.favorites,
                            onSelect: { food in viewModel.selectFood(food) }
                        )
                    }

                    // Search results
                    if !viewModel.searchQuery.isEmpty {
                        if viewModel.searchResults.isEmpty && !viewModel.isSearching {
                            EmptyStateView(
                                icon: "magnifyingglass",
                                title: String(localized: "food.noResults"),
                                message: String(localized: "food.noResultsMessage"),
                                actionTitle: String(localized: "food.createCustom"),
                                action: { viewModel.showCustomFood = true }
                            )
                        } else {
                            FoodSectionView(
                                title: String(localized: "food.searchResults"),
                                foods: viewModel.searchResults,
                                onSelect: { food in viewModel.selectFood(food) }
                            )
                        }
                    }

                    // Create custom food button
                    SecondaryButton(
                        title: String(localized: "food.createCustom"),
                        action: { viewModel.showCustomFood = true }
                    )
                }
                .padding(AppTheme.Spacing.standard)
            }
            .background(ColorPalette.backgroundSecondary)
            .navigationTitle(String(localized: "food.addTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadInitialData()
            }
            .sheet(item: $viewModel.selectedFood) { food in
                PortionSelectionView(
                    food: food,
                    mealCategory: viewModel.selectedCategory,
                    date: viewModel.date,
                    container: viewModel.container
                ) {
                    onComplete()
                    dismiss()
                }
            }
            .sheet(isPresented: $viewModel.showCustomFood) {
                CustomFoodView(container: viewModel.container) { food in
                    viewModel.selectedFood = food
                }
            }
        }
    }
}

/// Meal category horizontal picker.
struct MealCategoryPicker: View {
    @Binding var selection: MealCategory

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(MealCategory.allCases) { category in
                    Button(action: { selection = category }) {
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: category.icon)
                                .font(.system(size: 12))

                            Text(category.displayName)
                                .font(Typography.caption1)
                        }
                        .foregroundColor(selection == category ? .white : category.color)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(selection == category ? category.color : category.color.opacity(0.15))
                        .cornerRadius(AppTheme.CornerRadius.small)
                    }
                }
            }
        }
    }
}

/// Food section with title and list.
struct FoodSectionView: View {
    let title: String
    let foods: [FoodItem]
    let onSelect: (FoodItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(title)
                .font(Typography.headline)
                .foregroundColor(ColorPalette.textPrimary)

            VStack(spacing: 0) {
                ForEach(foods) { food in
                    Button(action: { onSelect(food) }) {
                        FoodItemRow(food: food)
                    }

                    if food.id != foods.last?.id {
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

/// Single food item row.
struct FoodItemRow: View {
    let food: FoodItem

    private var displayCalories: Int? {
        food.calories(for: food.defaultServingSize, unit: food.defaultServingUnit)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(food.name)
                    .font(Typography.body)
                    .foregroundColor(ColorPalette.textPrimary)

                if let brand = food.brand {
                    Text(brand)
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.textSecondary)
                }

                Text("\(Int(food.defaultServingSize)) \(food.defaultServingUnit.displayName)")
                    .font(Typography.caption2)
                    .foregroundColor(ColorPalette.textTertiary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                if let calories = displayCalories {
                    Text("\(calories)")
                        .font(Typography.numberSmall)
                        .foregroundColor(ColorPalette.textPrimary)
                    + Text(" kcal")
                        .font(Typography.caption2)
                        .foregroundColor(ColorPalette.textSecondary)
                }

                if food.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundColor(ColorPalette.error)
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .contentShape(Rectangle())
    }
}

/// Portion selection view.
struct PortionSelectionView: View {
    let food: FoodItem
    let mealCategory: MealCategory
    let date: Date
    let container: DependencyContainer
    let onComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var portionSize: Double
    @State private var portionUnit: PortionUnit
    @State private var isSaving = false

    init(food: FoodItem, mealCategory: MealCategory, date: Date, container: DependencyContainer, onComplete: @escaping () -> Void) {
        self.food = food
        self.mealCategory = mealCategory
        self.date = date
        self.container = container
        self.onComplete = onComplete
        _portionSize = State(initialValue: food.defaultServingSize)
        _portionUnit = State(initialValue: food.defaultServingUnit)
    }

    private var scaledCalories: Int {
        food.calories(for: portionSize, unit: portionUnit) ?? 0
    }

    private var scaledProtein: Double {
        food.protein(for: portionSize, unit: portionUnit) ?? 0
    }

    private var scaledCarbs: Double {
        food.carbs(for: portionSize, unit: portionUnit) ?? 0
    }

    private var scaledFat: Double {
        food.fat(for: portionSize, unit: portionUnit) ?? 0
    }

    private var scaledFiber: Double? {
        guard let fiberPer100 = food.fiberPer100 else { return nil }
        return fiberPer100 * portionSize / 100.0
    }

    private var scaledSugar: Double? {
        guard let sugarPer100 = food.sugarPer100 else { return nil }
        return sugarPer100 * portionSize / 100.0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Food info
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Text(food.name)
                            .font(Typography.title2)
                            .foregroundColor(ColorPalette.textPrimary)

                        if let brand = food.brand {
                            Text(brand)
                                .font(Typography.body)
                                .foregroundColor(ColorPalette.textSecondary)
                        }
                    }

                    // Portion picker
                    PortionPicker(size: $portionSize, unit: $portionUnit)

                    // Nutrition preview
                    VStack(spacing: AppTheme.Spacing.md) {
                        Text("\(scaledCalories)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(ColorPalette.textPrimary)
                        + Text(" kcal")
                            .font(Typography.title3)
                            .foregroundColor(ColorPalette.textSecondary)

                        HStack(spacing: AppTheme.Spacing.xl) {
                            NutrientLabel(name: "Protein", value: scaledProtein, color: .red.opacity(0.8))
                            NutrientLabel(name: "Carbs", value: scaledCarbs, color: .orange.opacity(0.8))
                            NutrientLabel(name: "Fat", value: scaledFat, color: .yellow.opacity(0.8))
                        }
                    }
                    .padding(AppTheme.Spacing.lg)
                    .background(ColorPalette.cardBackground)
                    .cornerRadius(AppTheme.CornerRadius.large)

                    // Add button
                    PrimaryButton(
                        title: String(localized: "common.add"),
                        isLoading: isSaving,
                        action: addEntry
                    )
                }
                .padding(AppTheme.Spacing.standard)
            }
            .background(ColorPalette.backgroundSecondary)
            .navigationTitle(String(localized: "food.portion"))
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

    private func addEntry() {
        isSaving = true

        Task {
            let entry = FoodEntry(
                date: date,
                mealCategory: mealCategory,
                foodName: food.name,
                portionSize: portionSize,
                portionUnit: portionUnit,
                calories: scaledCalories,
                protein: scaledProtein,
                carbs: scaledCarbs,
                fat: scaledFat,
                fiber: scaledFiber,
                sugar: scaledSugar,
                linkedFoodItemId: food.id
            )

            let useCase = container.makeAddFoodEntryUseCase()
            try? await useCase.execute(entry: entry)

            isSaving = false
            onComplete()
            dismiss()
        }
    }
}

struct NutrientLabel: View {
    let name: String
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

            Text(name)
                .font(Typography.caption2)
                .foregroundColor(ColorPalette.textSecondary)

            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 30, height: 4)
        }
    }
}

/// Custom food creation view.
struct CustomFoodView: View {
    let container: DependencyContainer
    let onCreated: (FoodItem) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var brand = ""
    @State private var caloriesPer100: Double = 0
    @State private var proteinPer100: Double = 0
    @State private var carbsPer100: Double = 0
    @State private var fatPer100: Double = 0
    @State private var defaultServingSize: Double = 100
    @State private var defaultServingUnit: PortionUnit = .grams
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledTextField(
                        label: String(localized: "food.name"),
                        text: $name,
                        placeholder: "e.g., Banana",
                        isRequired: true
                    )

                    LabeledTextField(
                        label: String(localized: "food.brand"),
                        text: $brand,
                        placeholder: String(localized: "food.brandOptional")
                    )
                }

                Section(header: Text(String(localized: "food.nutrition")), footer: Text("Values per 100g/100ml")) {
                    NumberInputField(title: "Calories", value: $caloriesPer100, unit: "kcal", step: 10)
                    NumberInputField(title: "Protein", value: $proteinPer100, unit: "g", step: 1, decimalPlaces: 1)
                    NumberInputField(title: "Carbs", value: $carbsPer100, unit: "g", step: 1, decimalPlaces: 1)
                    NumberInputField(title: "Fat", value: $fatPer100, unit: "g", step: 1, decimalPlaces: 1)
                }

                Section(String(localized: "food.serving")) {
                    NumberInputField(title: "Size", value: $defaultServingSize, step: 10)
                    Picker("Unit", selection: $defaultServingUnit) {
                        ForEach(PortionUnit.allCases) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "food.createCustom"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "common.save")) {
                        saveFood()
                    }
                    .disabled(name.isEmpty || isSaving)
                }
            }
        }
    }

    private func saveFood() {
        isSaving = true

        let food = FoodItem(
            name: name,
            brand: brand.isEmpty ? nil : brand,
            caloriesPer100: caloriesPer100,
            proteinPer100: proteinPer100,
            carbsPer100: carbsPer100,
            fatPer100: fatPer100,
            defaultServingSize: defaultServingSize,
            defaultServingUnit: defaultServingUnit,
            isFavorite: true
        )

        Task {
            let useCase = container.makeAddToFavoritesUseCase()
            try? await useCase.execute(foodItem: food)

            isSaving = false
            onCreated(food)
            dismiss()
        }
    }
}

/// Food entry detail view for editing.
struct FoodEntryDetailView: View {
    let entry: FoodEntry
    let container: DependencyContainer
    let onUpdate: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Entry details
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Text(entry.foodName)
                            .font(Typography.title2)
                            .foregroundColor(ColorPalette.textPrimary)

                        HStack {
                            Image(systemName: entry.mealCategory.icon)
                            Text(entry.mealCategory.displayName)
                        }
                        .font(Typography.callout)
                        .foregroundColor(entry.mealCategory.color)
                    }

                    // Nutrition info
                    VStack(spacing: AppTheme.Spacing.md) {
                        if let calories = entry.calories {
                            Text("\(calories)")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(ColorPalette.textPrimary)
                            + Text(" kcal")
                                .font(Typography.title3)
                                .foregroundColor(ColorPalette.textSecondary)
                        }

                        HStack(spacing: AppTheme.Spacing.xl) {
                            NutrientLabel(name: "Protein", value: entry.protein ?? 0, color: .red.opacity(0.8))
                            NutrientLabel(name: "Carbs", value: entry.carbs ?? 0, color: .orange.opacity(0.8))
                            NutrientLabel(name: "Fat", value: entry.fat ?? 0, color: .yellow.opacity(0.8))
                        }
                    }
                    .padding(AppTheme.Spacing.lg)
                    .background(ColorPalette.cardBackground)
                    .cornerRadius(AppTheme.CornerRadius.large)

                    // Portion info
                    HStack {
                        Text("Portion:")
                            .font(Typography.body)
                            .foregroundColor(ColorPalette.textSecondary)

                        Text(entry.portionString)
                            .font(Typography.body)
                            .foregroundColor(ColorPalette.textPrimary)
                    }

                    // Notes if available
                    if let notes = entry.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text("Notes")
                                .font(Typography.caption1)
                                .foregroundColor(ColorPalette.textSecondary)
                            Text(notes)
                                .font(Typography.body)
                                .foregroundColor(ColorPalette.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(AppTheme.Spacing.md)
                        .background(ColorPalette.cardBackground)
                        .cornerRadius(AppTheme.CornerRadius.medium)
                    }

                    Spacer()
                }
                .padding(AppTheme.Spacing.standard)
            }
            .background(ColorPalette.backgroundSecondary)
            .navigationTitle(String(localized: "food.details"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.close")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddFoodView(
        container: DependencyContainer.preview,
        mealCategory: .lunch,
        date: Date()
    ) {}
}
