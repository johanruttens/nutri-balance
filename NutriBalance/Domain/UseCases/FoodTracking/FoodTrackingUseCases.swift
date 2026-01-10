import Foundation

/// Use case for adding a food entry.
struct AddFoodEntryUseCase {
    private let repository: FoodEntryRepositoryProtocol

    init(repository: FoodEntryRepositoryProtocol) {
        self.repository = repository
    }

    func execute(entry: FoodEntry) async throws -> FoodEntry {
        try await repository.addEntry(entry)
    }
}

/// Use case for getting daily food entries.
struct GetDailyEntriesUseCase {
    private let repository: FoodEntryRepositoryProtocol

    init(repository: FoodEntryRepositoryProtocol) {
        self.repository = repository
    }

    func execute(for date: Date) async throws -> [FoodEntry] {
        try await repository.getEntries(for: date)
    }

    func execute(for date: Date, mealCategory: MealCategory) async throws -> [FoodEntry] {
        try await repository.getEntries(for: date, mealCategory: mealCategory)
    }
}

/// Use case for updating a food entry.
struct UpdateFoodEntryUseCase {
    private let repository: FoodEntryRepositoryProtocol

    init(repository: FoodEntryRepositoryProtocol) {
        self.repository = repository
    }

    func execute(entry: FoodEntry) async throws -> FoodEntry {
        try await repository.updateEntry(entry)
    }
}

/// Use case for deleting a food entry.
struct DeleteFoodEntryUseCase {
    private let repository: FoodEntryRepositoryProtocol

    init(repository: FoodEntryRepositoryProtocol) {
        self.repository = repository
    }

    func execute(entry: FoodEntry) async throws {
        try await repository.deleteEntry(entry)
    }
}
