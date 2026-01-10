import Foundation
import CoreData

/// Repository implementation for user data operations.
final class UserRepository: UserRepositoryProtocol {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func getCurrentUser() async throws -> User? {
        try await context.perform {
            guard let cdUser = CDUser.fetchCurrentUser(in: self.context) else {
                return nil
            }
            return UserMapper.toDomain(cdUser)
        }
    }

    func createUser(_ user: User) async throws -> User {
        try await context.perform {
            let entity = UserMapper.createEntity(user, in: self.context)
            try self.context.save()
            return UserMapper.toDomain(entity)
        }
    }

    func updateUser(_ user: User) async throws -> User {
        try await context.perform {
            let request = CDUser.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", user.id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                throw RepositoryError.notFound
            }

            UserMapper.toEntity(user, entity: entity)
            try self.context.save()
            return UserMapper.toDomain(entity)
        }
    }

    func deleteUser() async throws {
        try await context.perform {
            guard let user = CDUser.fetchCurrentUser(in: self.context) else {
                throw RepositoryError.notFound
            }

            self.context.delete(user)
            try self.context.save()
        }
    }
}

// MARK: - Repository Errors

enum RepositoryError: LocalizedError {
    case notFound
    case saveFailed
    case invalidData

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "The requested item was not found."
        case .saveFailed:
            return "Failed to save changes."
        case .invalidData:
            return "The data is invalid."
        }
    }
}
