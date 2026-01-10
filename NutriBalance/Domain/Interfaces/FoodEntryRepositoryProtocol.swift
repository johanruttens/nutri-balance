import Foundation

/// Protocol defining food entry data operations.
protocol FoodEntryRepositoryProtocol {
    /// Fetches all food entries for a specific date
    func getEntries(for date: Date) async throws -> [FoodEntry]

    /// Fetches food entries for a date range
    func getEntries(from startDate: Date, to endDate: Date) async throws -> [FoodEntry]

    /// Fetches food entries for a specific meal category on a date
    func getEntries(for date: Date, mealCategory: MealCategory) async throws -> [FoodEntry]

    /// Adds a new food entry
    func addEntry(_ entry: FoodEntry) async throws -> FoodEntry

    /// Updates an existing food entry
    func updateEntry(_ entry: FoodEntry) async throws -> FoodEntry

    /// Deletes a food entry
    func deleteEntry(_ entry: FoodEntry) async throws

    /// Deletes all entries for a specific date
    func deleteEntries(for date: Date) async throws

    /// Gets the total calorie count for a date
    func getTotalCalories(for date: Date) async throws -> Int
}
