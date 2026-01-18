import Foundation
import SwiftUI

/// Represents an achievement that can be earned by the user.
struct Achievement: Identifiable, Equatable, Codable {
    let id: UUID
    let type: AchievementType
    var unlockedAt: Date?
    var progress: Double // 0.0 to 1.0

    // MARK: - Computed Properties

    var isUnlocked: Bool {
        unlockedAt != nil
    }

    var displayName: String {
        type.displayName
    }

    var description: String {
        type.description
    }

    var iconName: String {
        type.iconName
    }

    var color: Color {
        type.color
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        type: AchievementType,
        unlockedAt: Date? = nil,
        progress: Double = 0
    ) {
        self.id = id
        self.type = type
        self.unlockedAt = unlockedAt
        self.progress = progress
    }
}

// MARK: - Achievement Types

enum AchievementType: String, CaseIterable, Identifiable, Codable {
    // Streak achievements
    case streak7Days = "streak_7_days"
    case streak30Days = "streak_30_days"
    case streak100Days = "streak_100_days"

    // Weight loss achievements
    case firstKilogram = "first_kilogram"
    case halfwayThere = "halfway_there"
    case goalReached = "goal_reached"

    // Logging achievements
    case firstEntry = "first_entry"
    case hundredEntries = "hundred_entries"
    case thousandEntries = "thousand_entries"

    // Hydration achievements
    case hydrationHero = "hydration_hero"
    case waterWeek = "water_week"

    // Nutrition achievements
    case balancedDay = "balanced_day"
    case proteinChampion = "protein_champion"
    case fiberFriend = "fiber_friend"
    case veggieVictor = "veggie_victor"

    // Consistency achievements
    case earlyBird = "early_bird"
    case mealPlanner = "meal_planner"
    case weekendWarrior = "weekend_warrior"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .streak7Days:
            return L("achievement.streak7.title")
        case .streak30Days:
            return L("achievement.streak30.title")
        case .streak100Days:
            return L("achievement.streak100.title")
        case .firstKilogram:
            return L("achievement.firstKg.title")
        case .halfwayThere:
            return L("achievement.halfway.title")
        case .goalReached:
            return L("achievement.goalReached.title")
        case .firstEntry:
            return L("achievement.firstEntry.title")
        case .hundredEntries:
            return L("achievement.hundredEntries.title")
        case .thousandEntries:
            return L("achievement.thousandEntries.title")
        case .hydrationHero:
            return L("achievement.hydrationHero.title")
        case .waterWeek:
            return L("achievement.waterWeek.title")
        case .balancedDay:
            return L("achievement.balancedDay.title")
        case .proteinChampion:
            return L("achievement.proteinChampion.title")
        case .fiberFriend:
            return L("achievement.fiberFriend.title")
        case .veggieVictor:
            return L("achievement.veggieVictor.title")
        case .earlyBird:
            return L("achievement.earlyBird.title")
        case .mealPlanner:
            return L("achievement.mealPlanner.title")
        case .weekendWarrior:
            return L("achievement.weekendWarrior.title")
        }
    }

    var description: String {
        switch self {
        case .streak7Days:
            return L("achievement.streak7.desc")
        case .streak30Days:
            return L("achievement.streak30.desc")
        case .streak100Days:
            return L("achievement.streak100.desc")
        case .firstKilogram:
            return L("achievement.firstKg.desc")
        case .halfwayThere:
            return L("achievement.halfway.desc")
        case .goalReached:
            return L("achievement.goalReached.desc")
        case .firstEntry:
            return L("achievement.firstEntry.desc")
        case .hundredEntries:
            return L("achievement.hundredEntries.desc")
        case .thousandEntries:
            return L("achievement.thousandEntries.desc")
        case .hydrationHero:
            return L("achievement.hydrationHero.desc")
        case .waterWeek:
            return L("achievement.waterWeek.desc")
        case .balancedDay:
            return L("achievement.balancedDay.desc")
        case .proteinChampion:
            return L("achievement.proteinChampion.desc")
        case .fiberFriend:
            return L("achievement.fiberFriend.desc")
        case .veggieVictor:
            return L("achievement.veggieVictor.desc")
        case .earlyBird:
            return L("achievement.earlyBird.desc")
        case .mealPlanner:
            return L("achievement.mealPlanner.desc")
        case .weekendWarrior:
            return L("achievement.weekendWarrior.desc")
        }
    }

    var iconName: String {
        switch self {
        case .streak7Days, .streak30Days, .streak100Days:
            return "flame.fill"
        case .firstKilogram, .halfwayThere, .goalReached:
            return "scalemass.fill"
        case .firstEntry, .hundredEntries, .thousandEntries:
            return "checkmark.circle.fill"
        case .hydrationHero, .waterWeek:
            return "drop.fill"
        case .balancedDay:
            return "chart.pie.fill"
        case .proteinChampion:
            return "figure.strengthtraining.traditional"
        case .fiberFriend:
            return "leaf.fill"
        case .veggieVictor:
            return "carrot.fill"
        case .earlyBird:
            return "sunrise.fill"
        case .mealPlanner:
            return "calendar.badge.checkmark"
        case .weekendWarrior:
            return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .streak7Days:
            return .orange
        case .streak30Days:
            return .red
        case .streak100Days:
            return .purple
        case .firstKilogram, .halfwayThere, .goalReached:
            return ColorPalette.primary
        case .firstEntry:
            return .green
        case .hundredEntries:
            return .blue
        case .thousandEntries:
            return .purple
        case .hydrationHero, .waterWeek:
            return ColorPalette.water
        case .balancedDay:
            return ColorPalette.success
        case .proteinChampion:
            return .red
        case .fiberFriend, .veggieVictor:
            return .green
        case .earlyBird:
            return ColorPalette.breakfast
        case .mealPlanner:
            return ColorPalette.lunch
        case .weekendWarrior:
            return .yellow
        }
    }

    var targetValue: Int {
        switch self {
        case .streak7Days:
            return 7
        case .streak30Days:
            return 30
        case .streak100Days:
            return 100
        case .firstKilogram:
            return 1
        case .halfwayThere:
            return 50 // percent
        case .goalReached:
            return 100 // percent
        case .firstEntry:
            return 1
        case .hundredEntries:
            return 100
        case .thousandEntries:
            return 1000
        case .hydrationHero:
            return 1
        case .waterWeek:
            return 7
        case .balancedDay:
            return 1
        case .proteinChampion:
            return 7
        case .fiberFriend:
            return 5
        case .veggieVictor:
            return 7
        case .earlyBird:
            return 7
        case .mealPlanner:
            return 7
        case .weekendWarrior:
            return 4 // weekends in a month
        }
    }

    /// Achievement category for grouping
    var category: AchievementCategory {
        switch self {
        case .streak7Days, .streak30Days, .streak100Days:
            return .streaks
        case .firstKilogram, .halfwayThere, .goalReached:
            return .weightLoss
        case .firstEntry, .hundredEntries, .thousandEntries:
            return .logging
        case .hydrationHero, .waterWeek:
            return .hydration
        case .balancedDay, .proteinChampion, .fiberFriend, .veggieVictor:
            return .nutrition
        case .earlyBird, .mealPlanner, .weekendWarrior:
            return .consistency
        }
    }
}

// MARK: - Achievement Category

enum AchievementCategory: String, CaseIterable, Identifiable {
    case streaks
    case weightLoss
    case logging
    case hydration
    case nutrition
    case consistency

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .streaks:
            return L("achievement.category.streaks")
        case .weightLoss:
            return L("achievement.category.weightLoss")
        case .logging:
            return L("achievement.category.logging")
        case .hydration:
            return L("achievement.category.hydration")
        case .nutrition:
            return L("achievement.category.nutrition")
        case .consistency:
            return L("achievement.category.consistency")
        }
    }

    var achievements: [AchievementType] {
        AchievementType.allCases.filter { $0.category == self }
    }
}

// MARK: - Mock Data

extension Achievement {
    static var mockUnlocked: Achievement {
        Achievement(
            type: .firstEntry,
            unlockedAt: Date(),
            progress: 1.0
        )
    }

    static var mockInProgress: Achievement {
        Achievement(
            type: .streak7Days,
            progress: 0.57 // 4 out of 7 days
        )
    }

    static var mockAll: [Achievement] {
        AchievementType.allCases.enumerated().map { index, type in
            Achievement(
                type: type,
                unlockedAt: index < 3 ? Date() : nil,
                progress: index < 3 ? 1.0 : Double.random(in: 0...0.8)
            )
        }
    }
}
