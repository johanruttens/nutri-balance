import Foundation

/// Represents a single food entry in the user's daily log.
struct FoodEntry: Identifiable, Equatable, Codable {
    let id: UUID
    var date: Date
    var mealCategory: MealCategory
    var foodName: String
    var portionSize: Double
    var portionUnit: PortionUnit

    // MARK: - Nutrition

    var calories: Int?
    var protein: Double? // grams
    var carbs: Double? // grams
    var fat: Double? // grams
    var fiber: Double? // grams
    var sugar: Double? // grams

    // MARK: - Additional Info

    var notes: String?
    var hungerLevel: Int? // 1-5 scale
    var moodEmoji: String?

    // MARK: - Relationships

    var linkedFoodItemId: UUID?

    // MARK: - Metadata

    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        mealCategory: MealCategory,
        foodName: String,
        portionSize: Double,
        portionUnit: PortionUnit = .grams,
        calories: Int? = nil,
        protein: Double? = nil,
        carbs: Double? = nil,
        fat: Double? = nil,
        fiber: Double? = nil,
        sugar: Double? = nil,
        notes: String? = nil,
        hungerLevel: Int? = nil,
        moodEmoji: String? = nil,
        linkedFoodItemId: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.mealCategory = mealCategory
        self.foodName = foodName
        self.portionSize = portionSize
        self.portionUnit = portionUnit
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.notes = notes
        self.hungerLevel = hungerLevel
        self.moodEmoji = moodEmoji
        self.linkedFoodItemId = linkedFoodItemId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Computed Properties

    /// Formatted portion string (e.g., "150 g" or "2 pieces")
    var portionString: String {
        let formattedSize: String
        if portionSize.truncatingRemainder(dividingBy: 1) == 0 {
            formattedSize = String(format: "%.0f", portionSize)
        } else {
            formattedSize = String(format: "%.1f", portionSize)
        }
        return "\(formattedSize) \(portionUnit.abbreviation)"
    }

    /// Whether nutrition information is available
    var hasNutritionInfo: Bool {
        calories != nil || protein != nil || carbs != nil || fat != nil
    }

    /// Total macros in grams
    var totalMacros: Double {
        (protein ?? 0) + (carbs ?? 0) + (fat ?? 0)
    }
}

// MARK: - Portion Units

enum PortionUnit: String, CaseIterable, Identifiable, Codable {
    case grams = "g"
    case milliliters = "ml"
    case pieces = "pcs"
    case cups = "cup"
    case tablespoons = "tbsp"
    case teaspoons = "tsp"
    case slices = "slice"
    case servings = "serving"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .grams:
            return L("unit.grams")
        case .milliliters:
            return L("unit.milliliters")
        case .pieces:
            return L("unit.pieces")
        case .cups:
            return L("unit.cups")
        case .tablespoons:
            return L("unit.tablespoons")
        case .teaspoons:
            return L("unit.teaspoons")
        case .slices:
            return L("unit.slices")
        case .servings:
            return L("unit.servings")
        }
    }

    var abbreviation: String {
        switch self {
        case .grams:
            return "g"
        case .milliliters:
            return "ml"
        case .pieces:
            return "pcs"
        case .cups:
            return "cup"
        case .tablespoons:
            return "tbsp"
        case .teaspoons:
            return "tsp"
        case .slices:
            return "slice"
        case .servings:
            return "srv"
        }
    }
}

// MARK: - Mock Data

extension FoodEntry {
    static var mock: FoodEntry {
        FoodEntry(
            mealCategory: .breakfast,
            foodName: "Oatmeal with Berries",
            portionSize: 250,
            portionUnit: .grams,
            calories: 350,
            protein: 12,
            carbs: 55,
            fat: 8,
            fiber: 6
        )
    }

    static var mockBreakfast: [FoodEntry] {
        [
            FoodEntry(
                mealCategory: .breakfast,
                foodName: "Oatmeal",
                portionSize: 150,
                portionUnit: .grams,
                calories: 250,
                protein: 8,
                carbs: 45,
                fat: 5
            ),
            FoodEntry(
                mealCategory: .breakfast,
                foodName: "Banana",
                portionSize: 1,
                portionUnit: .pieces,
                calories: 105,
                protein: 1,
                carbs: 27,
                fat: 0
            ),
            FoodEntry(
                mealCategory: .breakfast,
                foodName: "Greek Yogurt",
                portionSize: 150,
                portionUnit: .grams,
                calories: 100,
                protein: 17,
                carbs: 6,
                fat: 1
            )
        ]
    }
}
