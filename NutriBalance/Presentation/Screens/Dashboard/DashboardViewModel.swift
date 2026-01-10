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

        do {
            // Load user preferences
            await loadUserPreferences()

            // Load daily data in parallel
            async let summaryTask = loadDailySummary()
            async let hydrationTask = loadHydration()
            async let entriesTask = loadRecentEntries()
            async let weightTask = loadWeightProgress()

            _ = await (summaryTask, hydrationTask, entriesTask, weightTask)

            // Calculate streak
            await calculateStreak()

        } catch {
            self.error = error
        }

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
            let userRepository = container.makeUserRepository()
            if let user = try await userRepository.getUser() {
                calorieGoal = user.dailyCalorieGoal
                hydrationGoal = user.dailyWaterGoal
            }
        } catch {
            // Use defaults
        }
    }

    private func loadDailySummary() async {
        do {
            dailySummary = try await getDailySummaryUseCase.execute(for: selectedDate)
        } catch {
            dailySummary = nil
        }
    }

    private func loadHydration() async {
        do {
            let entries = try await getDailyHydrationUseCase.execute(for: selectedDate)
            hydrationIntake = entries.reduce(0) { $0 + $1.effectiveHydration }
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
            let entries = try await getWeightHistoryUseCase.execute(limit: 30)
            guard let latest = entries.first else {
                weightProgress = nil
                return
            }

            let userRepository = container.makeUserRepository()
            let user = try await userRepository.getUser()

            let targetWeight = user?.targetWeight ?? 80.0
            let startWeight = entries.last?.weight ?? latest.weight

            // Determine trend
            let trend: WeightTrend
            if entries.count >= 2 {
                let recent = entries.prefix(7).map(\.weight)
                let average = recent.reduce(0, +) / Double(recent.count)
                if average < startWeight - 0.5 {
                    trend = .losing
                } else if average > startWeight + 0.5 {
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
        // Calculate consecutive days with logged entries
        var streak = 0
        var currentDate = selectedDate

        do {
            while true {
                let entries = try await getDailyEntriesUseCase.execute(for: currentDate)
                if entries.isEmpty {
                    break
                }
                streak += 1
                guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousDay

                // Limit check to prevent infinite loop
                if streak > 365 {
                    break
                }
            }
        } catch {
            // Ignore errors in streak calculation
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
