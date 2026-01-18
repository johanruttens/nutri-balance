import Foundation

/// Use case for creating a new user during onboarding.
struct CreateUserUseCase {
    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func execute(user: User) async throws -> User {
        try await repository.createUser(user)
    }
}

/// Use case for updating user preferences.
struct UpdateUserPreferencesUseCase {
    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func execute(user: User) async throws -> User {
        try await repository.updateUser(user)
    }

    /// Convenience method for updating specific preferences
    func execute(
        targetCalories: Int? = nil,
        targetProtein: Double? = nil,
        targetCarbs: Double? = nil,
        targetFat: Double? = nil,
        targetWeight: Double? = nil
    ) async throws {
        guard var user = try await repository.getCurrentUser() else {
            throw UserRepositoryError.userNotFound
        }

        if let calories = targetCalories {
            user.dailyCalorieGoal = calories
        }
        if let protein = targetProtein {
            user.targetProtein = protein
        }
        if let carbs = targetCarbs {
            user.targetCarbs = carbs
        }
        if let fat = targetFat {
            user.targetFat = fat
        }
        if let weight = targetWeight {
            user.targetWeight = weight
        }

        _ = try await repository.updateUser(user)
    }

    /// Convenience method for updating profile information
    func execute(
        firstName: String? = nil,
        lastName: String? = nil,
        email: String? = nil,
        height: Double? = nil
    ) async throws {
        guard var user = try await repository.getCurrentUser() else {
            throw UserRepositoryError.userNotFound
        }

        if let firstName = firstName {
            user.firstName = firstName
        }
        if let lastName = lastName {
            user.lastName = lastName
        }
        if email != nil {
            user.email = email
        }
        if let height = height {
            user.height = height
        }

        _ = try await repository.updateUser(user)
    }
}

/// Errors related to user repository operations
enum UserRepositoryError: Error, LocalizedError {
    case userNotFound

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "No user profile found. Please complete onboarding."
        }
    }
}
