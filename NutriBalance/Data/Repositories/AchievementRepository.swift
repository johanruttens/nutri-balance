import Foundation
import CoreData

/// Repository implementation for achievement data operations.
final class AchievementRepository: AchievementRepositoryProtocol {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func getAllAchievements() async throws -> [Achievement] {
        try await context.perform {
            let achievements = CDAchievement.fetchAll(in: self.context)
            return achievements.map { AchievementMapper.toDomain($0) }
        }
    }

    func getUnlockedAchievements() async throws -> [Achievement] {
        try await context.perform {
            let achievements = CDAchievement.fetchUnlocked(in: self.context)
            return achievements.map { AchievementMapper.toDomain($0) }
        }
    }

    func getRecentlyUnlocked(limit: Int) async throws -> [Achievement] {
        try await context.perform {
            let achievements = CDAchievement.fetchRecentlyUnlocked(limit: limit, in: self.context)
            return achievements.map { AchievementMapper.toDomain($0) }
        }
    }

    func getAchievement(type: AchievementType) async throws -> Achievement? {
        try await context.perform {
            guard let achievement = CDAchievement.fetch(type: type, in: self.context) else {
                return nil
            }
            return AchievementMapper.toDomain(achievement)
        }
    }

    func updateProgress(type: AchievementType, progress: Double) async throws -> Achievement {
        try await context.perform {
            let entity: CDAchievement

            if let existing = CDAchievement.fetch(type: type, in: self.context) {
                entity = existing
            } else {
                // Create new achievement if it doesn't exist
                entity = CDAchievement(context: self.context)
                entity.id = UUID()
                entity.type = type.rawValue

                // Link to user if exists
                if let user = CDUser.fetchCurrentUser(in: self.context) {
                    entity.user = user
                }
            }

            entity.progress = min(1.0, max(0.0, progress))

            // Auto-unlock if progress reaches 100%
            if entity.progress >= 1.0 && entity.unlockedAt == nil {
                entity.unlockedAt = Date()
            }

            try self.context.save()
            return AchievementMapper.toDomain(entity)
        }
    }

    func unlockAchievement(type: AchievementType) async throws -> Achievement {
        try await context.perform {
            let entity: CDAchievement

            if let existing = CDAchievement.fetch(type: type, in: self.context) {
                entity = existing
            } else {
                entity = CDAchievement(context: self.context)
                entity.id = UUID()
                entity.type = type.rawValue

                if let user = CDUser.fetchCurrentUser(in: self.context) {
                    entity.user = user
                }
            }

            entity.progress = 1.0
            entity.unlockedAt = Date()

            try self.context.save()
            return AchievementMapper.toDomain(entity)
        }
    }

    func initializeAchievements() async throws {
        try await context.perform {
            // Create all achievement types if they don't exist
            for type in AchievementType.allCases {
                if CDAchievement.fetch(type: type, in: self.context) == nil {
                    let entity = CDAchievement(context: self.context)
                    entity.id = UUID()
                    entity.type = type.rawValue
                    entity.progress = 0
                    entity.unlockedAt = nil

                    if let user = CDUser.fetchCurrentUser(in: self.context) {
                        entity.user = user
                    }
                }
            }

            try self.context.save()
        }
    }
}
