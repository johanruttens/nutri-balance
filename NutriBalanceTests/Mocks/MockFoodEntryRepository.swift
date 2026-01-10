import Foundation
@testable import NutriBalance

/// Mock implementation of FoodEntryRepositoryProtocol for testing.
final class MockFoodEntryRepository: FoodEntryRepositoryProtocol {
    // MARK: - Stored Data

    var storedEntries: [FoodEntry] = []

    // MARK: - Call Tracking

    var createEntryCalled = false
    var getEntriesCalled = false
    var getEntriesForDateCalled = false
    var updateEntryCalled = false
    var deleteEntryCalled = false
    var getTotalCaloriesCalled = false

    var lastCreatedEntry: FoodEntry?
    var lastUpdatedEntry: FoodEntry?
    var lastDeletedEntryId: UUID?
    var lastQueriedDate: Date?
    var lastQueriedDateRange: (start: Date, end: Date)?

    // MARK: - Error Simulation

    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockError", code: -1)

    // MARK: - FoodEntryRepositoryProtocol

    func createEntry(_ entry: FoodEntry) async throws -> FoodEntry {
        createEntryCalled = true
        if shouldThrowError { throw errorToThrow }
        lastCreatedEntry = entry
        storedEntries.append(entry)
        return entry
    }

    func getEntries(from startDate: Date, to endDate: Date) async throws -> [FoodEntry] {
        getEntriesCalled = true
        if shouldThrowError { throw errorToThrow }
        lastQueriedDateRange = (startDate, endDate)
        return storedEntries.filter { entry in
            entry.date >= startDate && entry.date <= endDate
        }
    }

    func getEntriesForDate(_ date: Date) async throws -> [FoodEntry] {
        getEntriesForDateCalled = true
        if shouldThrowError { throw errorToThrow }
        lastQueriedDate = date
        let calendar = Calendar.current
        return storedEntries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }

    func updateEntry(_ entry: FoodEntry) async throws -> FoodEntry {
        updateEntryCalled = true
        if shouldThrowError { throw errorToThrow }
        lastUpdatedEntry = entry
        if let index = storedEntries.firstIndex(where: { $0.id == entry.id }) {
            storedEntries[index] = entry
        }
        return entry
    }

    func deleteEntry(id: UUID) async throws {
        deleteEntryCalled = true
        if shouldThrowError { throw errorToThrow }
        lastDeletedEntryId = id
        storedEntries.removeAll { $0.id == id }
    }

    func getTotalCalories(from startDate: Date, to endDate: Date) async throws -> Int {
        getTotalCaloriesCalled = true
        if shouldThrowError { throw errorToThrow }
        return storedEntries
            .filter { $0.date >= startDate && $0.date <= endDate }
            .compactMap(\.calories)
            .reduce(0, +)
    }

    // MARK: - Test Helpers

    func reset() {
        storedEntries = []
        createEntryCalled = false
        getEntriesCalled = false
        getEntriesForDateCalled = false
        updateEntryCalled = false
        deleteEntryCalled = false
        getTotalCaloriesCalled = false
        lastCreatedEntry = nil
        lastUpdatedEntry = nil
        lastDeletedEntryId = nil
        lastQueriedDate = nil
        lastQueriedDateRange = nil
        shouldThrowError = false
    }

    func addEntry(_ entry: FoodEntry) {
        storedEntries.append(entry)
    }
}
