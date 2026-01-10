import Foundation
import CoreData

/// Repository implementation for food entry data operations.
final class FoodEntryRepository: FoodEntryRepositoryProtocol {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func getEntries(for date: Date) async throws -> [FoodEntry] {
        try await context.perform {
            let entries = CDFoodEntry.fetchEntries(for: date, in: self.context)
            return entries.map { FoodEntryMapper.toDomain($0) }
        }
    }

    func getEntries(from startDate: Date, to endDate: Date) async throws -> [FoodEntry] {
        try await context.perform {
            let entries = CDFoodEntry.fetchEntries(from: startDate, to: endDate, in: self.context)
            return entries.map { FoodEntryMapper.toDomain($0) }
        }
    }

    func getEntries(for date: Date, mealCategory: MealCategory) async throws -> [FoodEntry] {
        try await context.perform {
            let entries = CDFoodEntry.fetchEntries(
                for: date,
                mealCategory: mealCategory.rawValue,
                in: self.context
            )
            return entries.map { FoodEntryMapper.toDomain($0) }
        }
    }

    func addEntry(_ entry: FoodEntry) async throws -> FoodEntry {
        try await context.perform {
            let entity = FoodEntryMapper.createEntity(entry, in: self.context)

            // Link to user if exists
            if let user = CDUser.fetchCurrentUser(in: self.context) {
                entity.user = user
            }

            // Link to food item if specified
            if let foodItemId = entry.linkedFoodItemId {
                let request = CDFoodItem.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", foodItemId as CVarArg)
                request.fetchLimit = 1

                if let foodItem = try self.context.fetch(request).first {
                    entity.linkedFoodItem = foodItem
                    // Increment use count
                    foodItem.useCount += 1
                    foodItem.lastUsedAt = Date()
                }
            }

            try self.context.save()
            return FoodEntryMapper.toDomain(entity)
        }
    }

    func updateEntry(_ entry: FoodEntry) async throws -> FoodEntry {
        try await context.perform {
            let request = CDFoodEntry.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                throw RepositoryError.notFound
            }

            FoodEntryMapper.toEntity(entry, entity: entity)
            try self.context.save()
            return FoodEntryMapper.toDomain(entity)
        }
    }

    func deleteEntry(_ entry: FoodEntry) async throws {
        try await context.perform {
            let request = CDFoodEntry.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                throw RepositoryError.notFound
            }

            self.context.delete(entity)
            try self.context.save()
        }
    }

    func deleteEntries(for date: Date) async throws {
        try await context.perform {
            let entries = CDFoodEntry.fetchEntries(for: date, in: self.context)
            for entry in entries {
                self.context.delete(entry)
            }
            try self.context.save()
        }
    }

    func getTotalCalories(for date: Date) async throws -> Int {
        try await context.perform {
            let entries = CDFoodEntry.fetchEntries(for: date, in: self.context)
            return entries.compactMap { $0.calories?.intValue }.reduce(0, +)
        }
    }
}
