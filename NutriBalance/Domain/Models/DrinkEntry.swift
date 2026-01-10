import Foundation

/// Represents a single drink entry for hydration tracking.
struct DrinkEntry: Identifiable, Equatable, Codable {
    let id: UUID
    var date: Date
    var drinkType: DrinkType
    var name: String?
    var amount: Double // in milliliters
    var calories: Int?
    var caffeineContent: Double? // in mg
    var sugarContent: Double? // in grams
    var notes: String?

    // MARK: - Metadata

    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        drinkType: DrinkType,
        name: String? = nil,
        amount: Double,
        calories: Int? = nil,
        caffeineContent: Double? = nil,
        sugarContent: Double? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.drinkType = drinkType
        self.name = name
        self.amount = amount
        self.calories = calories
        self.caffeineContent = caffeineContent
        self.sugarContent = sugarContent
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Computed Properties

    /// Display name (custom name or drink type name)
    var displayName: String {
        name ?? drinkType.displayName
    }

    /// Formatted amount string
    var amountString: String {
        if amount >= 1000 {
            return String(format: "%.1f L", amount / 1000)
        }
        return "\(Int(amount)) ml"
    }

    /// Effective hydration value considering drink type
    var effectiveHydration: Double {
        amount * drinkType.hydrationFactor
    }

    /// Whether this drink has alcohol
    var isAlcoholic: Bool {
        drinkType.hasAlcohol
    }

    /// Whether this drink has caffeine
    var hasCaffeine: Bool {
        drinkType.hasCaffeine || (caffeineContent ?? 0) > 0
    }
}

// MARK: - Mock Data

extension DrinkEntry {
    static var mock: DrinkEntry {
        DrinkEntry(
            drinkType: .water,
            amount: 250
        )
    }

    static var mockDayEntries: [DrinkEntry] {
        [
            DrinkEntry(drinkType: .water, amount: 250),
            DrinkEntry(drinkType: .coffee, name: "Morning Coffee", amount: 150, calories: 5, caffeineContent: 95),
            DrinkEntry(drinkType: .water, amount: 500),
            DrinkEntry(drinkType: .tea, name: "Green Tea", amount: 200, caffeineContent: 30),
            DrinkEntry(drinkType: .water, amount: 250),
            DrinkEntry(drinkType: .juice, name: "Orange Juice", amount: 200, calories: 90, sugarContent: 20)
        ]
    }
}
