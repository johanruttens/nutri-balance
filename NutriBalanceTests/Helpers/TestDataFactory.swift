import Foundation
@testable import NutriBalance

/// Factory for creating test data objects.
enum TestDataFactory {

    // MARK: - User

    static func makeUser(
        id: UUID = UUID(),
        firstName: String = "Test",
        lastName: String? = "User",
        currentWeight: Double = 80.0,
        targetWeight: Double = 75.0,
        dailyCalorieGoal: Int = 2000,
        dailyWaterGoal: Double = 2500,
        activityLevel: ActivityLevel = .moderatelyActive,
        onboardingCompleted: Bool = true
    ) -> User {
        User(
            id: id,
            firstName: firstName,
            lastName: lastName,
            currentWeight: currentWeight,
            targetWeight: targetWeight,
            dailyCalorieGoal: dailyCalorieGoal,
            dailyWaterGoal: dailyWaterGoal,
            activityLevel: activityLevel,
            preferredLanguage: "en",
            notificationsEnabled: true,
            onboardingCompleted: onboardingCompleted
        )
    }

    // MARK: - Food Entry

    static func makeFoodEntry(
        id: UUID = UUID(),
        date: Date = Date(),
        mealCategory: MealCategory = .lunch,
        foodName: String = "Test Food",
        portionSize: Double = 100,
        portionUnit: PortionUnit = .grams,
        calories: Int? = 250,
        protein: Double? = 15,
        carbs: Double? = 30,
        fat: Double? = 8
    ) -> FoodEntry {
        FoodEntry(
            id: id,
            date: date,
            mealCategory: mealCategory,
            foodName: foodName,
            portionSize: portionSize,
            portionUnit: portionUnit,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat
        )
    }

    static func makeFoodEntries(count: Int, date: Date = Date()) -> [FoodEntry] {
        (0..<count).map { index in
            makeFoodEntry(
                foodName: "Food \(index + 1)",
                calories: 200 + (index * 50),
                protein: 10 + Double(index * 2),
                carbs: 20 + Double(index * 3),
                fat: 5 + Double(index)
            )
        }
    }

    // MARK: - Food Item

    static func makeFoodItem(
        id: UUID = UUID(),
        name: String = "Test Item",
        brand: String? = nil,
        caloriesPer100: Double? = 150,
        proteinPer100: Double? = 10,
        carbsPer100: Double? = 20,
        fatPer100: Double? = 5,
        defaultServingSize: Double = 100,
        defaultServingUnit: PortionUnit = .grams,
        isFavorite: Bool = false,
        useCount: Int = 0
    ) -> FoodItem {
        FoodItem(
            id: id,
            name: name,
            brand: brand,
            caloriesPer100: caloriesPer100,
            proteinPer100: proteinPer100,
            carbsPer100: carbsPer100,
            fatPer100: fatPer100,
            defaultServingSize: defaultServingSize,
            defaultServingUnit: defaultServingUnit,
            isFavorite: isFavorite,
            useCount: useCount
        )
    }

    // MARK: - Drink Entry

    static func makeDrinkEntry(
        id: UUID = UUID(),
        date: Date = Date(),
        drinkType: DrinkType = .water,
        amount: Double = 250
    ) -> DrinkEntry {
        DrinkEntry(
            id: id,
            date: date,
            drinkType: drinkType,
            amount: amount
        )
    }

    // MARK: - Weight Entry

    static func makeWeightEntry(
        id: UUID = UUID(),
        date: Date = Date(),
        weight: Double = 80.0,
        notes: String? = nil
    ) -> WeightEntry {
        WeightEntry(
            id: id,
            date: date,
            weight: weight,
            notes: notes
        )
    }

    // MARK: - Date Helpers

    static func date(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    }

    static func date(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
}
