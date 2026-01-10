import Foundation
import CoreData

/// Core Data managed object for MealTemplate entity.
@objc(CDMealTemplate)
public class CDMealTemplate: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var mealCategory: Int16
    @NSManaged public var isFavorite: Bool
    @NSManaged public var useCount: Int32
    @NSManaged public var lastUsedAt: Date?
    @NSManaged public var applicableDays: [Int]?
    @NSManaged public var createdAt: Date

    // Relationships
    @NSManaged public var items: NSSet?
}

// MARK: - Fetch Requests

extension CDMealTemplate {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDMealTemplate> {
        return NSFetchRequest<CDMealTemplate>(entityName: "CDMealTemplate")
    }

    /// Fetches all meal templates
    static func fetchAll(in context: NSManagedObjectContext) -> [CDMealTemplate] {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDMealTemplate.useCount, ascending: false),
            NSSortDescriptor(keyPath: \CDMealTemplate.name, ascending: true)
        ]

        return (try? context.fetch(request)) ?? []
    }

    /// Fetches templates for a specific meal category
    static func fetchTemplates(
        for mealCategory: Int16,
        in context: NSManagedObjectContext
    ) -> [CDMealTemplate] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "mealCategory == %d", mealCategory)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDMealTemplate.useCount, ascending: false)
        ]

        return (try? context.fetch(request)) ?? []
    }

    /// Fetches favorite templates
    static func fetchFavorites(in context: NSManagedObjectContext) -> [CDMealTemplate] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == YES")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDMealTemplate.useCount, ascending: false)
        ]

        return (try? context.fetch(request)) ?? []
    }
}

// MARK: - Relationship Accessors

extension CDMealTemplate {
    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: CDFoodItem)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: CDFoodItem)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)
}
