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
            createdAt: Date(),
            updatedAt: Date()
        )

        do {
            try await logDrinkUseCase.execute(entry: entry)
            await loadTodayData()
        } catch {
            self.error = error
        }
    }

    func deleteEntry(_ entry: DrinkEntry) async {
        // Store entry for potential undo
        let deletedEntry = entry

        do {
            let repository = container.drinkEntryRepository
            try await repository.deleteEntry(entry)
            await loadTodayData()

            // Show undo toast
            ToastManager.shared.showUndo(L("toast.deleted")) { [weak self] in
                Task { @MainActor in
                    await self?.restoreEntry(deletedEntry)
                }
            }
        } catch {
            self.error = error
            ToastManager.shared.showError()
        }
    }

    private func restoreEntry(_ entry: DrinkEntry) async {
        do {
            try await logDrinkUseCase.execute(entry: entry)
            await loadTodayData()
            ToastManager.shared.showSuccess(L("toast.undone"))
        } catch {
            ToastManager.shared.showError()
        }
    }

    // MARK: - Private Methods

    private func loadTodayData() async {
        do {
            let result = try await getDailyHydrationUseCase.execute(for: Date())
            todayEntries = result.entries

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
                let result = try await getDailyHydrationUseCase.execute(for: date)
                let intake = result.totalHydration

                // Locale-safe weekday label using LocalizationManager
                let dayLabel = LDate(date, style: .weekdayShort)

                data.append(DailyHydrationData(
                    date: date,
                    dayLabel: dayLabel,
                    intake: intake
                ))
            } catch {
                // Add day with zero intake on error to maintain chart continuity
                let dayLabel = LDate(date, style: .weekdayShort)

                data.append(DailyHydrationData(
                    date: date,
                    dayLabel: dayLabel,
                    intake: 0
                ))
            }
        }

        weeklyData = data
    }
}
