import Foundation
@testable import NutriBalance

/// Mock implementation of UserRepositoryProtocol for testing.
final class MockUserRepository: UserRepositoryProtocol {
    // MARK: - Stored Data

    var storedUser: User?

    // MARK: - Call Tracking

    var getUserCalled = false
    var createUserCalled = false
    var updateUserCalled = false
    var deleteUserCalled = false

    var lastCreatedUser: User?
    var lastUpdatedUser: User?

    // MARK: - Error Simulation

    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockError", code: -1)

    // MARK: - UserRepositoryProtocol

    func getUser() async throws -> User? {
        getUserCalled = true
        if shouldThrowError { throw errorToThrow }
        return storedUser
    }

    func createUser(_ user: User) async throws -> User {
        createUserCalled = true
        if shouldThrowError { throw errorToThrow }
        lastCreatedUser = user
        storedUser = user
        return user
    }

    func updateUser(_ user: User) async throws -> User {
        updateUserCalled = true
        if shouldThrowError { throw errorToThrow }
        lastUpdatedUser = user
        storedUser = user
        return user
    }

    func deleteUser() async throws {
        deleteUserCalled = true
        if shouldThrowError { throw errorToThrow }
        storedUser = nil
    }

    // MARK: - Test Helpers

    func reset() {
        storedUser = nil
        getUserCalled = false
        createUserCalled = false
        updateUserCalled = false
        deleteUserCalled = false
        lastCreatedUser = nil
        lastUpdatedUser = nil
        shouldThrowError = false
    }
}
