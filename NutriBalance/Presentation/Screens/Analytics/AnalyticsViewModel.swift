import Foundation
import SwiftUI

/// View model for the Analytics screen.
@MainActor
final class AnalyticsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var summary: AnalyticsSummary = .empty
    @Published var calorieData: [DailyCalorieData] = []
    @Published var avgProtein: Double = 0
    @Published var avgCarbs: Double = 0
    @Published var avgFat: Double = 0
    @Published var calorieGoalProgress: Double = 0
    @Published var proteinGoalProgress: Double = 0
    @Published var hydrationGoalProgress: Double = 0
    @Published var currentStreak: Int = 0
    @Published var daysLogged: Int = 0
    @Published var calorieGoal: Int = 1800
    @Published var hydrationGoal: Double = 2500
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showExport = false

    // MARK: - Dependencies

    let container: DependencyContainer

    // MARK: - Initialization

    init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - Public Methods

    func loadData(for period: AnalyticsPeriod) async {
        isLoading = true
        error = nil

        await loadUserGoals()

        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .day, value: -(period.days - 1), to: today) ?? today

        var dailySummaries: [DailySummary] = []
        var dailyHydration: [Double] = []
        var loggedDays = 0

        // Get user for daily summaries
        let user = try? await container.userRepository.getCurrentUser()

        // Load data for each day
        for dayOffset in 0..<period.days {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else {
                continue
            }

            // Load food entries
            if let user = user {
                do {
                    let getDailySummaryUseCase = container.makeGetDailySummaryUseCase()
                    let summary = try await getDailySummaryUseCase.execute(for: date, user: user)
                    dailySummaries.append(summary)
                    if summary.totalCalories > 0 {
                        loggedDays += 1
                    }
                } catch {
                    // Skip day on error
                }
            }

            // Load hydration
            do {
                let getHydrationUseCase = container.makeGetDailyHydrationUseCase()
                let result = try await getHydrationUseCase.execute(for: date)
                dailyHydration.append(result.totalHydration)
            } catch {
                dailyHydration.append(0)
            }
        }

        // Calculate averages
        let validSummaries = dailySummaries.filter { $0.totalCalories > 0 }

        if !validSummaries.isEmpty {
            let avgCalories = validSummaries.reduce(0) { $0 + $1.totalCalories } / validSummaries.count
            let avgHydration = dailyHydration.reduce(0, +) / Double(max(1, dailyHydration.count))

            summary = AnalyticsSummary(
                avgCalories: avgCalories,
                avgHydration: avgHydration
            )

            avgProtein = validSummaries.reduce(0) { $0 + $1.totalProtein } / Double(validSummaries.count)
            avgCarbs = validSummaries.reduce(0) { $0 + $1.totalCarbs } / Double(validSummaries.count)
            avgFat = validSummaries.reduce(0) { $0 + $1.totalFat } / Double(validSummaries.count)
        } else {
            summary = .empty
            avgProtein = 0
            avgCarbs = 0
            avgFat = 0
        }

        // Build calorie chart data
        calorieData = []
        for (index, daySummary) in dailySummaries.enumerated() {
            guard let date = calendar.date(byAdding: .day, value: index, to: startDate) else {
                continue
            }

            let dayLabel: String
            if period == .week {
                dayLabel = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            } else {
                dayLabel = "\(calendar.component(.day, from: date))"
            }

            calorieData.append(DailyCalorieData(
                date: date,
                dayLabel: dayLabel,
                calories: daySummary.totalCalories
            ))
        }

        // Calculate goal progress
        calculateGoalProgress(from: validSummaries, hydration: dailyHydration)

        // Update logged days and streak
        daysLogged = loggedDays
        await calculateStreak()

        isLoading = false
    }

    // MARK: - Private Methods

    private func loadUserGoals() async {
        do {
            let repository = container.userRepository
            if let user = try await repository.getCurrentUser() {
                calorieGoal = user.dailyCalorieGoal
                hydrationGoal = user.dailyWaterGoal
            }
        } catch {
            // Use defaults
        }
    }

    private func calculateGoalProgress(from summaries: [DailySummary], hydration: [Double]) {
        guard !summaries.isEmpty else {
            calorieGoalProgress = 0
            proteinGoalProgress = 0
            hydrationGoalProgress = 0
            return
        }

        // Calculate how many days met the goal
        let daysAtCalorieGoal = summaries.filter {
            let ratio = Double($0.totalCalories) / Double(calorieGoal)
            return ratio >= 0.9 && ratio <= 1.1 // Within 10% of goal
        }.count

        calorieGoalProgress = Double(daysAtCalorieGoal) / Double(summaries.count)

        // Protein goal (assuming 100g default)
        let proteinGoal: Double = 100
        let daysAtProteinGoal = summaries.filter { $0.totalProtein >= proteinGoal * 0.9 }.count
        proteinGoalProgress = Double(daysAtProteinGoal) / Double(summaries.count)

        // Hydration goal
        let daysAtHydrationGoal = hydration.filter { $0 >= hydrationGoal * 0.9 }.count
        hydrationGoalProgress = Double(daysAtHydrationGoal) / Double(max(1, hydration.count))
    }

    private func calculateStreak() async {
        var streak = 0
        let calendar = Calendar.current
        var currentDate = Date()

        let getDailyEntriesUseCase = container.makeGetDailyEntriesUseCase()

        while true {
            do {
                let entries = try await getDailyEntriesUseCase.execute(for: currentDate)
                if entries.isEmpty {
                    break
                }
                streak += 1

                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousDay

                if streak > 365 {
                    break
                }
            } catch {
                break
            }
        }

        currentStreak = streak
    }
}

// MARK: - Supporting Types

struct AnalyticsSummary {
    let avgCalories: Int
    let avgHydration: Double

    static let empty = AnalyticsSummary(avgCalories: 0, avgHydration: 0)
}
