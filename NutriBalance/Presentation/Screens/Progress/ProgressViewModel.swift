import Foundation
import SwiftUI

/// View model for the Progress/Weight tracking screen.
@MainActor
final class ProgressViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var currentWeight: Double = 0
    @Published var targetWeight: Double = 80
    @Published var startWeight: Double = 0
    @Published var weightTrend: WeightTrend = .stable
    @Published var chartData: [WeightChartData] = []
    @Published var recentEntries: [WeightEntry] = []
    @Published var statistics: WeightStatistics = .empty
    @Published var bmi: Double = 0
    @Published var userHeight: Double = 175
    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - Dependencies

    let container: DependencyContainer

    private var getWeightHistoryUseCase: GetWeightHistoryUseCase {
        container.makeGetWeightHistoryUseCase()
    }

    private var calculateProgressUseCase: CalculateProgressUseCase {
        container.makeCalculateProgressUseCase()
    }

    // MARK: - Initialization

    init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - Public Methods

    func loadData() async {
        isLoading = true
        error = nil

        await loadUserData()
        await loadHistory(for: .month)
        await calculateStatistics()

        isLoading = false
    }

    func loadHistory(for timeRange: TimeRange) async {
        do {
            let entries = try await getWeightHistoryUseCase.execute(days: timeRange.days)

            recentEntries = entries

            // Convert to chart data
            chartData = entries.reversed().map { entry in
                WeightChartData(date: entry.date, weight: entry.weight)
            }

            // Update current weight
            if let latest = entries.first {
                currentWeight = latest.weight
            }

            // Determine trend
            calculateTrend(from: entries)
        } catch {
            self.error = error
            recentEntries = []
            chartData = []
        }
    }

    func deleteEntry(_ entry: WeightEntry) async {
        do {
            let repository = container.weightRepository
            try await repository.deleteEntry(entry)
            await loadData()
        } catch {
            self.error = error
        }
    }

    // MARK: - Private Methods

    private func loadUserData() async {
        do {
            let repository = container.userRepository
            if let user = try await repository.getCurrentUser() {
                targetWeight = user.targetWeight
                userHeight = user.height ?? 175
                startWeight = user.currentWeight // This should ideally be stored as starting weight

                // Calculate BMI
                let heightInMeters = userHeight / 100
                bmi = currentWeight / (heightInMeters * heightInMeters)
            }
        } catch {
            // Use defaults
        }
    }

    private func calculateTrend(from entries: [WeightEntry]) {
        guard entries.count >= 2 else {
            weightTrend = .stable
            return
        }

        // Compare last week's average with previous week
        let recentWeek = entries.prefix(7)
        let recentAvg = recentWeek.reduce(0) { $0 + $1.weight } / Double(recentWeek.count)

        let olderEntries = entries.dropFirst(7).prefix(7)
        guard !olderEntries.isEmpty else {
            // Compare first and last
            if let first = entries.first, let last = entries.last {
                let diff = last.weight - first.weight
                if diff > 0.5 {
                    weightTrend = .losing
                } else if diff < -0.5 {
                    weightTrend = .gaining
                } else {
                    weightTrend = .stable
                }
            }
            return
        }

        let olderAvg = olderEntries.reduce(0) { $0 + $1.weight } / Double(olderEntries.count)
        let diff = olderAvg - recentAvg

        if diff > 0.3 {
            weightTrend = .losing
        } else if diff < -0.3 {
            weightTrend = .gaining
        } else {
            weightTrend = .stable
        }
    }

    private func calculateStatistics() async {
        guard !recentEntries.isEmpty else {
            statistics = .empty
            return
        }

        let totalLost = startWeight - currentWeight

        // Calculate weekly average loss
        let weeklyAverage: Double
        if recentEntries.count >= 2,
           let oldest = recentEntries.last,
           let newest = recentEntries.first {
            let daysDiff = Calendar.current.dateComponents([.day], from: oldest.date, to: newest.date).day ?? 1
            let weeks = max(1, Double(daysDiff) / 7.0)
            weeklyAverage = (oldest.weight - newest.weight) / weeks
        } else {
            weeklyAverage = 0
        }

        let daysTracked = recentEntries.count

        statistics = WeightStatistics(
            totalLost: totalLost,
            weeklyAverage: weeklyAverage,
            daysTracked: daysTracked
        )
    }
}

// MARK: - Supporting Types

struct WeightStatistics {
    let totalLost: Double
    let weeklyAverage: Double
    let daysTracked: Int

    static let empty = WeightStatistics(totalLost: 0, weeklyAverage: 0, daysTracked: 0)
}
