import Foundation

/// Protocol defining weight entry data operations.
protocol WeightRepositoryProtocol {
    /// Fetches the most recent weight entry
    func getLatestEntry() async throws -> WeightEntry?

    /// Fetches weight entries for a date range
    func getEntries(from startDate: Date, to endDate: Date) async throws -> [WeightEntry]

    /// Fetches weight entries for the last N days
    func getEntriesForLastDays(_ days: Int) async throws -> [WeightEntry]

    /// Gets weight entry for a specific date
    func getEntry(for date: Date) async throws -> WeightEntry?

    /// Adds a new weight entry
    func addEntry(_ entry: WeightEntry) async throws -> WeightEntry

    /// Updates an existing weight entry
    func updateEntry(_ entry: WeightEntry) async throws -> WeightEntry

    /// Deletes a weight entry
    func deleteEntry(_ entry: WeightEntry) async throws

    /// Calculates weight progress
    func calculateProgress(targetWeight: Double) async throws -> WeightProgress?
}
