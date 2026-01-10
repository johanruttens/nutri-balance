import Foundation
import CoreData

/// Repository implementation for food item data operations.
final class FoodItemRepository: FoodItemRepositoryProtocol {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func getAllItems() async throws -> [FoodItem] {
        try await context.perform {
            let request = CDFoodItem.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \CDFoodItem.name, ascending: true)
            ]
            let items = try self.context.fetch(request)
            return items.map { FoodItemMapper.toDomain($0) }
        }
    }

    func getFavorites() async throws -> [FoodItem] {
        try await context.perform {
            let items = CDFoodItem.fetchFavorites(in: self.context)
            return items.map { FoodItemMapper.toDomain($0) }
        }
    }

    func getRecentItems(limit: Int) async throws -> [FoodItem] {
        try await context.perform {
            let items = CDFoodItem.fetchRecent(limit: limit, in: self.context)
            return items.map { FoodItemMapper.toDomain($0) }
        }
    }

    func getFrequentItems(limit: Int) async throws -> [FoodItem] {
        try await context.perform {
            let items = CDFoodItem.fetchFrequent(limit: limit, in: self.context)
            return items.map { FoodItemMapper.toDomain($0) }
        }
    }

    func searchItems(query: String) async throws -> [FoodItem] {
        try await context.perform {
            let items = CDFoodItem.search(query: query, in: self.context)
            return items.map { FoodItemMapper.toDomain($0) }
        }
    }

    func getItem(id: UUID) async throws -> FoodItem? {
        try await context.perform {
            let request = CDFoodItem.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1

            guard let item = try self.context.fetch(request).first else {
                return nil
            }
            return FoodItemMapper.toDomain(item)
        }
    }

    func addItem(_ item: FoodItem) async throws -> FoodItem {
        try await context.perform {
            let entity = FoodItemMapper.createEntity(item, in: self.context)
            try self.context.save()
            return FoodItemMapper.toDomain(entity)
        }
    }

    func updateItem(_ item: FoodItem) async throws -> FoodItem {
        try await context.perform {
            let request = CDFoodItem.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                throw RepositoryError.notFound
            }

            FoodItemMapper.toEntity(item, entity: entity)
            try self.context.save()
            return FoodItemMapper.toDomain(entity)
        }
    }

    func deleteItem(_ item: FoodItem) async throws {
        try await context.perform {
            let request = CDFoodItem.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                throw RepositoryError.notFound
            }

            self.context.delete(entity)
            try self.context.save()
        }
    }

    func toggleFavorite(_ item: FoodItem) async throws -> FoodItem {
        try await context.perform {
            let request = CDFoodItem.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                throw RepositoryError.notFound
            }

            entity.isFavorite.toggle()
            entity.updatedAt = Date()
            try self.context.save()
            return FoodItemMapper.toDomain(entity)
        }
    }

    func incrementUseCount(_ item: FoodItem) async throws {
        try await context.perform {
            let request = CDFoodItem.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                throw RepositoryError.notFound
            }

            entity.useCount += 1
            entity.lastUsedAt = Date()
            entity.updatedAt = Date()
            try self.context.save()
        }
    }
}
