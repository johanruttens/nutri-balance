import Foundation
import CoreData

/// Repository implementation for drink entry data operations.
final class DrinkEntryRepository: DrinkEntryRepositoryProtocol {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func getEntries(for date: Date) async throws -> [DrinkEntry] {
        try await context.perform {
            let entries = CDDrinkEntry.fetchEntries(for: date, in: self.context)
            return entries.map { DrinkEntryMapper.toDomain($0) }
        }
    }

    func getEntries(from startDate: Date, to endDate: Date) async throws -> [DrinkEntry] {
        try await context.perform {
            let entries = CDDrinkEntry.fetchEntries(from: startDate, to: endDate, in: self.context)
            return entries.map { DrinkEntryMapper.toDomain($0) }
        }
    }

    func addEntry(_ entry: DrinkEntry) async throws -> DrinkEntry {
        try await context.perform {
            let entity = DrinkEntryMapper.createEntity(entry, in: self.context)

            // Link to user if exists
            if let user = CDUser.fetchCurrentUser(in: self.context) {
                entity.user = user
            }

            try self.context.save()
            return DrinkEntryMapper.toDomain(entity)
        }
    }

    func updateEntry(_ entry: DrinkEntry) async throws -> DrinkEntry {
        try await context.perform {
            let request = CDDrinkEntry.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                throw RepositoryError.notFound
            }

            DrinkEntryMapper.toEntity(entry, entity: entity)
            try self.context.save()
            return DrinkEntryMapper.toDomain(entity)
        }
    }

    func deleteEntry(_ entry: DrinkEntry) async throws {
        try await context.perform {
            let request = CDDrinkEntry.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                throw RepositoryError.notFound
            }

            self.context.delete(entity)
            try self.context.save()
        }
    }

    func getTotalHydration(for date: Date) async throws -> Double {
        try await context.perform {
            CDDrinkEntry.totalWaterIntake(for: date, in: self.context)
        }
    }

    func getTotalCaffeine(for date: Date) async throws -> Double {
        try await context.perform {
            let entries = CDDrinkEntry.fetchEntries(for: date, in: self.context)
            return entries.compactMap { $0.caffeineContent?.doubleValue }.reduce(0, +)
        }
    }
}
