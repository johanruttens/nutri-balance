import Foundation
import CoreData

/// Core Data managed object for DrinkEntry entity.
@objc(CDDrinkEntry)
public class CDDrinkEntry: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var drinkType: Int16
    @NSManaged public var name: String?
    @NSManaged public var amount: Double
    @NSManaged public var calories: NSNumber?
    @NSManaged public var caffeineContent: NSNumber?
    @NSManaged public var sugarContent: NSNumber?
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    // Relationships
    @NSManaged public var user: CDUser?
}

// MARK: - Fetch Requests

extension CDDrinkEntry {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDDrinkEntry> {
        return NSFetchRequest<CDDrinkEntry>(entityName: "CDDrinkEntry")
    }

    /// Fetches drink entries for a specific date
    static func fetchEntries(
        for date: Date,
        in context: NSManagedObjectContext
    ) -> [CDDrinkEntry] {
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
            NSSortDescriptor(keyPath: \CDDrinkEntry.date, ascending: true)
        ]

        return (try? context.fetch(request)) ?? []
    }

    /// Fetches drink entries for a date range
    static func fetchEntries(
        from startDate: Date,
        to endDate: Date,
        in context: NSManagedObjectContext
    ) -> [CDDrinkEntry] {
        let request = fetchRequest()

        request.predicate = NSPredicate(
            format: "date >= %@ AND date <= %@",
            startDate as NSDate,
            endDate as NSDate
        )
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDDrinkEntry.date, ascending: true)
        ]

        return (try? context.fetch(request)) ?? []
    }

    /// Calculates total water intake for a date
    static func totalWaterIntake(
        for date: Date,
        in context: NSManagedObjectContext
    ) -> Double {
        let entries = fetchEntries(for: date, in: context)
        return entries.reduce(0) { total, entry in
            let drinkType = DrinkType(rawValue: entry.drinkType) ?? .other
            return total + (entry.amount * drinkType.hydrationFactor)
        }
    }
}
