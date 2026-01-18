import Foundation
import SwiftUI

/// View model for the Dashboard screen.
@MainActor
final class DashboardViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var selectedDate: Date = Date()
    @Published var dailySummary: DailySummary?
    @Published var hydrationIntake: Double = 0
    @Published var hydrationGoal: Double = 2500
    @Published var calorieGoal: Int = 1800
    @Published var currentStreak: Int = 0
    @Published var recentEntries: [FoodEntry] = []
    @Published var weightProgress: WeightProgressData?
    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - Dependencies

    let container: DependencyContainer

    private var getDailySummaryUseCase: GetDailySummaryUseCase {
        container.makeGetDailySummaryUseCase()
    }

    private var getDailyHydrationUseCase: GetDailyHydrationUseCase {
        container.makeGetDailyHydrationUseCase()
    }

    private var getDailyEntriesUseCase: GetDailyEntriesUseCase {
        container.makeGetDailyEntriesUseCase()
    }

    private var getWeightHistoryUseCase: GetWeightHistoryUseCase {
        container.makeGetWeightHistoryUseCase()
    }

    // MARK: - Initialization

    init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - Public Methods

    func loadData() async {
        isLoading = true
        error = nil

        // Load user preferences first
        await loadUserPreferences()

        // Load daily data in parallel - these handle their own errors
        async let summaryTask = loadDailySummary()
        async let hydrationTask = loadHydration()
        async let entriesTask = loadRecentEntries()
        async let weightTask = loadWeightProgress()

        _ = await (summaryTask, hydrationTask, entriesTask, weightTask)

        // Calculate streak with timeout
        await calculateStreak()

        isLoading = false
    }

    func refresh() async {
        await loadData()
    }

    func selectDate(_ date: Date) {
        selectedDate = date
        Task {
            await loadData()
        }
    }

    // MARK: - Private Methods

    private func loadUserPreferences() async {
        do {
            if let user = try await container.userRepository.getCurrentUser() {
                calorieGoal = user.dailyCalorieGoal
                hydrationGoal = user.dailyWaterGoal
            }
        } catch {
            // Use defaults
        }
    }

    private func loadDailySummary() async {
        do {
            guard let user = try await container.userRepository.getCurrentUser() else {
                dailySummary = nil
                return
            }
            dailySummary = try await getDailySummaryUseCase.execute(for: selectedDate, user: user)
        } catch {
            dailySummary = nil
        }
    }

    private func loadHydration() async {
        do {
            let result = try await getDailyHydrationUseCase.execute(for: selectedDate)
            hydrationIntake = result.totalHydration
        } catch {
            hydrationIntake = 0
        }
    }

    private func loadRecentEntries() async {
        do {
            recentEntries = try await getDailyEntriesUseCase.execute(for: selectedDate)
        } catch {
            recentEntries = []
        }
    }

    private func loadWeightProgress() async {
        do {
            let entries = try await getWeightHistoryUseCase.execute(days: 30)
            guard let latest = entries.first else {
                weightProgress = nil
                return
            }

            let user = try await container.userRepository.getCurrentUser()

            let targetWeight = user?.targetWeight ?? 80.0
            let startWeight = entries.last?.weight ?? latest.weight

            // Determine trend by comparing recent 7-day average vs prior 7-day average
            let trend: WeightTrend
            if entries.count >= 7 {
                // Get recent 7 days average
                let recentEntries = Array(entries.prefix(7))
                let recentAverage = recentEntries.map { $0.weight }.reduce(0, +) / Double(recentEntries.count)

                // Get prior period average (days 8-14 or whatever is available)
                let priorEntries = Array(entries.dropFirst(7).prefix(7))

                if priorEntries.count >= 3 {
                    // Compare with prior period
                    let priorAverage = priorEntries.map { $0.weight }.reduce(0, +) / Double(priorEntries.count)
                    let difference = recentAverage - priorAverage

                    if difference < -0.3 {
                        trend = .losing
                    } else if difference > 0.3 {
                        trend = .gaining
                    } else {
                        trend = .stable
                    }
                } else {
                    // Not enough prior data, compare with start weight
                    if recentAverage < startWeight - 0.5 {
                        trend = .losing
                    } else if recentAverage > startWeight + 0.5 {
                        trend = .gaining
                    } else {
                        trend = .stable
                    }
                }
            } else if entries.count >= 2,
                      let firstEntry = entries.last,
                      let lastEntry = entries.first {
                // Limited data - compare first and last entry
                let firstWeight = firstEntry.weight
                let lastWeight = lastEntry.weight
                let difference = lastWeight - firstWeight

                if difference < -0.3 {
                    trend = .losing
                } else if difference > 0.3 {
                    trend = .gaining
                } else {
                    trend = .stable
                }
            } else {
                trend = .stable
            }

            weightProgress = WeightProgressData(
                current: latest.weight,
                target: targetWeight,
                start: startWeight,
                trend: trend
            )
        } catch {
            weightProgress = nil
        }
    }

    private func calculateStreak() async {
        // Calculate consecutive days with logged entries with timeout protection
        var streak = 0
        var currentDate = selectedDate
        let maxDaysToCheck = 365
        let calendar = Calendar.current

        // Use withTaskGroup with timeout for safety
        await withTaskGroup(of: Int.self) { group in
            group.addTask {
                var localStreak = 0
                var checkDate = currentDate

                for _ in 0..<maxDaysToCheck {
                    do {
                        let entries = try await self.getDailyEntriesUseCase.execute(for: checkDate)
                        if entries.isEmpty {
                            break
                        }
                        localStreak += 1

                        guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                            break
                        }
                        checkDate = previousDay
                    } catch {
                        // Stop on error
                        break
                    }
                }
                return localStreak
            }

            // Only take the first result
            if let result = await group.next() {
                streak = result
            }

            // Cancel any remaining tasks
            group.cancelAll()
        }

        currentStreak = streak
    }
}

// MARK: - Supporting Types

struct WeightProgressData {
    let current: Double
    let target: Double
    let start: Double
    let trend: WeightTrend
}
