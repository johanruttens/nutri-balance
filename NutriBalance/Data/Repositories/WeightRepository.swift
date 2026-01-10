import Foundation
import CoreData

/// Repository implementation for weight entry data operations.
final class WeightRepository: WeightRepositoryProtocol {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func getLatestEntry() async throws -> WeightEntry? {
        try await context.perform {
            guard let entry = CDWeightEntry.fetchLatest(in: self.context) else {
                return nil
            }
            return WeightEntryMapper.toDomain(entry)
        }
    }

    func getEntries(from startDate: Date, to endDate: Date) async throws -> [WeightEntry] {
        try await context.perform {
            let entries = CDWeightEntry.fetchEntries(from: startDate, to: endDate, in: self.context)
            return entries.map { WeightEntryMapper.toDomain($0) }
        }
    }

    func getEntriesForLastDays(_ days: Int) async throws -> [WeightEntry] {
        try await context.perform {
            let entries = CDWeightEntry.fetchLastDays(days, in: self.context)
            return entries.map { WeightEntryMapper.toDomain($0) }
        }
    }

    func getEntry(for date: Date) async throws -> WeightEntry? {
        try await context.perform {
            guard let entry = CDWeightEntry.fetchEntry(for: date, in: self.context) else {
                return nil
            }
            return WeightEntryMapper.toDomain(entry)
        }
    }

    func addEntry(_ entry: WeightEntry) async throws -> WeightEntry {
        try await context.perform {
            // Check if entry already exists for this date
            if let existing = CDWeightEntry.fetchEntry(for: entry.date, in: self.context) {
                // Update existing entry
                WeightEntryMapper.toEntity(entry, entity: existing)
                try self.context.save()
                return WeightEntryMapper.toDomain(existing)
            }

            let entity = WeightEntryMapper.createEntity(entry, in: self.context)

            // Link to user if exists
            if let user = CDUser.fetchCurrentUser(in: self.context) {
                entity.user = user
                // Update user's current weight
                user.currentWeight = entry.weight
                user.updatedAt = Date()
            }

            try self.context.save()
            return WeightEntryMapper.toDomain(entity)
        }
    }

    func updateEntry(_ entry: WeightEntry) async throws -> WeightEntry {
        try await context.perform {
            let request = CDWeightEntry.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                throw RepositoryError.notFound
            }

            WeightEntryMapper.toEntity(entry, entity: entity)
            try self.context.save()
            return WeightEntryMapper.toDomain(entity)
        }
    }

    func deleteEntry(_ entry: WeightEntry) async throws {
        try await context.perform {
            let request = CDWeightEntry.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                throw RepositoryError.notFound
            }

            self.context.delete(entity)
            try self.context.save()
        }
    }

    func calculateProgress(targetWeight: Double) async throws -> WeightProgress? {
        try await context.perform {
            let entries = CDWeightEntry.fetchLastDays(90, in: self.context)
            guard !entries.isEmpty else { return nil }

            let domainEntries = entries.map { WeightEntryMapper.toDomain($0) }
            let currentWeight = entries.last?.weight ?? 0
            let startWeight = entries.first?.weight ?? currentWeight

            return WeightProgress(
                currentWeight: currentWeight,
                targetWeight: targetWeight,
                startWeight: startWeight,
                entries: domainEntries
            )
        }
    }
}
