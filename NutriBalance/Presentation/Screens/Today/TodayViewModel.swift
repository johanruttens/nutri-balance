import Foundation
import SwiftUI

/// View model for the Today food tracking screen.
@MainActor
final class TodayViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var selectedDate: Date = Date()
    @Published var entries: [FoodEntry] = []
    @Published var calorieGoal: Int = 1800
    @Published var hydrationIntake: Double = 0
    @Published var hydrationGoal: Double = 2000
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedEntry: FoodEntry?

    // MARK: - Computed Properties

    var totalCalories: Int {
        entries.compactMap(\.calories).reduce(0, +)
    }

    var totalProtein: Double {
        entries.compactMap(\.protein).reduce(0, +)
    }

    var totalCarbs: Double {
        entries.compactMap(\.carbs).reduce(0, +)
    }

    var totalFat: Double {
        entries.compactMap(\.fat).reduce(0, +)
    }

    // MARK: - Dependencies

    let container: DependencyContainer

    private var getDailyEntriesUseCase: GetDailyEntriesUseCase {
        container.makeGetDailyEntriesUseCase()
    }

    private var deleteFoodEntryUseCase: DeleteFoodEntryUseCase {
        container.makeDeleteFoodEntryUseCase()
    }

    // MARK: - Initialization

    init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - Public Methods

    func loadEntries() async {
        isLoading = true
        error = nil

        do {
            // Load user preferences
            let userRepository = container.userRepository
            if let user = try await userRepository.getCurrentUser() {
                calorieGoal = user.dailyCalorieGoal
                hydrationGoal = user.dailyWaterGoal
            }

            // Load entries for selected date
            entries = try await getDailyEntriesUseCase.execute(for: selectedDate)

            // Load hydration data for selected date
            let hydrationUseCase = container.makeGetDailyHydrationUseCase()
            let hydrationData = try await hydrationUseCase.execute(for: selectedDate)
            hydrationIntake = hydrationData.totalHydration
        } catch {
            self.error = error
            entries = []
            hydrationIntake = 0
        }

        isLoading = false
    }

    func entriesForCategory(_ category: MealCategory) -> [FoodEntry] {
        entries.filter { $0.mealCategory == category }
    }

    func deleteEntry(_ entry: FoodEntry) async {
        // Store entry for potential undo
        let deletedEntry = entry

        do {
            try await deleteFoodEntryUseCase.execute(entry: entry)
            entries.removeAll { $0.id == entry.id }

            // Show undo toast
            ToastManager.shared.showUndo(L("toast.deleted")) { [weak self] in
                Task { @MainActor in
                    await self?.restoreEntry(deletedEntry)
                }
            }
        } catch {
            self.error = error
            ToastManager.shared.showError()
        }
    }

    private func restoreEntry(_ entry: FoodEntry) async {
        do {
            let addFoodEntryUseCase = container.makeAddFoodEntryUseCase()
            _ = try await addFoodEntryUseCase.execute(entry: entry)
            await loadEntries()
            ToastManager.shared.showSuccess(L("toast.undone"))
        } catch {
            ToastManager.shared.showError()
        }
    }

    func copyFromPreviousDay() async {
        guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) else {
            return
        }

        do {
            let previousEntries = try await getDailyEntriesUseCase.execute(for: previousDate)
            let addFoodEntryUseCase = container.makeAddFoodEntryUseCase()

            for entry in previousEntries {
                let newEntry = FoodEntry(
                    date: selectedDate,
                    mealCategory: entry.mealCategory,
                    foodName: entry.foodName,
                    portionSize: entry.portionSize,
                    portionUnit: entry.portionUnit,
                    calories: entry.calories,
                    protein: entry.protein,
                    carbs: entry.carbs,
                    fat: entry.fat,
                    fiber: entry.fiber,
                    sugar: entry.sugar,
                    notes: entry.notes,
                    linkedFoodItemId: entry.linkedFoodItemId
                )
                _ = try await addFoodEntryUseCase.execute(entry: newEntry)
            }

            await loadEntries()
        } catch {
            self.error = error
        }
    }
}
