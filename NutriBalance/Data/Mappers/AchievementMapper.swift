import Foundation
import CoreData

/// Maps between CDAchievement (Core Data) and Achievement (Domain) models.
enum AchievementMapper {

    /// Converts a Core Data achievement to a domain achievement
    static func toDomain(_ cdAchievement: CDAchievement) -> Achievement {
        Achievement(
            id: cdAchievement.id,
            type: AchievementType(rawValue: cdAchievement.type) ?? .firstEntry,
            unlockedAt: cdAchievement.unlockedAt,
            progress: cdAchievement.progress
        )
    }

    /// Updates a Core Data achievement from a domain achievement
    static func toEntity(_ achievement: Achievement, entity: CDAchievement) {
        entity.id = achievement.id
        entity.type = achievement.type.rawValue
        entity.unlockedAt = achievement.unlockedAt
        entity.progress = achievement.progress
    }

    /// Creates a new Core Data achievement from a domain achievement
    static func createEntity(_ achievement: Achievement, in context: NSManagedObjectContext) -> CDAchievement {
        let entity = CDAchievement(context: context)
        toEntity(achievement, entity: entity)
        return entity
    }
}
