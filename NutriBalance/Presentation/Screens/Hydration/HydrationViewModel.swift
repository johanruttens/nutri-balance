import Foundation
import SwiftUI

/// View model for the Hydration tracking screen.
@MainActor
final class HydrationViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var dailyIntake: Double = 0
    @Published var effectiveHydration: Double = 0
    @Published var dailyGoal: Double = 2500
    @Published var todayEntries: [DrinkEntry] = []
    @Published var weeklyData: [DailyHydrationData] = []
    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - Dependencies

    let container: DependencyContainer

    private var getDailyHydrationUseCase: GetDailyHydrationUseCase {
        container.makeGetDailyHydrationUseCase()
    }

    private var logDrinkUseCase: LogDrinkUseCase {
        container.makeLogDrinkUseCase()
    }

    // MARK: - Initialization

    init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - Public Methods

    func loadData() async {
        isLoading = true
        error = nil

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadTodayData() }
            group.addTask { await self.loadWeeklyData() }
        }

        isLoading = false
    }

    func quickAddWater(amount: Double) async {
        let entry = DrinkEntry(
            id: UUID(),
            date: Date(),
            drinkType: .water,
            amount: amount,
            unit: .milliliters
        )

        do {
            try await logDrinkUseCase.execute(entry: entry)
            await loadTodayData()
        } catch {
            self.error = error
        }
    }

    func deleteEntry(_ entry: DrinkEntry) async {
        do {
            let repository = container.makeDrinkEntryRepository()
            try await repository.delete(id: entry.id)
            await loadTodayData()
        } catch {
            self.error = error
        }
    }

    // MARK: - Private Methods

    private func loadTodayData() async {
        do {
            todayEntries = try await getDailyHydrationUseCase.execute(for: Date())

            // Calculate totals
            dailyIntake = todayEntries.reduce(0) { $0 + $1.amount }
            effectiveHydration = todayEntries.reduce(0) { $0 + $1.effectiveHydration }

            // Sort by time (most recent first)
            todayEntries.sort { $0.date > $1.date }
        } catch {
            self.error = error
            todayEntries = []
            dailyIntake = 0
            effectiveHydration = 0
        }
    }

    private func loadWeeklyData() async {
        let calendar = Calendar.current
        let today = Date()

        var data: [DailyHydrationData] = []

        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                continue
            }

            do {
                let entries = try await getDailyHydrationUseCase.execute(for: date)
                let intake = entries.reduce(0) { $0 + $1.amount }

                let dayLabel = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]

                data.append(DailyHydrationData(
                    date: date,
                    dayLabel: dayLabel,
                    intake: intake
                ))
            } catch {
                // Skip days with errors
            }
        }

        weeklyData = data
    }
}
