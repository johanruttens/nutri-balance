import SwiftUI

/// Main hydration tracking view.
struct HydrationView: View {
    @StateObject private var viewModel: HydrationViewModel
    @State private var showAddDrink = false
    @State private var showDeleteConfirmation = false
    @State private var entryToDelete: DrinkEntry?
    @State private var entryToEdit: DrinkEntry?

    init(container: DependencyContainer) {
        _viewModel = StateObject(wrappedValue: HydrationViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Daily progress ring
                    HydrationProgressSection(
                        intake: viewModel.dailyIntake,
                        goal: viewModel.dailyGoal,
                        effectiveIntake: viewModel.effectiveHydration
                    )

                    // Quick add buttons
                    QuickAddSection(onAdd: { amount in
                        Task { await viewModel.quickAddWater(amount: amount) }
                    })

                    // Today's drinks
                    if !viewModel.todayEntries.isEmpty {
                        DrinksListSection(
                            entries: viewModel.todayEntries,
                            onEdit: { entry in
                                entryToEdit = entry
                            },
                            onDelete: { entry in
                                entryToDelete = entry
                                showDeleteConfirmation = true
                            }
                        )
                    }

                    // Weekly chart
                    WeeklyHydrationSection(data: viewModel.weeklyData)
                }
                .padding(AppTheme.Spacing.standard)
            }
            .background(ColorPalette.backgroundSecondary)
            .navigationTitle(L("hydration.title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddDrink = true }) {
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
            .sheet(isPresented: $showAddDrink) {
                AddDrinkView(container: viewModel.container) {
                    Task { await viewModel.loadData() }
                }
            }
            .sheet(item: $entryToEdit) { entry in
                AddDrinkView(container: viewModel.container, editingEntry: entry) {
                    Task { await viewModel.loadData() }
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
                Text(String(format: L("common.deleteDrinkMessage"), entry.drinkType.displayName))
            }
        }
    }
}

/// Hydration progress section with ring.
struct HydrationProgressSection: View {
    let intake: Double
    let goal: Double
    let effectiveIntake: Double

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return intake / goal
    }

    private var isComplete: Bool {
        intake >= goal
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Main ring
            ZStack {
                // Background ring
                Circle()
                    .stroke(ColorPalette.water.opacity(0.2), lineWidth: 20)

                // Progress ring
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        ColorPalette.water,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progress)

                // Center content
                VStack(spacing: AppTheme.Spacing.sm) {
                    if isComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(ColorPalette.success)
                    } else {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 32))
                            .foregroundColor(ColorPalette.water)
                    }

                    Text("\(Int(intake))")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(ColorPalette.textPrimary)

                    Text("/ \(Int(goal)) ml")
                        .font(Typography.body)
                        .foregroundColor(ColorPalette.textSecondary)
                }
            }
            .frame(width: 200, height: 200)

            // Status message
            if isComplete {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(L("hydration.goalReached"))
                        .font(Typography.headline)
                        .foregroundColor(ColorPalette.success)
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            } else {
                let remaining = goal - intake
                Text("\(Int(remaining)) ml " + L("hydration.remaining"))
                    .font(Typography.callout)
                    .foregroundColor(ColorPalette.textSecondary)
            }

            // Effective hydration info
            if effectiveIntake != intake {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                    Text(L("hydration.effectiveHydration") + ": \(Int(effectiveIntake)) ml")
                        .font(Typography.caption1)
                }
                .foregroundColor(ColorPalette.textTertiary)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}

/// Quick add buttons section.
struct QuickAddSection: View {
    let onAdd: (Double) -> Void

    private let sizes: [(icon: String, amount: Double, label: String)] = [
        ("drop", 200, "200ml"),
        ("drop.fill", 250, "250ml"),
        ("waterbottle", 500, "500ml"),
        ("waterbottle.fill", 750, "750ml")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(L("hydration.quickAdd"))
                .font(Typography.headline)
                .foregroundColor(ColorPalette.textPrimary)

            HStack(spacing: AppTheme.Spacing.md) {
                ForEach(sizes, id: \.amount) { size in
                    Button(action: { onAdd(size.amount) }) {
                        VStack(spacing: AppTheme.Spacing.sm) {
                            ZStack {
                                Circle()
                                    .fill(ColorPalette.water.opacity(0.15))
                                    .frame(width: 50, height: 50)

                                Image(systemName: size.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(ColorPalette.water)
                            }

                            Text(size.label)
                                .font(Typography.caption1)
                                .foregroundColor(ColorPalette.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.standard)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}

/// Today's drinks list section.
struct DrinksListSection: View {
    let entries: [DrinkEntry]
    let onEdit: (DrinkEntry) -> Void
    let onDelete: (DrinkEntry) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(L("hydration.todaysDrinks"))
                .font(Typography.headline)
                .foregroundColor(ColorPalette.textPrimary)

            VStack(spacing: 0) {
                ForEach(entries) { entry in
                    DrinkEntryRow(entry: entry)
                        .swipeActions(edge: .leading) {
                            Button {
                                onEdit(entry)
                            } label: {
                                Label(L("common.edit"), systemImage: "pencil")
                            }
                            .tint(ColorPalette.primary)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                onDelete(entry)
                            } label: {
                                Label(L("common.delete"), systemImage: "trash")
                            }
                        }

                    if entry.id != entries.last?.id {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }
            .background(ColorPalette.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
    }
}

/// Single drink entry row.
struct DrinkEntryRow: View {
    let entry: DrinkEntry

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(entry.drinkType.color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: entry.drinkType.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(entry.drinkType.color)
            }

            // Info
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(entry.drinkType.displayName)
                    .font(Typography.body)
                    .foregroundColor(ColorPalette.textPrimary)

                Text(LDate(entry.date, style: .time))
                    .font(Typography.caption1)
                    .foregroundColor(ColorPalette.textSecondary)
            }

            Spacer()

            // Amount
            VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                Text("\(Int(entry.amount)) ml")
                    .font(Typography.numberSmall)
                    .foregroundColor(ColorPalette.textPrimary)

                if entry.effectiveHydration != entry.amount {
                    Text("≈ \(Int(entry.effectiveHydration)) ml")
                        .font(Typography.caption2)
                        .foregroundColor(ColorPalette.textTertiary)
                }
            }
        }
        .padding(AppTheme.Spacing.md)
    }
}

/// Weekly hydration chart section.
struct WeeklyHydrationSection: View {
    let data: [DailyHydrationData]

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(L("hydration.thisWeek"))
                .font(Typography.headline)
                .foregroundColor(ColorPalette.textPrimary)

            if data.isEmpty {
                Text(L("hydration.noData"))
                    .font(Typography.body)
                    .foregroundColor(ColorPalette.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                HydrationBarChart(data: data, goal: 2500)
                    .frame(height: 150)
            }
        }
        .padding(AppTheme.Spacing.standard)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}

/// Add drink view.
struct AddDrinkView: View {
    let container: DependencyContainer
    let editingEntry: DrinkEntry?
    let onComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: DrinkType = .water
    @State private var amount: Double = 250
    @State private var isSaving = false

    init(container: DependencyContainer, editingEntry: DrinkEntry? = nil, onComplete: @escaping () -> Void) {
        self.container = container
        self.editingEntry = editingEntry
        self.onComplete = onComplete
        if let entry = editingEntry {
            _selectedType = State(initialValue: entry.drinkType)
            _amount = State(initialValue: entry.amount)
        }
    }

    private var isEditing: Bool {
        editingEntry != nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Drink type selector
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        Text(L("hydration.drinkType"))
                            .font(Typography.headline)
                            .foregroundColor(ColorPalette.textPrimary)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: AppTheme.Spacing.md) {
                            ForEach(DrinkType.allCases) { type in
                                DrinkTypeButton(
                                    type: type,
                                    isSelected: selectedType == type,
                                    action: { selectedType = type }
                                )
                            }
                        }
                    }

                    // Amount selector
                    VStack(spacing: AppTheme.Spacing.lg) {
                        Text(L("hydration.amount"))
                            .font(Typography.headline)
                            .foregroundColor(ColorPalette.textPrimary)

                        // Amount display
                        HStack {
                            Button(action: { amount = max(50, amount - 50) }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(ColorPalette.water)
                            }

                            Text("\(Int(amount))")
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .foregroundColor(ColorPalette.textPrimary)
                                .frame(width: 150)

                            Button(action: { amount = min(2000, amount + 50) }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(ColorPalette.water)
                            }
                        }

                        Text("ml")
                            .font(Typography.title3)
                            .foregroundColor(ColorPalette.textSecondary)

                        // Quick amount buttons
                        HStack(spacing: AppTheme.Spacing.sm) {
                            ForEach([150, 200, 250, 500], id: \.self) { quickAmount in
                                Button(action: { amount = Double(quickAmount) }) {
                                    Text("\(quickAmount)")
                                        .font(Typography.caption1)
                                        .foregroundColor(Int(amount) == quickAmount ? .white : ColorPalette.water)
                                        .padding(.horizontal, AppTheme.Spacing.md)
                                        .padding(.vertical, AppTheme.Spacing.sm)
                                        .background(Int(amount) == quickAmount ? ColorPalette.water : ColorPalette.water.opacity(0.15))
                                        .cornerRadius(AppTheme.CornerRadius.small)
                                }
                            }
                        }
                    }

                    // Effective hydration info
                    if selectedType.hydrationFactor != 1.0 {
                        HStack {
                            Image(systemName: "info.circle")
                            Text(L("hydration.effectiveNote") + ": \(Int(amount * selectedType.hydrationFactor)) ml")
                        }
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.textTertiary)
                        .padding()
                        .background(ColorPalette.inputBackground)
                        .cornerRadius(AppTheme.CornerRadius.small)
                    }

                    // Add/Save button
                    PrimaryButton(
                        title: isEditing ? L("common.save") : L("hydration.addDrink"),
                        action: saveDrink,
                        isLoading: isSaving
                    )
                }
                .padding(AppTheme.Spacing.standard)
            }
            .background(ColorPalette.backgroundSecondary)
            .navigationTitle(isEditing ? L("hydration.editDrink") : L("hydration.addDrink"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("common.cancel")) {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveDrink() {
        isSaving = true

        Task {
            if let existingEntry = editingEntry {
                // Update existing entry
                var updatedEntry = existingEntry
                updatedEntry.drinkType = selectedType
                updatedEntry.amount = amount
                updatedEntry.updatedAt = Date()

                let useCase = container.makeUpdateDrinkUseCase()
                try? await useCase.execute(entry: updatedEntry)
                ToastManager.shared.showSuccess(L("toast.updated"))
            } else {
                // Create new entry
                let entry = DrinkEntry(
                    id: UUID(),
                    date: Date(),
                    drinkType: selectedType,
                    amount: amount,
                    createdAt: Date(),
                    updatedAt: Date()
                )

                let useCase = container.makeLogDrinkUseCase()
                try? await useCase.execute(entry: entry)
                ToastManager.shared.showSuccess(L("toast.added"))
            }

            isSaving = false
            onComplete()
            dismiss()
        }
    }
}

/// Drink type selection button.
struct DrinkTypeButton: View {
    let type: DrinkType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(isSelected ? type.color : type.color.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: type.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : type.color)
                }

                Text(type.displayName)
                    .font(Typography.caption1)
                    .foregroundColor(isSelected ? type.color : ColorPalette.textSecondary)
            }
            .padding(AppTheme.Spacing.sm)
            .background(isSelected ? type.color.opacity(0.1) : Color.clear)
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
    }
}

#Preview {
    HydrationView(container: DependencyContainer.preview)
}
