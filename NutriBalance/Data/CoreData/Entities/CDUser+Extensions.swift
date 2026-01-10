import Foundation
import CoreData

/// Core Data managed object for User entity.
@objc(CDUser)
public class CDUser: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var firstName: String
    @NSManaged public var lastName: String?
    @NSManaged public var email: String?
    @NSManaged public var profileImageData: Data?
    @NSManaged public var currentWeight: Double
    @NSManaged public var targetWeight: Double
    @NSManaged public var height: NSNumber?
    @NSManaged public var birthDate: Date?
    @NSManaged public var targetDate: Date?
    @NSManaged public var dailyCalorieGoal: Int32
    @NSManaged public var dailyWaterGoal: Double
    @NSManaged public var targetProtein: NSNumber?
    @NSManaged public var targetCarbs: NSNumber?
    @NSManaged public var targetFat: NSNumber?
    @NSManaged public var activityLevel: Int16
    @NSManaged public var preferredLanguage: String
    @NSManaged public var notificationsEnabled: Bool
    @NSManaged public var onboardingCompleted: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    // Relationships
    @NSManaged public var foodEntries: NSSet?
    @NSManaged public var drinkEntries: NSSet?
    @NSManaged public var weightEntries: NSSet?
    @NSManaged public var achievements: NSSet?
}

// MARK: - Fetch Requests

extension CDUser {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUser> {
        return NSFetchRequest<CDUser>(entityName: "CDUser")
    }

    /// Fetches the current user (assumes single user app)
    static func fetchCurrentUser(in context: NSManagedObjectContext) -> CDUser? {
        let request = fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDUser.createdAt, ascending: false)]

        return try? context.fetch(request).first
    }
}

// MARK: - Relationship Accessors

extension CDUser {
    @objc(addFoodEntriesObject:)
    @NSManaged public func addToFoodEntries(_ value: CDFoodEntry)

    @objc(removeFoodEntriesObject:)
    @NSManaged public func removeFromFoodEntries(_ value: CDFoodEntry)

    @objc(addDrinkEntriesObject:)
    @NSManaged public func addToDrinkEntries(_ value: CDDrinkEntry)

    @objc(removeDrinkEntriesObject:)
    @NSManaged public func removeFromDrinkEntries(_ value: CDDrinkEntry)

    @objc(addWeightEntriesObject:)
    @NSManaged public func addToWeightEntries(_ value: CDWeightEntry)

    @objc(removeWeightEntriesObject:)
    @NSManaged public func removeFromWeightEntries(_ value: CDWeightEntry)

    @objc(addAchievementsObject:)
    @NSManaged public func addToAchievements(_ value: CDAchievement)

    @objc(removeAchievementsObject:)
    @NSManaged public func removeFromAchievements(_ value: CDAchievement)
}
