import Foundation

/// Use case for logging a drink entry.
struct LogDrinkUseCase {
    private let repository: DrinkEntryRepositoryProtocol

    init(repository: DrinkEntryRepositoryProtocol) {
        self.repository = repository
    }

    func execute(entry: DrinkEntry) async throws -> DrinkEntry {
        try await repository.addEntry(entry)
    }
}

/// Use case for getting daily hydration data.
struct GetDailyHydrationUseCase {
    private let repository: DrinkEntryRepositoryProtocol

    init(repository: DrinkEntryRepositoryProtocol) {
        self.repository = repository
    }

    func execute(for date: Date) async throws -> (entries: [DrinkEntry], totalHydration: Double) {
        let entries = try await repository.getEntries(for: date)
        let totalHydration = try await repository.getTotalHydration(for: date)
        return (entries, totalHydration)
    }
}
