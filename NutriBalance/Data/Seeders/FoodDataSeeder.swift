import Foundation
import CoreData

/// Seeds the database with common food items.
final class FoodDataSeeder {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Seeds the database with initial food data if not already seeded.
    func seedIfNeeded() async {
        let hasSeeded = UserDefaults.standard.bool(forKey: "foodDataSeeded")
        guard !hasSeeded else { return }

        await seed()
        UserDefaults.standard.set(true, forKey: "foodDataSeeded")
    }

    /// Seeds the database with common food items.
    func seed() async {
        await context.perform {
            // Clear existing items first (for clean reseed)
            let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDFoodItem")
            let batchDelete = NSBatchDeleteRequest(fetchRequest: deleteRequest)
            try? self.context.execute(batchDelete)

            // Seed common foods
            self.seedFruits()
            self.seedVegetables()
            self.seedProteins()
            self.seedDairy()
            self.seedGrains()
            self.seedBeverages()
            self.seedSnacks()

            try? self.context.save()
        }
    }

    // MARK: - Food Categories

    private func seedFruits() {
        createFood(name: "Apple", category: "Fruit", calories: 52, protein: 0.3, carbs: 14, fat: 0.2, fiber: 2.4, sugar: 10, serving: 150, unit: "g")
        createFood(name: "Banana", category: "Fruit", calories: 89, protein: 1.1, carbs: 23, fat: 0.3, fiber: 2.6, sugar: 12, serving: 120, unit: "g")
        createFood(name: "Orange", category: "Fruit", calories: 47, protein: 0.9, carbs: 12, fat: 0.1, fiber: 2.4, sugar: 9, serving: 150, unit: "g")
        createFood(name: "Strawberries", category: "Fruit", calories: 32, protein: 0.7, carbs: 8, fat: 0.3, fiber: 2, sugar: 5, serving: 100, unit: "g")
        createFood(name: "Blueberries", category: "Fruit", calories: 57, protein: 0.7, carbs: 14, fat: 0.3, fiber: 2.4, sugar: 10, serving: 100, unit: "g")
        createFood(name: "Grapes", category: "Fruit", calories: 69, protein: 0.7, carbs: 18, fat: 0.2, fiber: 0.9, sugar: 16, serving: 100, unit: "g")
        createFood(name: "Mango", category: "Fruit", calories: 60, protein: 0.8, carbs: 15, fat: 0.4, fiber: 1.6, sugar: 14, serving: 100, unit: "g")
        createFood(name: "Pear", category: "Fruit", calories: 57, protein: 0.4, carbs: 15, fat: 0.1, fiber: 3.1, sugar: 10, serving: 150, unit: "g")
        createFood(name: "Watermelon", category: "Fruit", calories: 30, protein: 0.6, carbs: 8, fat: 0.2, fiber: 0.4, sugar: 6, serving: 200, unit: "g")
        createFood(name: "Kiwi", category: "Fruit", calories: 61, protein: 1.1, carbs: 15, fat: 0.5, fiber: 3, sugar: 9, serving: 75, unit: "g")
    }

    private func seedVegetables() {
        createFood(name: "Broccoli", category: "Vegetable", calories: 34, protein: 2.8, carbs: 7, fat: 0.4, fiber: 2.6, sugar: 2, serving: 100, unit: "g")
        createFood(name: "Carrot", category: "Vegetable", calories: 41, protein: 0.9, carbs: 10, fat: 0.2, fiber: 2.8, sugar: 5, serving: 80, unit: "g")
        createFood(name: "Spinach", category: "Vegetable", calories: 23, protein: 2.9, carbs: 3.6, fat: 0.4, fiber: 2.2, sugar: 0.4, serving: 100, unit: "g")
        createFood(name: "Tomato", category: "Vegetable", calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, fiber: 1.2, sugar: 2.6, serving: 150, unit: "g")
        createFood(name: "Cucumber", category: "Vegetable", calories: 15, protein: 0.7, carbs: 3.6, fat: 0.1, fiber: 0.5, sugar: 1.7, serving: 100, unit: "g")
        createFood(name: "Bell Pepper", category: "Vegetable", calories: 31, protein: 1, carbs: 6, fat: 0.3, fiber: 2.1, sugar: 4.2, serving: 120, unit: "g")
        createFood(name: "Zucchini", category: "Vegetable", calories: 17, protein: 1.2, carbs: 3.1, fat: 0.3, fiber: 1, sugar: 2.5, serving: 150, unit: "g")
        createFood(name: "Cauliflower", category: "Vegetable", calories: 25, protein: 1.9, carbs: 5, fat: 0.3, fiber: 2, sugar: 2, serving: 100, unit: "g")
        createFood(name: "Green Beans", category: "Vegetable", calories: 31, protein: 1.8, carbs: 7, fat: 0.1, fiber: 2.7, sugar: 3.3, serving: 100, unit: "g")
        createFood(name: "Lettuce", category: "Vegetable", calories: 15, protein: 1.4, carbs: 2.9, fat: 0.2, fiber: 1.3, sugar: 0.8, serving: 100, unit: "g")
    }

    private func seedProteins() {
        createFood(name: "Chicken Breast", category: "Protein", calories: 165, protein: 31, carbs: 0, fat: 3.6, fiber: 0, sugar: 0, serving: 150, unit: "g")
        createFood(name: "Salmon", category: "Protein", calories: 208, protein: 20, carbs: 0, fat: 13, fiber: 0, sugar: 0, serving: 150, unit: "g")
        createFood(name: "Beef Steak", category: "Protein", calories: 271, protein: 26, carbs: 0, fat: 18, fiber: 0, sugar: 0, serving: 150, unit: "g")
        createFood(name: "Egg", category: "Protein", calories: 155, protein: 13, carbs: 1.1, fat: 11, fiber: 0, sugar: 1.1, serving: 50, unit: "g")
        createFood(name: "Tuna", category: "Protein", calories: 132, protein: 28, carbs: 0, fat: 1, fiber: 0, sugar: 0, serving: 100, unit: "g")
        createFood(name: "Turkey Breast", category: "Protein", calories: 135, protein: 30, carbs: 0, fat: 1, fiber: 0, sugar: 0, serving: 150, unit: "g")
        createFood(name: "Pork Chop", category: "Protein", calories: 231, protein: 25, carbs: 0, fat: 14, fiber: 0, sugar: 0, serving: 150, unit: "g")
        createFood(name: "Shrimp", category: "Protein", calories: 99, protein: 24, carbs: 0.2, fat: 0.3, fiber: 0, sugar: 0, serving: 100, unit: "g")
        createFood(name: "Tofu", category: "Protein", calories: 76, protein: 8, carbs: 1.9, fat: 4.8, fiber: 0.3, sugar: 0.6, serving: 100, unit: "g")
        createFood(name: "Lentils", category: "Protein", calories: 116, protein: 9, carbs: 20, fat: 0.4, fiber: 8, sugar: 1.8, serving: 100, unit: "g")
    }

    private func seedDairy() {
        createFood(name: "Milk (Whole)", category: "Dairy", calories: 61, protein: 3.2, carbs: 4.8, fat: 3.3, fiber: 0, sugar: 5, serving: 250, unit: "ml")
        createFood(name: "Milk (Skimmed)", category: "Dairy", calories: 34, protein: 3.4, carbs: 5, fat: 0.1, fiber: 0, sugar: 5, serving: 250, unit: "ml")
        createFood(name: "Greek Yogurt", category: "Dairy", calories: 97, protein: 9, carbs: 3.6, fat: 5, fiber: 0, sugar: 4, serving: 150, unit: "g")
        createFood(name: "Cottage Cheese", category: "Dairy", calories: 98, protein: 11, carbs: 3.4, fat: 4.3, fiber: 0, sugar: 2.7, serving: 100, unit: "g")
        createFood(name: "Cheddar Cheese", category: "Dairy", calories: 403, protein: 25, carbs: 1.3, fat: 33, fiber: 0, sugar: 0.5, serving: 30, unit: "g")
        createFood(name: "Mozzarella", category: "Dairy", calories: 280, protein: 28, carbs: 3.1, fat: 17, fiber: 0, sugar: 1, serving: 30, unit: "g")
        createFood(name: "Butter", category: "Dairy", calories: 717, protein: 0.9, carbs: 0.1, fat: 81, fiber: 0, sugar: 0.1, serving: 10, unit: "g")
        createFood(name: "Cream Cheese", category: "Dairy", calories: 342, protein: 6, carbs: 4.1, fat: 34, fiber: 0, sugar: 3.8, serving: 30, unit: "g")
    }

    private func seedGrains() {
        createFood(name: "White Rice", category: "Grain", calories: 130, protein: 2.7, carbs: 28, fat: 0.3, fiber: 0.4, sugar: 0, serving: 150, unit: "g")
        createFood(name: "Brown Rice", category: "Grain", calories: 111, protein: 2.6, carbs: 23, fat: 0.9, fiber: 1.8, sugar: 0.4, serving: 150, unit: "g")
        createFood(name: "Pasta", category: "Grain", calories: 131, protein: 5, carbs: 25, fat: 1.1, fiber: 1.8, sugar: 0.6, serving: 100, unit: "g")
        createFood(name: "Whole Wheat Bread", category: "Grain", calories: 247, protein: 13, carbs: 41, fat: 3.4, fiber: 7, sugar: 6, serving: 30, unit: "g")
        createFood(name: "Oatmeal", category: "Grain", calories: 68, protein: 2.4, carbs: 12, fat: 1.4, fiber: 1.7, sugar: 0.5, serving: 100, unit: "g")
        createFood(name: "Quinoa", category: "Grain", calories: 120, protein: 4.4, carbs: 21, fat: 1.9, fiber: 2.8, sugar: 0.9, serving: 100, unit: "g")
        createFood(name: "Cornflakes", category: "Grain", calories: 357, protein: 8, carbs: 84, fat: 0.4, fiber: 3.3, sugar: 8, serving: 30, unit: "g")
        createFood(name: "Granola", category: "Grain", calories: 471, protein: 10, carbs: 64, fat: 20, fiber: 7, sugar: 25, serving: 50, unit: "g")
    }

    private func seedBeverages() {
        createFood(name: "Orange Juice", category: "Beverage", calories: 45, protein: 0.7, carbs: 10, fat: 0.2, fiber: 0.2, sugar: 8, serving: 250, unit: "ml")
        createFood(name: "Apple Juice", category: "Beverage", calories: 46, protein: 0.1, carbs: 11, fat: 0.1, fiber: 0.2, sugar: 10, serving: 250, unit: "ml")
        createFood(name: "Coffee (Black)", category: "Beverage", calories: 2, protein: 0.3, carbs: 0, fat: 0, fiber: 0, sugar: 0, serving: 250, unit: "ml")
        createFood(name: "Green Tea", category: "Beverage", calories: 1, protein: 0, carbs: 0.2, fat: 0, fiber: 0, sugar: 0, serving: 250, unit: "ml")
        createFood(name: "Smoothie (Fruit)", category: "Beverage", calories: 80, protein: 1.5, carbs: 18, fat: 0.5, fiber: 2, sugar: 14, serving: 250, unit: "ml")
        createFood(name: "Protein Shake", category: "Beverage", calories: 120, protein: 24, carbs: 3, fat: 1.5, fiber: 1, sugar: 2, serving: 300, unit: "ml")
    }

    private func seedSnacks() {
        createFood(name: "Almonds", category: "Snack", calories: 579, protein: 21, carbs: 22, fat: 50, fiber: 12, sugar: 4, serving: 30, unit: "g")
        createFood(name: "Walnuts", category: "Snack", calories: 654, protein: 15, carbs: 14, fat: 65, fiber: 7, sugar: 3, serving: 30, unit: "g")
        createFood(name: "Dark Chocolate", category: "Snack", calories: 546, protein: 5, carbs: 60, fat: 31, fiber: 7, sugar: 48, serving: 30, unit: "g")
        createFood(name: "Protein Bar", category: "Snack", calories: 350, protein: 20, carbs: 35, fat: 12, fiber: 5, sugar: 15, serving: 60, unit: "g")
        createFood(name: "Rice Cake", category: "Snack", calories: 35, protein: 0.7, carbs: 7, fat: 0.3, fiber: 0.4, sugar: 0, serving: 9, unit: "g")
        createFood(name: "Hummus", category: "Snack", calories: 166, protein: 8, carbs: 14, fat: 10, fiber: 6, sugar: 0.3, serving: 50, unit: "g")
        createFood(name: "Popcorn (Plain)", category: "Snack", calories: 387, protein: 13, carbs: 78, fat: 4.5, fiber: 15, sugar: 0.9, serving: 30, unit: "g")
        createFood(name: "Banana Chips", category: "Snack", calories: 519, protein: 2, carbs: 58, fat: 34, fiber: 8, sugar: 35, serving: 30, unit: "g")
    }

    // MARK: - Helper

    private func createFood(
        name: String,
        category: String,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        fiber: Double,
        sugar: Double,
        serving: Double,
        unit: String
    ) {
        let food = CDFoodItem(context: context)
        food.id = UUID()
        food.name = name
        food.category = category
        food.caloriesPer100 = NSNumber(value: calories)
        food.proteinPer100 = NSNumber(value: protein)
        food.carbsPer100 = NSNumber(value: carbs)
        food.fatPer100 = NSNumber(value: fat)
        food.fiberPer100 = NSNumber(value: fiber)
        food.sugarPer100 = NSNumber(value: sugar)
        food.defaultServingSize = serving
        food.defaultServingUnit = unit
        food.isFavorite = false
        food.useCount = 0
        food.createdAt = Date()
        food.updatedAt = Date()
    }
}
