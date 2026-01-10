import Foundation
import CoreData

/// Maps between CDUser (Core Data) and User (Domain) models.
enum UserMapper {

    /// Converts a Core Data user to a domain user
    static func toDomain(_ cdUser: CDUser) -> User {
        User(
            id: cdUser.id,
            firstName: cdUser.firstName,
            lastName: cdUser.lastName,
            profileImageData: cdUser.profileImageData,
            email: cdUser.email,
            currentWeight: cdUser.currentWeight,
            targetWeight: cdUser.targetWeight,
            height: cdUser.height?.doubleValue,
            birthDate: cdUser.birthDate,
            targetDate: cdUser.targetDate,
            dailyCalorieGoal: Int(cdUser.dailyCalorieGoal),
            dailyWaterGoal: cdUser.dailyWaterGoal,
            targetProtein: cdUser.targetProtein?.doubleValue,
            targetCarbs: cdUser.targetCarbs?.doubleValue,
            targetFat: cdUser.targetFat?.doubleValue,
            activityLevel: ActivityLevel(rawValue: cdUser.activityLevel) ?? .moderatelyActive,
            preferredLanguage: cdUser.preferredLanguage,
            notificationsEnabled: cdUser.notificationsEnabled,
            mealReminderTimes: nil, // TODO: Implement meal reminder times mapping
            createdAt: cdUser.createdAt,
            updatedAt: cdUser.updatedAt,
            onboardingCompleted: cdUser.onboardingCompleted
        )
    }

    /// Updates a Core Data user from a domain user
    static func toEntity(_ user: User, entity: CDUser) {
        entity.id = user.id
        entity.firstName = user.firstName
        entity.lastName = user.lastName
        entity.profileImageData = user.profileImageData
        entity.email = user.email
        entity.currentWeight = user.currentWeight
        entity.targetWeight = user.targetWeight
        entity.height = user.height.map { NSNumber(value: $0) }
        entity.birthDate = user.birthDate
        entity.targetDate = user.targetDate
        entity.dailyCalorieGoal = Int32(user.dailyCalorieGoal)
        entity.dailyWaterGoal = user.dailyWaterGoal
        entity.targetProtein = user.targetProtein.map { NSNumber(value: $0) }
        entity.targetCarbs = user.targetCarbs.map { NSNumber(value: $0) }
        entity.targetFat = user.targetFat.map { NSNumber(value: $0) }
        entity.activityLevel = user.activityLevel.rawValue
        entity.preferredLanguage = user.preferredLanguage
        entity.notificationsEnabled = user.notificationsEnabled
        entity.onboardingCompleted = user.onboardingCompleted
        entity.updatedAt = Date()
    }

    /// Creates a new Core Data user from a domain user
    static func createEntity(_ user: User, in context: NSManagedObjectContext) -> CDUser {
        let entity = CDUser(context: context)
        entity.createdAt = user.createdAt
        toEntity(user, entity: entity)
        return entity
    }
}
