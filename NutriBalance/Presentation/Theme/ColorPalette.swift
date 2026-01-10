import SwiftUI

/// Application color palette following the design specification.
/// Uses semantic naming for easy maintenance and consistency.
enum ColorPalette {

    // MARK: - Primary Accent

    /// Primary accent color - Vibrant Teal (#00BFA5)
    static let primary = Color(hex: "00BFA5")

    /// Light variant of primary color
    static let primaryLight = Color(hex: "5DF2D6")

    /// Dark variant of primary color
    static let primaryDark = Color(hex: "008E76")

    // MARK: - Secondary Accent

    /// Secondary accent color - Coral (#FF6B6B)
    static let secondary = Color(hex: "FF6B6B")

    // MARK: - Backgrounds

    /// Primary background - Pure White
    static let background = Color.white

    /// Secondary background - Light Gray (#F8F9FA)
    static let backgroundSecondary = Color(hex: "F8F9FA")

    /// Card background - White
    static let cardBackground = Color.white

    /// Input field background
    static let inputBackground = Color(hex: "F5F5F5")

    // MARK: - Text Colors

    /// Primary text - Charcoal (#333333)
    static let textPrimary = Color(hex: "333333")

    /// Secondary text - Medium Gray (#666666)
    static let textSecondary = Color(hex: "666666")

    /// Tertiary text - Light Gray (#999999)
    static let textTertiary = Color(hex: "999999")

    // MARK: - Meal Category Colors

    /// Breakfast color - Warm Yellow (#FFD54F)
    static let breakfast = Color(hex: "FFD54F")

    /// Morning snack color - Light Orange (#FFAB40)
    static let morningSnack = Color(hex: "FFAB40")

    /// Lunch color - Fresh Green (#66BB6A)
    static let lunch = Color(hex: "66BB6A")

    /// Afternoon snack color - Soft Purple (#AB47BC)
    static let afternoonSnack = Color(hex: "AB47BC")

    /// Dinner color - Deep Blue (#42A5F5)
    static let dinner = Color(hex: "42A5F5")

    /// Evening snack color - Lavender (#7E57C2)
    static let eveningSnack = Color(hex: "7E57C2")

    /// Other meal color - Cyan (#26C6DA)
    static let otherMeal = Color(hex: "26C6DA")

    // MARK: - Semantic Colors

    /// Success color - Soft Green (#4CAF50)
    static let success = Color(hex: "4CAF50")

    /// Warning color - Warm Orange (#FF9800)
    static let warning = Color(hex: "FF9800")

    /// Error color - Soft Red (#F44336)
    static let error = Color(hex: "F44336")

    // MARK: - Special

    /// Water/Hydration color - Sky Blue (#29B6F6)
    static let water = Color(hex: "29B6F6")

    /// Divider color
    static let divider = Color(hex: "E0E0E0")

    /// Shadow color
    static let shadow = Color.black.opacity(0.08)

    // MARK: - Meal Category Color Helper

    /// Returns the color for a specific meal category
    static func color(for category: MealCategory) -> Color {
        switch category {
        case .breakfast:
            return breakfast
        case .morningSnack:
            return morningSnack
        case .lunch:
            return lunch
        case .afternoonSnack:
            return afternoonSnack
        case .dinner:
            return dinner
        case .eveningSnack:
            return eveningSnack
        case .other:
            return otherMeal
        }
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    /// Initialize a Color from a hex string
    /// - Parameter hex: Hex color string (with or without # prefix)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Returns the hex string representation of the color
    var hexString: String {
        guard let components = UIColor(self).cgColor.components else {
            return "000000"
        }

        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)

        return String(format: "%02X%02X%02X", r, g, b)
    }
}
