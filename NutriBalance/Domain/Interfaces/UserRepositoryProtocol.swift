import Foundation

/// Protocol defining user data operations.
protocol UserRepositoryProtocol {
    /// Fetches the current user
    func getCurrentUser() async throws -> User?

    /// Creates a new user
    func createUser(_ user: User) async throws -> User

    /// Updates an existing user
    func updateUser(_ user: User) async throws -> User

    /// Deletes the current user and all associated data
    func deleteUser() async throws
}
