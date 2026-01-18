import Foundation
import SwiftUI

/// Represents the different meal categories for food tracking.
/// Each category has a specific time window and visual styling.
enum MealCategory: Int16, CaseIterable, Identifiable, Codable {
    case breakfast = 0
    case morningSnack = 1
    case lunch = 2
    case afternoonSnack = 3
    case dinner = 4
    case eveningSnack = 5
    case other = 6

    var id: Int16 { rawValue }

    // MARK: - Display Names

    /// Localized display name for the meal category
    var displayName: String {
        switch self {
        case .breakfast:
            return L("meal.breakfast")
        case .morningSnack:
            return L("meal.morningSnack")
        case .lunch:
            return L("meal.lunch")
        case .afternoonSnack:
            return L("meal.afternoonSnack")
        case .dinner:
            return L("meal.dinner")
        case .eveningSnack:
            return L("meal.eveningSnack")
        case .other:
            return L("meal.other")
        }
    }

    // MARK: - Icons

    /// SF Symbol name for the meal category
    var iconName: String {
        switch self {
        case .breakfast:
            return "sunrise.fill"
        case .morningSnack:
            return "apple.logo"
        case .lunch:
            return "fork.knife"
        case .afternoonSnack:
            return "leaf.fill"
        case .dinner:
            return "moon.stars.fill"
        case .eveningSnack:
            return "moon.fill"
        case .other:
            return "ellipsis.circle.fill"
        }
    }

    // MARK: - Colors

    /// Color associated with the meal category
    var color: Color {
        ColorPalette.color(for: self)
    }

    // MARK: - Time Windows

    /// Default start hour for this meal category (24-hour format)
    var defaultStartHour: Int {
        switch self {
        case .breakfast:
            return 6
        case .morningSnack:
            return 10
        case .lunch:
            return 12
        case .afternoonSnack:
            return 14
        case .dinner:
            return 17
        case .eveningSnack:
            return 21
        case .other:
            return 0
        }
    }

    /// Default end hour for this meal category (24-hour format)
    var defaultEndHour: Int {
        switch self {
        case .breakfast:
            return 10
        case .morningSnack:
            return 12
        case .lunch:
            return 14
        case .afternoonSnack:
            return 17
        case .dinner:
            return 21
        case .eveningSnack:
            return 23
        case .other:
            return 24
        }
    }

    // MARK: - Helpers

    /// Returns the suggested meal category for a given time
    static func suggested(for date: Date) -> MealCategory {
        let hour = Calendar.current.component(.hour, from: date)

        for category in MealCategory.allCases {
            if hour >= category.defaultStartHour && hour < category.defaultEndHour {
                return category
            }
        }

        return .other
    }

    /// All main meal categories (excluding snacks and other)
    static var mainMeals: [MealCategory] {
        [.breakfast, .lunch, .dinner]
    }

    /// All snack categories
    static var snacks: [MealCategory] {
        [.morningSnack, .afternoonSnack, .eveningSnack]
    }

    /// Ordered list for display purposes
    static var orderedForDisplay: [MealCategory] {
        [.breakfast, .morningSnack, .lunch, .afternoonSnack, .dinner, .eveningSnack]
    }
}
