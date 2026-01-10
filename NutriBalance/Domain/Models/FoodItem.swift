import Foundation

/// Represents a reusable food item template that can be saved as a favorite
/// or used for quick entry suggestions.
struct FoodItem: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var brand: String?

    // MARK: - Nutrition per 100g/100ml

    var caloriesPer100: Double?
    var proteinPer100: Double?
    var carbsPer100: Double?
    var fatPer100: Double?
    var fiberPer100: Double?
    var sugarPer100: Double?

    // MARK: - Default Serving

    var defaultServingSize: Double
    var defaultServingUnit: PortionUnit

    // MARK: - Categorization

    var category: FoodItemCategory?
    var tags: [String]

    // MARK: - Usage Tracking

    var isFavorite: Bool
    var useCount: Int
    var lastUsedAt: Date?

    // MARK: - Metadata

    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        brand: String? = nil,
        caloriesPer100: Double? = nil,
        proteinPer100: Double? = nil,
        carbsPer100: Double? = nil,
        fatPer100: Double? = nil,
        fiberPer100: Double? = nil,
        sugarPer100: Double? = nil,
        defaultServingSize: Double = 100,
        defaultServingUnit: PortionUnit = .grams,
        category: FoodItemCategory? = nil,
        tags: [String] = [],
        isFavorite: Bool = false,
        useCount: Int = 0,
        lastUsedAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.caloriesPer100 = caloriesPer100
        self.proteinPer100 = proteinPer100
        self.carbsPer100 = carbsPer100
        self.fatPer100 = fatPer100
        self.fiberPer100 = fiberPer100
        self.sugarPer100 = sugarPer100
        self.defaultServingSize = defaultServingSize
        self.defaultServingUnit = defaultServingUnit
        self.category = category
        self.tags = tags
        self.isFavorite = isFavorite
        self.useCount = useCount
        self.lastUsedAt = lastUsedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Computed Properties

    /// Display name including brand if available
    var displayName: String {
        if let brand = brand, !brand.isEmpty {
            return "\(name) (\(brand))"
        }
        return name
    }

    /// Calculate calories for a given portion
    func calories(for portion: Double, unit: PortionUnit) -> Int? {
        guard let caloriesPer100 = caloriesPer100 else { return nil }
        let factor = conversionFactor(from: unit, size: portion)
        return Int(caloriesPer100 * factor)
    }

    /// Calculate protein for a given portion
    func protein(for portion: Double, unit: PortionUnit) -> Double? {
        guard let proteinPer100 = proteinPer100 else { return nil }
        let factor = conversionFactor(from: unit, size: portion)
        return proteinPer100 * factor
    }

    /// Calculate carbs for a given portion
    func carbs(for portion: Double, unit: PortionUnit) -> Double? {
        guard let carbsPer100 = carbsPer100 else { return nil }
        let factor = conversionFactor(from: unit, size: portion)
        return carbsPer100 * factor
    }

    /// Calculate fat for a given portion
    func fat(for portion: Double, unit: PortionUnit) -> Double? {
        guard let fatPer100 = fatPer100 else { return nil }
        let factor = conversionFactor(from: unit, size: portion)
        return fatPer100 * factor
    }

    /// Create a food entry from this item
    func toFoodEntry(
        mealCategory: MealCategory,
        portionSize: Double? = nil,
        portionUnit: PortionUnit? = nil,
        date: Date = Date()
    ) -> FoodEntry {
        let size = portionSize ?? defaultServingSize
        let unit = portionUnit ?? defaultServingUnit

        return FoodEntry(
            date: date,
            mealCategory: mealCategory,
            foodName: name,
            portionSize: size,
            portionUnit: unit,
            calories: calories(for: size, unit: unit),
            protein: protein(for: size, unit: unit),
            carbs: carbs(for: size, unit: unit),
            fat: fat(for: size, unit: unit),
            fiber: fiberPer100.map { $0 * conversionFactor(from: unit, size: size) },
            sugar: sugarPer100.map { $0 * conversionFactor(from: unit, size: size) },
            linkedFoodItemId: id
        )
    }

    // MARK: - Private Helpers

    private func conversionFactor(from unit: PortionUnit, size: Double) -> Double {
        // For grams and ml, divide by 100 to get factor
        // For other units, assume serving size represents approximately 100g worth
        switch unit {
        case .grams, .milliliters:
            return size / 100.0
        default:
            // For pieces, cups, etc., use the default serving as reference
            return (size * defaultServingSize) / 100.0
        }
    }
}

// MARK: - Food Item Category

enum FoodItemCategory: String, CaseIterable, Identifiable, Codable {
    case grains = "grains"
    case protein = "protein"
    case dairy = "dairy"
    case fruits = "fruits"
    case vegetables = "vegetables"
    case fats = "fats"
    case sweets = "sweets"
    case beverages = "beverages"
    case prepared = "prepared"
    case other = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .grains:
            return String(localized: "category.grains", defaultValue: "Grains & Cereals")
        case .protein:
            return String(localized: "category.protein", defaultValue: "Protein")
        case .dairy:
            return String(localized: "category.dairy", defaultValue: "Dairy")
        case .fruits:
            return String(localized: "category.fruits", defaultValue: "Fruits")
        case .vegetables:
            return String(localized: "category.vegetables", defaultValue: "Vegetables")
        case .fats:
            return String(localized: "category.fats", defaultValue: "Fats & Oils")
        case .sweets:
            return String(localized: "category.sweets", defaultValue: "Sweets & Snacks")
        case .beverages:
            return String(localized: "category.beverages", defaultValue: "Beverages")
        case .prepared:
            return String(localized: "category.prepared", defaultValue: "Prepared Foods")
        case .other:
            return String(localized: "category.other", defaultValue: "Other")
        }
    }

    var iconName: String {
        switch self {
        case .grains:
            return "leaf.circle.fill"
        case .protein:
            return "fork.knife.circle.fill"
        case .dairy:
            return "mug.fill"
        case .fruits:
            return "apple.logo"
        case .vegetables:
            return "carrot.fill"
        case .fats:
            return "drop.fill"
        case .sweets:
            return "birthday.cake.fill"
        case .beverages:
            return "cup.and.saucer.fill"
        case .prepared:
            return "takeoutbag.and.cup.and.straw.fill"
        case .other:
            return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Mock Data

extension FoodItem {
    static var mock: FoodItem {
        FoodItem(
            name: "Oatmeal",
            brand: "Quaker",
            caloriesPer100: 367,
            proteinPer100: 12.5,
            carbsPer100: 68,
            fatPer100: 6.5,
            fiberPer100: 10,
            defaultServingSize: 40,
            defaultServingUnit: .grams,
            category: .grains,
            tags: ["breakfast", "fiber", "healthy"],
            isFavorite: true,
            useCount: 15
        )
    }

    static var mockFavorites: [FoodItem] {
        [
            FoodItem(
                name: "Banana",
                caloriesPer100: 89,
                proteinPer100: 1.1,
                carbsPer100: 23,
                fatPer100: 0.3,
                defaultServingSize: 1,
                defaultServingUnit: .pieces,
                category: .fruits,
                isFavorite: true,
                useCount: 20
            ),
            FoodItem(
                name: "Greek Yogurt",
                brand: "Fage",
                caloriesPer100: 59,
                proteinPer100: 10,
                carbsPer100: 3.6,
                fatPer100: 0.7,
                defaultServingSize: 150,
                defaultServingUnit: .grams,
                category: .dairy,
                isFavorite: true,
                useCount: 12
            ),
            FoodItem(
                name: "Chicken Breast",
                caloriesPer100: 165,
                proteinPer100: 31,
                carbsPer100: 0,
                fatPer100: 3.6,
                defaultServingSize: 150,
                defaultServingUnit: .grams,
                category: .protein,
                isFavorite: true,
                useCount: 18
            )
        ]
    }
}
