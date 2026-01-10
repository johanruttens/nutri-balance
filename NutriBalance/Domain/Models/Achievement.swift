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
            return String(localized: "achievement.streak7.title", defaultValue: "7-Day Streak")
        case .streak30Days:
            return String(localized: "achievement.streak30.title", defaultValue: "30-Day Streak")
        case .streak100Days:
            return String(localized: "achievement.streak100.title", defaultValue: "100-Day Streak")
        case .firstKilogram:
            return String(localized: "achievement.firstKg.title", defaultValue: "First Kilogram")
        case .halfwayThere:
            return String(localized: "achievement.halfway.title", defaultValue: "Halfway There")
        case .goalReached:
            return String(localized: "achievement.goalReached.title", defaultValue: "Goal Reached!")
        case .firstEntry:
            return String(localized: "achievement.firstEntry.title", defaultValue: "Getting Started")
        case .hundredEntries:
            return String(localized: "achievement.hundredEntries.title", defaultValue: "Dedicated Logger")
        case .thousandEntries:
            return String(localized: "achievement.thousandEntries.title", defaultValue: "Logging Legend")
        case .hydrationHero:
            return String(localized: "achievement.hydrationHero.title", defaultValue: "Hydration Hero")
        case .waterWeek:
            return String(localized: "achievement.waterWeek.title", defaultValue: "Water Week")
        case .balancedDay:
            return String(localized: "achievement.balancedDay.title", defaultValue: "Balanced Day")
        case .proteinChampion:
            return String(localized: "achievement.proteinChampion.title", defaultValue: "Protein Champion")
        case .fiberFriend:
            return String(localized: "achievement.fiberFriend.title", defaultValue: "Fiber Friend")
        case .veggieVictor:
            return String(localized: "achievement.veggieVictor.title", defaultValue: "Veggie Victor")
        case .earlyBird:
            return String(localized: "achievement.earlyBird.title", defaultValue: "Early Bird")
        case .mealPlanner:
            return String(localized: "achievement.mealPlanner.title", defaultValue: "Meal Planner")
        case .weekendWarrior:
            return String(localized: "achievement.weekendWarrior.title", defaultValue: "Weekend Warrior")
        }
    }

    var description: String {
        switch self {
        case .streak7Days:
            return String(localized: "achievement.streak7.desc", defaultValue: "Log your meals for 7 consecutive days")
        case .streak30Days:
            return String(localized: "achievement.streak30.desc", defaultValue: "Log your meals for 30 consecutive days")
        case .streak100Days:
            return String(localized: "achievement.streak100.desc", defaultValue: "Log your meals for 100 consecutive days")
        case .firstKilogram:
            return String(localized: "achievement.firstKg.desc", defaultValue: "Lose your first kilogram")
        case .halfwayThere:
            return String(localized: "achievement.halfway.desc", defaultValue: "Reach 50% of your weight goal")
        case .goalReached:
            return String(localized: "achievement.goalReached.desc", defaultValue: "Reach your target weight")
        case .firstEntry:
            return String(localized: "achievement.firstEntry.desc", defaultValue: "Log your first food entry")
        case .hundredEntries:
            return String(localized: "achievement.hundredEntries.desc", defaultValue: "Log 100 food entries")
        case .thousandEntries:
            return String(localized: "achievement.thousandEntries.desc", defaultValue: "Log 1000 food entries")
        case .hydrationHero:
            return String(localized: "achievement.hydrationHero.desc", defaultValue: "Meet your daily water goal")
        case .waterWeek:
            return String(localized: "achievement.waterWeek.desc", defaultValue: "Meet your water goal for 7 consecutive days")
        case .balancedDay:
            return String(localized: "achievement.balancedDay.desc", defaultValue: "Achieve balanced macros for a day")
        case .proteinChampion:
            return String(localized: "achievement.proteinChampion.desc", defaultValue: "Meet your protein goal for 7 days")
        case .fiberFriend:
            return String(localized: "achievement.fiberFriend.desc", defaultValue: "Consume 25g+ fiber for 5 days")
        case .veggieVictor:
            return String(localized: "achievement.veggieVictor.desc", defaultValue: "Log vegetables in every meal for a week")
        case .earlyBird:
            return String(localized: "achievement.earlyBird.desc", defaultValue: "Log breakfast before 9 AM for a week")
        case .mealPlanner:
            return String(localized: "achievement.mealPlanner.desc", defaultValue: "Log all 3 main meals for 7 days straight")
        case .weekendWarrior:
            return String(localized: "achievement.weekendWarrior.desc", defaultValue: "Stay within calorie goal on weekends for a month")
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
            return String(localized: "achievement.category.streaks", defaultValue: "Streaks")
        case .weightLoss:
            return String(localized: "achievement.category.weightLoss", defaultValue: "Weight Loss")
        case .logging:
            return String(localized: "achievement.category.logging", defaultValue: "Logging")
        case .hydration:
            return String(localized: "achievement.category.hydration", defaultValue: "Hydration")
        case .nutrition:
            return String(localized: "achievement.category.nutrition", defaultValue: "Nutrition")
        case .consistency:
            return String(localized: "achievement.category.consistency", defaultValue: "Consistency")
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
