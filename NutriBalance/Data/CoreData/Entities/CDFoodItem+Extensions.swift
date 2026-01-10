import Foundation
import CoreData

/// Core Data managed object for FoodItem entity.
@objc(CDFoodItem)
public class CDFoodItem: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var brand: String?
    @NSManaged public var caloriesPer100: NSNumber?
    @NSManaged public var proteinPer100: NSNumber?
    @NSManaged public var carbsPer100: NSNumber?
    @NSManaged public var fatPer100: NSNumber?
    @NSManaged public var fiberPer100: NSNumber?
    @NSManaged public var sugarPer100: NSNumber?
    @NSManaged public var defaultServingSize: Double
    @NSManaged public var defaultServingUnit: String
    @NSManaged public var category: String?
    @NSManaged public var tags: [String]?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var useCount: Int32
    @NSManaged public var lastUsedAt: Date?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    // Relationships
    @NSManaged public var entries: NSSet?
    @NSManaged public var templates: NSSet?
}

// MARK: - Fetch Requests

extension CDFoodItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDFoodItem> {
        return NSFetchRequest<CDFoodItem>(entityName: "CDFoodItem")
    }

    /// Fetches all favorite food items
    static func fetchFavorites(in context: NSManagedObjectContext) -> [CDFoodItem] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == YES")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDFoodItem.useCount, ascending: false),
            NSSortDescriptor(keyPath: \CDFoodItem.name, ascending: true)
        ]

        return (try? context.fetch(request)) ?? []
    }

    /// Fetches recently used food items
    static func fetchRecent(
        limit: Int = 10,
        in context: NSManagedObjectContext
    ) -> [CDFoodItem] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "lastUsedAt != nil")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDFoodItem.lastUsedAt, ascending: false)
        ]
        request.fetchLimit = limit

        return (try? context.fetch(request)) ?? []
    }

    /// Fetches frequently used food items
    static func fetchFrequent(
        limit: Int = 10,
        in context: NSManagedObjectContext
    ) -> [CDFoodItem] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "useCount > 0")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDFoodItem.useCount, ascending: false)
        ]
        request.fetchLimit = limit

        return (try? context.fetch(request)) ?? []
    }

    /// Searches food items by name
    static func search(
        query: String,
        in context: NSManagedObjectContext
    ) -> [CDFoodItem] {
        let request = fetchRequest()
        request.predicate = NSPredicate(
            format: "name CONTAINS[cd] %@ OR brand CONTAINS[cd] %@",
            query,
            query
        )
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDFoodItem.useCount, ascending: false),
            NSSortDescriptor(keyPath: \CDFoodItem.name, ascending: true)
        ]

        return (try? context.fetch(request)) ?? []
    }
}

// MARK: - Relationship Accessors

extension CDFoodItem {
    @objc(addEntriesObject:)
    @NSManaged public func addToEntries(_ value: CDFoodEntry)

    @objc(removeEntriesObject:)
    @NSManaged public func removeFromEntries(_ value: CDFoodEntry)

    @objc(addTemplatesObject:)
    @NSManaged public func addToTemplates(_ value: CDMealTemplate)

    @objc(removeTemplatesObject:)
    @NSManaged public func removeFromTemplates(_ value: CDMealTemplate)
}
