import Foundation
import CoreData

/// Core Data managed object for WeightEntry entity.
@objc(CDWeightEntry)
public class CDWeightEntry: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var weight: Double
    @NSManaged public var notes: String?
    @NSManaged public var bodyFatPercentage: NSNumber?
    @NSManaged public var muscleMass: NSNumber?
    @NSManaged public var waistCircumference: NSNumber?
    @NSManaged public var hipCircumference: NSNumber?
    @NSManaged public var createdAt: Date

    // Relationships
    @NSManaged public var user: CDUser?
}

// MARK: - Fetch Requests

extension CDWeightEntry {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDWeightEntry> {
        return NSFetchRequest<CDWeightEntry>(entityName: "CDWeightEntry")
    }

    /// Fetches the most recent weight entry
    static func fetchLatest(in context: NSManagedObjectContext) -> CDWeightEntry? {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDWeightEntry.date, ascending: false)
        ]
        request.fetchLimit = 1

        return try? context.fetch(request).first
    }

    /// Fetches weight entries for a date range
    static func fetchEntries(
        from startDate: Date,
        to endDate: Date,
        in context: NSManagedObjectContext
    ) -> [CDWeightEntry] {
        let request = fetchRequest()

        request.predicate = NSPredicate(
            format: "date >= %@ AND date <= %@",
            startDate as NSDate,
            endDate as NSDate
        )
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDWeightEntry.date, ascending: true)
        ]

        return (try? context.fetch(request)) ?? []
    }

    /// Fetches weight entries for the last N days
    static func fetchLastDays(
        _ days: Int,
        in context: NSManagedObjectContext
    ) -> [CDWeightEntry] {
        let endDate = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) else {
            return []
        }

        return fetchEntries(from: startDate, to: endDate, in: context)
    }

    /// Fetches entry for a specific date (if exists)
    static func fetchEntry(
        for date: Date,
        in context: NSManagedObjectContext
    ) -> CDWeightEntry? {
        let request = fetchRequest()

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        request.fetchLimit = 1

        return try? context.fetch(request).first
    }
}
