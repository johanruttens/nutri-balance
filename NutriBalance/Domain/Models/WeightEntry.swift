import Foundation
import SwiftUI

/// Represents a weight measurement entry.
struct WeightEntry: Identifiable, Equatable, Codable {
    let id: UUID
    var date: Date
    var weight: Double // in kg
    var notes: String?

    // MARK: - Optional Measurements

    var bodyFatPercentage: Double?
    var muscleMass: Double? // in kg
    var waistCircumference: Double? // in cm
    var hipCircumference: Double? // in cm

    // MARK: - Metadata

    var createdAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        weight: Double,
        notes: String? = nil,
        bodyFatPercentage: Double? = nil,
        muscleMass: Double? = nil,
        waistCircumference: Double? = nil,
        hipCircumference: Double? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.weight = weight
        self.notes = notes
        self.bodyFatPercentage = bodyFatPercentage
        self.muscleMass = muscleMass
        self.waistCircumference = waistCircumference
        self.hipCircumference = hipCircumference
        self.createdAt = createdAt
    }

    // MARK: - Computed Properties

    /// Formatted weight string
    var weightString: String {
        String(format: "%.1f kg", weight)
    }

    /// Waist-to-hip ratio if both measurements are available
    var waistToHipRatio: Double? {
        guard let waist = waistCircumference, let hip = hipCircumference, hip > 0 else {
            return nil
        }
        return waist / hip
    }
}

// MARK: - Weight Progress

struct WeightProgress: Equatable {
    let currentWeight: Double
    let targetWeight: Double
    let startWeight: Double
    let entries: [WeightEntry]

    /// Total weight lost from start
    var totalLost: Double {
        startWeight - currentWeight
    }

    /// Weight remaining to lose
    var remaining: Double {
        currentWeight - targetWeight
    }

    /// Progress percentage (0.0 to 1.0)
    var progressPercentage: Double {
        let totalToLose = startWeight - targetWeight
        guard totalToLose > 0 else { return 1.0 }
        return min(1.0, max(0.0, totalLost / totalToLose))
    }

    /// Whether goal has been reached
    var goalReached: Bool {
        currentWeight <= targetWeight
    }

    /// Average weekly weight change
    var weeklyAverage: Double? {
        guard entries.count >= 2 else { return nil }
        let sortedEntries = entries.sorted { $0.date < $1.date }
        guard let first = sortedEntries.first, let last = sortedEntries.last else { return nil }

        let weeks = Calendar.current.dateComponents([.day], from: first.date, to: last.date).day.map { Double($0) / 7.0 } ?? 0
        guard weeks > 0 else { return nil }

        return (first.weight - last.weight) / weeks
    }

    /// Estimated days to reach goal based on current progress
    var estimatedDaysToGoal: Int? {
        guard let weeklyLoss = weeklyAverage, weeklyLoss > 0 else { return nil }
        let daysPerKg = 7.0 / weeklyLoss
        return Int(remaining * daysPerKg)
    }

    /// Trend direction
    var trend: WeightTrend {
        guard entries.count >= 3 else { return .stable }

        let recentEntries = entries.sorted { $0.date > $1.date }.prefix(5)
        guard recentEntries.count >= 2 else { return .stable }

        let weights = recentEntries.map { $0.weight }
        let avgRecent = weights.prefix(2).reduce(0, +) / Double(min(2, weights.count))
        let avgOlder = weights.suffix(from: min(2, weights.count)).reduce(0, +) / Double(max(1, weights.count - 2))

        let difference = avgOlder - avgRecent
        if difference > 0.3 {
            return .losing
        } else if difference < -0.3 {
            return .gaining
        }
        return .stable
    }
}

enum WeightTrend: String, Codable {
    case losing
    case stable
    case gaining

    var displayName: String {
        switch self {
        case .losing:
            return L("weight.trend.losing")
        case .stable:
            return L("weight.trend.stable")
        case .gaining:
            return L("weight.trend.gaining")
        }
    }

    var iconName: String {
        switch self {
        case .losing:
            return "arrow.down.right"
        case .stable:
            return "arrow.right"
        case .gaining:
            return "arrow.up.right"
        }
    }

    var color: Color {
        switch self {
        case .losing:
            return ColorPalette.success
        case .stable:
            return ColorPalette.warning
        case .gaining:
            return ColorPalette.error
        }
    }
}

// MARK: - Mock Data

extension WeightEntry {
    static var mock: WeightEntry {
        WeightEntry(weight: 85.0)
    }

    static var mockHistory: [WeightEntry] {
        let calendar = Calendar.current
        let today = Date()

        return (0..<30).compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { return nil }
            // Simulate gradual weight loss with some fluctuation
            let baseWeight = 85.0 - (Double(30 - daysAgo) * 0.05)
            let fluctuation = Double.random(in: -0.3...0.3)
            return WeightEntry(date: date, weight: baseWeight + fluctuation)
        }.reversed()
    }
}
