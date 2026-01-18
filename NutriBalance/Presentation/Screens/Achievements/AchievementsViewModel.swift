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
            let storedAchievements = try await container.achievementRepository.getAllAchievements()

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
        // Streak achievements
        case .streak7Days:
            let streak = await getCurrentStreak()
            return min(1.0, Double(streak) / 7.0)
        case .streak30Days:
            let streak = await getCurrentStreak()
            return min(1.0, Double(streak) / 30.0)
        case .streak100Days:
            let totalDays = await getTotalLoggedDays()
            return min(1.0, Double(totalDays) / 100.0)

        // Weight loss achievements
        case .firstKilogram:
            let weightLost = await getWeightLost()
            return min(1.0, weightLost / 1.0)
        case .halfwayThere:
            return await getGoalProgress() / 100.0
        case .goalReached:
            return await hasReachedGoalWeight() ? 1.0 : 0.0

        // Logging achievements
        case .firstEntry:
            return await hasAnyFoodEntry() ? 1.0 : 0.0
        case .hundredEntries:
            let count = await getFoodEntryCount()
            return min(1.0, Double(count) / 100.0)
        case .thousandEntries:
            let count = await getFoodEntryCount()
            return min(1.0, Double(count) / 1000.0)

        // Hydration achievements
        case .hydrationHero:
            let daysAtGoal = await getHydrationGoalDays()
            return min(1.0, Double(daysAtGoal) / 1.0)
        case .waterWeek:
            let daysAtGoal = await getHydrationGoalDays()
            return min(1.0, Double(daysAtGoal) / 7.0)

        // Nutrition achievements
        case .balancedDay:
            let daysBalanced = await getBalancedDays()
            return min(1.0, Double(daysBalanced) / 1.0)
        case .proteinChampion:
            let daysAtGoal = await getProteinGoalDays()
            return min(1.0, Double(daysAtGoal) / 7.0)
        case .fiberFriend:
            let daysFiber = await getFiberGoalDays()
            return min(1.0, Double(daysFiber) / 5.0)
        case .veggieVictor:
            return 0.0 // Simplified

        // Consistency achievements
        case .earlyBird:
            return await hasLoggedBreakfastStreak() ? 1.0 : 0.0
        case .mealPlanner:
            return await hasPerfectWeek() ? 1.0 : 0.0
        case .weekendWarrior:
            return 0.0 // Simplified
        }
    }

    // Helper methods for progress calculation
    private func hasAnyFoodEntry() async -> Bool {
        do {
            let entries = try await container.foodEntryRepository.getEntries(for: Date())
            return !entries.isEmpty
        } catch {
            return false
        }
    }

    private func getFoodEntryCount() async -> Int {
        do {
            // Get entries for the last year
            let calendar = Calendar.current
            let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
            let entries = try await container.foodEntryRepository.getEntries(from: oneYearAgo, to: Date())
            return entries.count
        } catch {
            return 0
        }
    }

    private func getCurrentStreak() async -> Int {
        var streak = 0
        let calendar = Calendar.current
        var currentDate = Date()

        while true {
            do {
                let entries = try await container.foodEntryRepository.getEntries(for: currentDate)
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

    private func getFiberGoalDays() async -> Int {
        // Count days meeting fiber goal
        return 0 // Simplified
    }

    private func getBalancedDays() async -> Int {
        // Count days with balanced macros
        return 0 // Simplified
    }

    private func getWeightLost() async -> Double {
        do {
            let entries = try await container.weightRepository.getEntriesForLastDays(365)

            guard let latest = entries.first,
                  let oldest = entries.last else {
                return 0
            }

            return max(0, oldest.weight - latest.weight)
        } catch {
            return 0
        }
    }

    private func getGoalProgress() async -> Double {
        do {
            guard let user = try await container.userRepository.getCurrentUser() else {
                return 0
            }

            let entries = try await container.weightRepository.getEntriesForLastDays(365)
            guard let latestWeight = entries.first?.weight,
                  let startWeight = entries.last?.weight else {
                return 0
            }

            let totalToLose = startWeight - user.targetWeight
            guard totalToLose > 0 else { return 100.0 }

            let lost = startWeight - latestWeight
            return Double((lost / totalToLose) * 100.0)
        } catch {
            return 0
        }
    }

    private func hasReachedGoalWeight() async -> Bool {
        do {
            guard let user = try await container.userRepository.getCurrentUser(),
                  let latest = try? await container.weightRepository.getLatestEntry() else {
                return false
            }

            return latest.weight <= user.targetWeight
        } catch {
            return false
        }
    }

    private func hasLoggedBreakfastStreak() async -> Bool {
        // Check for 7-day breakfast logging streak
        return false // Simplified
    }

    private func hasPerfectWeek() async -> Bool {
        // Check for a week with all meals logged and goals met
        return false // Simplified
    }
}
