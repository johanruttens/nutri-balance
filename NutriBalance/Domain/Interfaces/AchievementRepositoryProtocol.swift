import Foundation

/// Protocol defining achievement data operations.
protocol AchievementRepositoryProtocol {
    /// Fetches all achievements
    func getAllAchievements() async throws -> [Achievement]

    /// Fetches unlocked achievements
    func getUnlockedAchievements() async throws -> [Achievement]

    /// Fetches recently unlocked achievements
    func getRecentlyUnlocked(limit: Int) async throws -> [Achievement]

    /// Gets achievement by type
    func getAchievement(type: AchievementType) async throws -> Achievement?

    /// Updates achievement progress
    func updateProgress(type: AchievementType, progress: Double) async throws -> Achievement

    /// Unlocks an achievement
    func unlockAchievement(type: AchievementType) async throws -> Achievement

    /// Initializes all achievements for a new user
    func initializeAchievements() async throws
}
