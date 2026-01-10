import Foundation
import CoreData

/// Core Data managed object for Achievement entity.
@objc(CDAchievement)
public class CDAchievement: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var type: String
    @NSManaged public var unlockedAt: Date?
    @NSManaged public var progress: Double

    // Relationships
    @NSManaged public var user: CDUser?
}

// MARK: - Fetch Requests

extension CDAchievement {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDAchievement> {
        return NSFetchRequest<CDAchievement>(entityName: "CDAchievement")
    }

    /// Fetches all achievements for a user
    static func fetchAll(in context: NSManagedObjectContext) -> [CDAchievement] {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDAchievement.unlockedAt, ascending: false)
        ]

        return (try? context.fetch(request)) ?? []
    }

    /// Fetches all unlocked achievements
    static func fetchUnlocked(in context: NSManagedObjectContext) -> [CDAchievement] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "unlockedAt != nil")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDAchievement.unlockedAt, ascending: false)
        ]

        return (try? context.fetch(request)) ?? []
    }

    /// Fetches achievement by type
    static func fetch(
        type: AchievementType,
        in context: NSManagedObjectContext
    ) -> CDAchievement? {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", type.rawValue)
        request.fetchLimit = 1

        return try? context.fetch(request).first
    }

    /// Fetches recently unlocked achievements
    static func fetchRecentlyUnlocked(
        limit: Int = 5,
        in context: NSManagedObjectContext
    ) -> [CDAchievement] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "unlockedAt != nil")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDAchievement.unlockedAt, ascending: false)
        ]
        request.fetchLimit = limit

        return (try? context.fetch(request)) ?? []
    }
}
