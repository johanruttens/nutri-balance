import Foundation

/// Use case for logging a weight entry.
struct LogWeightUseCase {
    private let repository: WeightRepositoryProtocol

    init(repository: WeightRepositoryProtocol) {
        self.repository = repository
    }

    func execute(entry: WeightEntry) async throws -> WeightEntry {
        try await repository.addEntry(entry)
    }
}

/// Use case for getting weight history.
struct GetWeightHistoryUseCase {
    private let repository: WeightRepositoryProtocol

    init(repository: WeightRepositoryProtocol) {
        self.repository = repository
    }

    func execute(days: Int = 30) async throws -> [WeightEntry] {
        try await repository.getEntriesForLastDays(days)
    }

    func execute(from startDate: Date, to endDate: Date) async throws -> [WeightEntry] {
        try await repository.getEntries(from: startDate, to: endDate)
    }
}

/// Use case for calculating weight progress.
struct CalculateProgressUseCase {
    private let weightRepository: WeightRepositoryProtocol
    private let userRepository: UserRepositoryProtocol

    init(weightRepository: WeightRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.weightRepository = weightRepository
        self.userRepository = userRepository
    }

    func execute() async throws -> WeightProgress? {
        guard let user = try await userRepository.getCurrentUser() else {
            return nil
        }
        return try await weightRepository.calculateProgress(targetWeight: user.targetWeight)
    }
}
