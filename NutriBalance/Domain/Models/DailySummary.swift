import Foundation

/// Represents a summary of daily nutrition and hydration data.
struct DailySummary: Identifiable, Equatable {
    let id: UUID
    let date: Date

    // MARK: - Food Summary

    let foodEntries: [FoodEntry]
    let totalCalories: Int
    let totalProtein: Double
    let totalCarbs: Double
    let totalFat: Double
    let totalFiber: Double

    // MARK: - Hydration Summary

    let drinkEntries: [DrinkEntry]
    let totalWaterIntake: Double // effective hydration in ml
    let totalCaffeine: Double // in mg

    // MARK: - Goals

    let calorieGoal: Int
    let waterGoal: Double
    let proteinGoal: Double?
    let carbsGoal: Double?
    let fatGoal: Double?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        foodEntries: [FoodEntry] = [],
        drinkEntries: [DrinkEntry] = [],
        calorieGoal: Int = 2000,
        waterGoal: Double = 2000,
        proteinGoal: Double? = nil,
        carbsGoal: Double? = nil,
        fatGoal: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.foodEntries = foodEntries
        self.drinkEntries = drinkEntries
        self.calorieGoal = calorieGoal
        self.waterGoal = waterGoal
        self.proteinGoal = proteinGoal
        self.carbsGoal = carbsGoal
        self.fatGoal = fatGoal

        // Calculate totals
        self.totalCalories = foodEntries.compactMap { $0.calories }.reduce(0, +)
        self.totalProtein = foodEntries.compactMap { $0.protein }.reduce(0, +)
        self.totalCarbs = foodEntries.compactMap { $0.carbs }.reduce(0, +)
        self.totalFat = foodEntries.compactMap { $0.fat }.reduce(0, +)
        self.totalFiber = foodEntries.compactMap { $0.fiber }.reduce(0, +)

        self.totalWaterIntake = drinkEntries.reduce(0) { $0 + $1.effectiveHydration }
        self.totalCaffeine = drinkEntries.compactMap { $0.caffeineContent }.reduce(0, +)
    }

    // MARK: - Computed Properties

    /// Calories remaining for the day
    var caloriesRemaining: Int {
        max(0, calorieGoal - totalCalories)
    }

    /// Whether calorie goal has been exceeded
    var isOverCalorieGoal: Bool {
        totalCalories > calorieGoal
    }

    /// Calorie progress (0.0 to 1.0+)
    var calorieProgress: Double {
        guard calorieGoal > 0 else { return 0 }
        return Double(totalCalories) / Double(calorieGoal)
    }

    /// Water progress (0.0 to 1.0+)
    var waterProgress: Double {
        guard waterGoal > 0 else { return 0 }
        return totalWaterIntake / waterGoal
    }

    /// Protein progress if goal is set
    var proteinProgress: Double? {
        guard let goal = proteinGoal, goal > 0 else { return nil }
        return totalProtein / goal
    }

    /// Carbs progress if goal is set
    var carbsProgress: Double? {
        guard let goal = carbsGoal, goal > 0 else { return nil }
        return totalCarbs / goal
    }

    /// Fat progress if goal is set
    var fatProgress: Double? {
        guard let goal = fatGoal, goal > 0 else { return nil }
        return totalFat / goal
    }

    /// Entries grouped by meal category
    var entriesByMeal: [MealCategory: [FoodEntry]] {
        Dictionary(grouping: foodEntries) { $0.mealCategory }
    }

    /// Calories by meal category
    var caloriesByMeal: [MealCategory: Int] {
        var result: [MealCategory: Int] = [:]
        for (category, entries) in entriesByMeal {
            result[category] = entries.compactMap { $0.calories }.reduce(0, +)
        }
        return result
    }

    /// Meal categories that have been logged
    var loggedMealCategories: Set<MealCategory> {
        Set(foodEntries.map { $0.mealCategory })
    }

    /// Whether all main meals have been logged
    var hasLoggedAllMainMeals: Bool {
        MealCategory.mainMeals.allSatisfy { loggedMealCategories.contains($0) }
    }

    /// Macro distribution percentages
    var macroDistribution: MacroDistribution {
        let totalMacroCalories = (totalProtein * 4) + (totalCarbs * 4) + (totalFat * 9)
        guard totalMacroCalories > 0 else {
            return MacroDistribution(proteinPercentage: 0, carbsPercentage: 0, fatPercentage: 0)
        }

        return MacroDistribution(
            proteinPercentage: (totalProtein * 4) / totalMacroCalories * 100,
            carbsPercentage: (totalCarbs * 4) / totalMacroCalories * 100,
            fatPercentage: (totalFat * 9) / totalMacroCalories * 100
        )
    }
}

// MARK: - Macro Distribution

struct MacroDistribution: Equatable {
    let proteinPercentage: Double
    let carbsPercentage: Double
    let fatPercentage: Double

    /// Whether the distribution is balanced (roughly 30/40/30 protein/carbs/fat)
    var isBalanced: Bool {
        let proteinInRange = proteinPercentage >= 20 && proteinPercentage <= 40
        let carbsInRange = carbsPercentage >= 30 && carbsPercentage <= 50
        let fatInRange = fatPercentage >= 20 && fatPercentage <= 35
        return proteinInRange && carbsInRange && fatInRange
    }
}

// MARK: - Weekly Summary

struct WeeklySummary: Identifiable, Equatable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let dailySummaries: [DailySummary]

    // MARK: - Computed Properties

    /// Average daily calories
    var averageCalories: Int {
        guard !dailySummaries.isEmpty else { return 0 }
        let total = dailySummaries.reduce(0) { $0 + $1.totalCalories }
        return total / dailySummaries.count
    }

    /// Average daily protein
    var averageProtein: Double {
        guard !dailySummaries.isEmpty else { return 0 }
        let total = dailySummaries.reduce(0) { $0 + $1.totalProtein }
        return total / Double(dailySummaries.count)
    }

    /// Average daily water intake
    var averageWaterIntake: Double {
        guard !dailySummaries.isEmpty else { return 0 }
        let total = dailySummaries.reduce(0) { $0 + $1.totalWaterIntake }
        return total / Double(dailySummaries.count)
    }

    /// Days that met calorie goal
    var daysWithinCalorieGoal: Int {
        dailySummaries.filter { !$0.isOverCalorieGoal }.count
    }

    /// Days that met water goal
    var daysMetWaterGoal: Int {
        dailySummaries.filter { $0.waterProgress >= 1.0 }.count
    }

    /// Logging streak (consecutive days with at least one entry)
    var loggingStreak: Int {
        var streak = 0
        for summary in dailySummaries.sorted(by: { $0.date > $1.date }) {
            if !summary.foodEntries.isEmpty {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }

    /// Total calories for the week
    var totalCalories: Int {
        dailySummaries.reduce(0) { $0 + $1.totalCalories }
    }

    /// Best day (lowest calories while still eating)
    var bestDay: DailySummary? {
        dailySummaries
            .filter { !$0.foodEntries.isEmpty }
            .min { $0.totalCalories < $1.totalCalories }
    }

    /// Highest calorie day
    var highestCalorieDay: DailySummary? {
        dailySummaries.max { $0.totalCalories < $1.totalCalories }
    }
}

// MARK: - Mock Data

extension DailySummary {
    static var mock: DailySummary {
        DailySummary(
            foodEntries: FoodEntry.mockBreakfast,
            drinkEntries: DrinkEntry.mockDayEntries,
            calorieGoal: 1800,
            waterGoal: 2500,
            proteinGoal: 120,
            carbsGoal: 180,
            fatGoal: 60
        )
    }
}
