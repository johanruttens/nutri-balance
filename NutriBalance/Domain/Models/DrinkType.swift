import Foundation
import SwiftUI

/// Represents the different types of drinks for hydration tracking.
enum DrinkType: Int16, CaseIterable, Identifiable, Codable {
    case water = 0
    case coffee = 1
    case tea = 2
    case juice = 3
    case soda = 4
    case milk = 5
    case alcoholic = 6
    case smoothie = 7
    case other = 8

    var id: Int16 { rawValue }

    // MARK: - Display Names

    /// Localized display name for the drink type
    var displayName: String {
        switch self {
        case .water:
            return String(localized: "drink.water", defaultValue: "Water")
        case .coffee:
            return String(localized: "drink.coffee", defaultValue: "Coffee")
        case .tea:
            return String(localized: "drink.tea", defaultValue: "Tea")
        case .juice:
            return String(localized: "drink.juice", defaultValue: "Juice")
        case .soda:
            return String(localized: "drink.soda", defaultValue: "Soft Drink")
        case .milk:
            return String(localized: "drink.milk", defaultValue: "Milk")
        case .alcoholic:
            return String(localized: "drink.alcoholic", defaultValue: "Alcoholic")
        case .smoothie:
            return String(localized: "drink.smoothie", defaultValue: "Smoothie")
        case .other:
            return String(localized: "drink.other", defaultValue: "Other")
        }
    }

    // MARK: - Icons

    /// SF Symbol name for the drink type
    var iconName: String {
        switch self {
        case .water:
            return "drop.fill"
        case .coffee:
            return "cup.and.saucer.fill"
        case .tea:
            return "leaf.fill"
        case .juice:
            return "carrot.fill"
        case .soda:
            return "bubbles.and.sparkles.fill"
        case .milk:
            return "mug.fill"
        case .alcoholic:
            return "wineglass.fill"
        case .smoothie:
            return "takeoutbag.and.cup.and.straw.fill"
        case .other:
            return "cup.and.saucer"
        }
    }

    // MARK: - Colors

    /// Color associated with the drink type
    var color: Color {
        switch self {
        case .water:
            return ColorPalette.water
        case .coffee:
            return Color(hex: "6D4C41")
        case .tea:
            return Color(hex: "8D6E63")
        case .juice:
            return Color(hex: "FF9800")
        case .soda:
            return Color(hex: "F44336")
        case .milk:
            return Color(hex: "ECEFF1")
        case .alcoholic:
            return Color(hex: "7B1FA2")
        case .smoothie:
            return Color(hex: "E91E63")
        case .other:
            return ColorPalette.textSecondary
        }
    }

    // MARK: - Properties

    /// Whether this drink counts towards hydration goals
    var countsTowardsHydration: Bool {
        switch self {
        case .water, .tea, .juice, .milk, .smoothie:
            return true
        case .coffee:
            return true // Coffee does contribute, though less effectively
        case .soda, .alcoholic, .other:
            return false
        }
    }

    /// Hydration factor (1.0 = full hydration value, like water)
    var hydrationFactor: Double {
        switch self {
        case .water:
            return 1.0
        case .tea:
            return 0.9
        case .juice, .smoothie:
            return 0.85
        case .milk:
            return 0.9
        case .coffee:
            return 0.8 // Slight diuretic effect
        case .soda:
            return 0.5
        case .alcoholic:
            return 0.0 // Alcohol is dehydrating
        case .other:
            return 0.5
        }
    }

    /// Whether this drink typically contains caffeine
    var hasCaffeine: Bool {
        switch self {
        case .coffee, .tea, .soda:
            return true
        default:
            return false
        }
    }

    /// Whether this drink typically contains alcohol
    var hasAlcohol: Bool {
        self == .alcoholic
    }

    // MARK: - Default Portions

    /// Default portion size in milliliters
    var defaultPortionMl: Double {
        switch self {
        case .water:
            return 250
        case .coffee:
            return 150
        case .tea:
            return 200
        case .juice:
            return 200
        case .soda:
            return 330
        case .milk:
            return 200
        case .alcoholic:
            return 150
        case .smoothie:
            return 300
        case .other:
            return 200
        }
    }

    /// Quick add portion options in milliliters
    var quickAddOptions: [Int] {
        switch self {
        case .water:
            return [200, 250, 330, 500]
        case .coffee:
            return [100, 150, 200, 300]
        case .tea:
            return [150, 200, 250, 350]
        case .juice:
            return [150, 200, 250, 330]
        case .soda:
            return [200, 330, 500]
        case .milk:
            return [100, 150, 200, 250]
        case .alcoholic:
            return [100, 150, 200, 250]
        case .smoothie:
            return [200, 300, 400, 500]
        case .other:
            return [100, 200, 250, 500]
        }
    }
}
