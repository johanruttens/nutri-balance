import Foundation
import SwiftUI

/// View model for the Achievements screen.
@MainActor
final class AchievementsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var achievements: [Achievement] = []
    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - Computed Properties

    var unlockedAchievements: [Achievement] {
        achievements.filter { $0.unlockedAt != nil }
    }

    var inProgressAchievements: [Achievement] {
        achievements.filter { $0.unlockedAt == nil && $0.progress > 0 }
    }

    var lockedAchievements: [Achievement] {
        achievements.filter { $0.unlockedAt == nil && $0.progress == 0 }
    }

    var unlockedCount: Int {
        unlockedAchievements.count
    }

    var totalCount: Int {
        AchievementType.allCases.count
    }

    // MARK: - Dependencies

    let container: DependencyContainer

    // MARK: - Initialization

    init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - Public Methods

    func loadAchievements() async {
        isLoading = true
        error = nil

        do {
            let repository = container.makeAchievementRepository()
            let storedAchievements = try await repository.getAll()

            // Create achievement objects for all types
            var allAchievements: [Achievement] = []

            for type in AchievementType.allCases {
                if let stored = storedAchievements.first(where: { $0.type == type }) {
                    allAchievements.append(stored)
                } else {
                    // Calculate progress for this achievement
                    let progress = await calculateProgress(for: type)
                    allAchievements.append(Achievement(
                        id: UUID(),
                        type: type,
                        unlockedAt: nil,
                        progress: progress
                    ))
                }
            }

            achievements = allAchievements.sorted { a, b in
                // Sort: unlocked first, then by progress, then by category
                if a.unlockedAt != nil && b.unlockedAt == nil { return true }
                if a.unlockedAt == nil && b.unlockedAt != nil { return false }
                if a.progress != b.progress { return a.progress > b.progress }
                return a.type.category.rawValue < b.type.category.rawValue
            }
        } catch {
            self.error = error
            achievements = []
        }

        isLoading = false
    }

    // MARK: - Private Methods

    private func calculateProgress(for type: AchievementType) async -> Double {
        switch type {
        case .firstEntry:
            return await hasAnyFoodEntry() ? 1.0 : 0.0

        case .weekStreak:
            let streak = await getCurrentStreak()
            return min(1.0, Double(streak) / 7.0)

        case .monthStreak:
            let streak = await getCurrentStreak()
            return min(1.0, Double(streak) / 30.0)

        case .hundredDays:
            let totalDays = await getTotalLoggedDays()
            return min(1.0, Double(totalDays) / 100.0)

        case .hydrationHero:
            let daysAtGoal = await getHydrationGoalDays()
            return min(1.0, Double(daysAtGoal) / 7.0)

        case .proteinPro:
            let daysAtGoal = await getProteinGoalDays()
            return min(1.0, Double(daysAtGoal) / 7.0)

        case .balancedEater:
            let daysBalanced = await getBalancedDays()
            return min(1.0, Double(daysBalanced) / 7.0)

        case .firstKgLost, .fiveKgLost, .tenKgLost:
            let weightLost = await getWeightLost()
            let target: Double
            switch type {
            case .firstKgLost: target = 1.0
            case .fiveKgLost: target = 5.0
            case .tenKgLost: target = 10.0
            default: target = 1.0
            }
            return min(1.0, weightLost / target)

        case .goalWeight:
            return await hasReachedGoalWeight() ? 1.0 : 0.0

        case .tenFoods, .fiftyFoods, .hundredFoods:
            let count = await getFoodItemCount()
            let target: Int
            switch type {
            case .tenFoods: target = 10
            case .fiftyFoods: target = 50
            case .hundredFoods: target = 100
            default: target = 10
            }
            return min(1.0, Double(count) / Double(target))

        case .earlyBird:
            return await hasLoggedBreakfastStreak() ? 1.0 : 0.0

        case .nightOwl:
            return await hasLoggedDinnerStreak() ? 1.0 : 0.0

        case .perfectWeek:
            return await hasPerfectWeek() ? 1.0 : 0.0
        }
    }

    // Helper methods for progress calculation
    private func hasAnyFoodEntry() async -> Bool {
        do {
            let repository = container.makeFoodEntryRepository()
            let entries = try await repository.getForDate(Date())
            return !entries.isEmpty
        } catch {
            return false
        }
    }

    private func getCurrentStreak() async -> Int {
        var streak = 0
        let calendar = Calendar.current
        var currentDate = Date()

        let repository = container.makeFoodEntryRepository()

        while true {
            do {
                let entries = try await repository.getForDate(currentDate)
                if entries.isEmpty { break }
                streak += 1

                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = previousDay

                if streak > 365 { break }
            } catch {
                break
            }
        }

        return streak
    }

    private func getTotalLoggedDays() async -> Int {
        // Simplified: would normally count distinct days with entries
        return await getCurrentStreak()
    }

    private func getHydrationGoalDays() async -> Int {
        // Count days meeting hydration goal
        return 0 // Simplified
    }

    private func getProteinGoalDays() async -> Int {
        // Count days meeting protein goal
        return 0 // Simplified
    }

    private func getBalancedDays() async -> Int {
        // Count days with balanced macros
        return 0 // Simplified
    }

    private func getWeightLost() async -> Double {
        do {
            let repository = container.makeWeightRepository()
            let entries = try await repository.getHistory(limit: 100)

            guard let latest = entries.first,
                  let oldest = entries.last else {
                return 0
            }

            return max(0, oldest.weight - latest.weight)
        } catch {
            return 0
        }
    }

    private func hasReachedGoalWeight() async -> Bool {
        do {
            let userRepository = container.makeUserRepository()
            let weightRepository = container.makeWeightRepository()

            guard let user = try await userRepository.getUser(),
                  let entries = try? await weightRepository.getHistory(limit: 1),
                  let latest = entries.first else {
                return false
            }

            return latest.weight <= user.targetWeight
        } catch {
            return false
        }
    }

    private func getFoodItemCount() async -> Int {
        do {
            let repository = container.makeFoodItemRepository()
            let items = try await repository.getFavorites()
            return items.count
        } catch {
            return 0
        }
    }

    private func hasLoggedBreakfastStreak() async -> Bool {
        // Check for 7-day breakfast logging streak
        return false // Simplified
    }

    private func hasLoggedDinnerStreak() async -> Bool {
        // Check for 7-day dinner logging streak
        return false // Simplified
    }

    private func hasPerfectWeek() async -> Bool {
        // Check for a week with all meals logged and goals met
        return false // Simplified
    }
}
