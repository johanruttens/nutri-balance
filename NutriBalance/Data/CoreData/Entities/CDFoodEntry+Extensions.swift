import Foundation
import CoreData

/// Core Data managed object for FoodEntry entity.
@objc(CDFoodEntry)
public class CDFoodEntry: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var mealCategory: Int16
    @NSManaged public var foodName: String
    @NSManaged public var portionSize: Double
    @NSManaged public var portionUnit: String
    @NSManaged public var calories: NSNumber?
    @NSManaged public var protein: NSNumber?
    @NSManaged public var carbs: NSNumber?
    @NSManaged public var fat: NSNumber?
    @NSManaged public var fiber: NSNumber?
    @NSManaged public var sugar: NSNumber?
    @NSManaged public var notes: String?
    @NSManaged public var hungerLevel: NSNumber?
    @NSManaged public var moodEmoji: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    // Relationships
    @NSManaged public var user: CDUser?
    @NSManaged public var linkedFoodItem: CDFoodItem?
}

// MARK: - Fetch Requests

extension CDFoodEntry {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDFoodEntry> {
        return NSFetchRequest<CDFoodEntry>(entityName: "CDFoodEntry")
    }

    /// Fetches entries for a specific date
    static func fetchEntries(
        for date: Date,
        in context: NSManagedObjectContext
    ) -> [CDFoodEntry] {
        let request = fetchRequest()

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDFoodEntry.mealCategory, ascending: true),
            NSSortDescriptor(keyPath: \CDFoodEntry.createdAt, ascending: true)
        ]

        return (try? context.fetch(request)) ?? []
    }

    /// Fetches entries for a date range
    static func fetchEntries(
        from startDate: Date,
        to endDate: Date,
        in context: NSManagedObjectContext
    ) -> [CDFoodEntry] {
        let request = fetchRequest()

        request.predicate = NSPredicate(
            format: "date >= %@ AND date <= %@",
            startDate as NSDate,
            endDate as NSDate
        )
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDFoodEntry.date, ascending: true),
            NSSortDescriptor(keyPath: \CDFoodEntry.mealCategory, ascending: true)
        ]

        return (try? context.fetch(request)) ?? []
    }

    /// Fetches entries for a specific meal category on a date
    static func fetchEntries(
        for date: Date,
        mealCategory: Int16,
        in context: NSManagedObjectContext
    ) -> [CDFoodEntry] {
        let request = fetchRequest()

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@ AND mealCategory == %d",
            startOfDay as NSDate,
            endOfDay as NSDate,
            mealCategory
        )
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDFoodEntry.createdAt, ascending: true)
        ]

        return (try? context.fetch(request)) ?? []
    }
}
