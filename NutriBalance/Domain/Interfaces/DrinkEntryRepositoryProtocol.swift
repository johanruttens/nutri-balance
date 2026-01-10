import Foundation

/// Protocol defining drink entry data operations.
protocol DrinkEntryRepositoryProtocol {
    /// Fetches all drink entries for a specific date
    func getEntries(for date: Date) async throws -> [DrinkEntry]

    /// Fetches drink entries for a date range
    func getEntries(from startDate: Date, to endDate: Date) async throws -> [DrinkEntry]

    /// Adds a new drink entry
    func addEntry(_ entry: DrinkEntry) async throws -> DrinkEntry

    /// Updates an existing drink entry
    func updateEntry(_ entry: DrinkEntry) async throws -> DrinkEntry

    /// Deletes a drink entry
    func deleteEntry(_ entry: DrinkEntry) async throws

    /// Gets total water intake for a date (considering hydration factors)
    func getTotalHydration(for date: Date) async throws -> Double

    /// Gets total caffeine intake for a date
    func getTotalCaffeine(for date: Date) async throws -> Double
}
