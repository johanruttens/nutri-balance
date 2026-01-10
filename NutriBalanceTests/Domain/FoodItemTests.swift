import XCTest
@testable import NutriBalance

final class FoodItemTests: XCTestCase {

    // MARK: - Initialization Tests

    func testFoodItemInitialization() {
        let item = TestDataFactory.makeFoodItem(
            name: "Chicken Breast",
            brand: "Generic",
            caloriesPer100: 165,
            proteinPer100: 31,
            carbsPer100: 0,
            fatPer100: 3.6
        )

        XCTAssertEqual(item.name, "Chicken Breast")
        XCTAssertEqual(item.brand, "Generic")
        XCTAssertEqual(item.caloriesPer100, 165)
        XCTAssertEqual(item.proteinPer100, 31)
        XCTAssertEqual(item.carbsPer100, 0)
        XCTAssertEqual(item.fatPer100, 3.6)
    }

    func testFoodItemDefaultValues() {
        let item = FoodItem(name: "Basic Food")

        XCTAssertEqual(item.defaultServingSize, 100)
        XCTAssertEqual(item.defaultServingUnit, .grams)
        XCTAssertFalse(item.isFavorite)
        XCTAssertEqual(item.useCount, 0)
        XCTAssertNil(item.lastUsedAt)
    }

    // MARK: - Display Name Tests

    func testDisplayNameWithBrand() {
        let item = TestDataFactory.makeFoodItem(
            name: "Yogurt",
            brand: "Fage"
        )
        XCTAssertEqual(item.displayName, "Yogurt (Fage)")
    }

    func testDisplayNameWithoutBrand() {
        let item = TestDataFactory.makeFoodItem(
            name: "Banana",
            brand: nil
        )
        XCTAssertEqual(item.displayName, "Banana")
    }

    func testDisplayNameWithEmptyBrand() {
        let item = FoodItem(
            name: "Apple",
            brand: ""
        )
        XCTAssertEqual(item.displayName, "Apple")
    }

    // MARK: - Calorie Calculation Tests

    func testCaloriesFor100Grams() {
        let item = TestDataFactory.makeFoodItem(caloriesPer100: 200)
        let calories = item.calories(for: 100, unit: .grams)
        XCTAssertEqual(calories, 200)
    }

    func testCaloriesFor50Grams() {
        let item = TestDataFactory.makeFoodItem(caloriesPer100: 200)
        let calories = item.calories(for: 50, unit: .grams)
        XCTAssertEqual(calories, 100)
    }

    func testCaloriesFor150Grams() {
        let item = TestDataFactory.makeFoodItem(caloriesPer100: 200)
        let calories = item.calories(for: 150, unit: .grams)
        XCTAssertEqual(calories, 300)
    }

    func testCaloriesReturnsNilWhenNoCalorieData() {
        let item = TestDataFactory.makeFoodItem(caloriesPer100: nil)
        let calories = item.calories(for: 100, unit: .grams)
        XCTAssertNil(calories)
    }

    // MARK: - Protein Calculation Tests

    func testProteinFor100Grams() {
        let item = TestDataFactory.makeFoodItem(proteinPer100: 25)
        let protein = item.protein(for: 100, unit: .grams)
        XCTAssertEqual(protein, 25)
    }

    func testProteinFor200Grams() {
        let item = TestDataFactory.makeFoodItem(proteinPer100: 20)
        let protein = item.protein(for: 200, unit: .grams)
        XCTAssertEqual(protein, 40)
    }

    func testProteinReturnsNilWhenNoData() {
        let item = TestDataFactory.makeFoodItem(proteinPer100: nil)
        let protein = item.protein(for: 100, unit: .grams)
        XCTAssertNil(protein)
    }

    // MARK: - Carbs Calculation Tests

    func testCarbsFor100Grams() {
        let item = TestDataFactory.makeFoodItem(carbsPer100: 50)
        let carbs = item.carbs(for: 100, unit: .grams)
        XCTAssertEqual(carbs, 50)
    }

    func testCarbsFor75Grams() {
        let item = TestDataFactory.makeFoodItem(carbsPer100: 40)
        let carbs = item.carbs(for: 75, unit: .grams)
        XCTAssertEqual(carbs, 30)
    }

    // MARK: - Fat Calculation Tests

    func testFatFor100Grams() {
        let item = TestDataFactory.makeFoodItem(fatPer100: 10)
        let fat = item.fat(for: 100, unit: .grams)
        XCTAssertEqual(fat, 10)
    }

    func testFatFor250Grams() {
        let item = TestDataFactory.makeFoodItem(fatPer100: 8)
        let fat = item.fat(for: 250, unit: .grams)
        XCTAssertEqual(fat, 20)
    }

    // MARK: - toFoodEntry Tests

    func testToFoodEntryWithDefaultPortion() {
        let item = TestDataFactory.makeFoodItem(
            name: "Oatmeal",
            caloriesPer100: 389,
            proteinPer100: 17,
            carbsPer100: 66,
            fatPer100: 7,
            defaultServingSize: 40,
            defaultServingUnit: .grams
        )

        let entry = item.toFoodEntry(mealCategory: .breakfast)

        XCTAssertEqual(entry.foodName, "Oatmeal")
        XCTAssertEqual(entry.mealCategory, .breakfast)
        XCTAssertEqual(entry.portionSize, 40)
        XCTAssertEqual(entry.portionUnit, .grams)
        XCTAssertEqual(entry.linkedFoodItemId, item.id)
    }

    func testToFoodEntryWithCustomPortion() {
        let item = TestDataFactory.makeFoodItem(
            name: "Rice",
            caloriesPer100: 130,
            defaultServingSize: 100,
            defaultServingUnit: .grams
        )

        let entry = item.toFoodEntry(
            mealCategory: .lunch,
            portionSize: 200,
            portionUnit: .grams
        )

        XCTAssertEqual(entry.portionSize, 200)
        XCTAssertEqual(entry.calories, 260) // 130 * 2
    }

    // MARK: - Category Tests

    func testFoodItemCategoryDisplayName() {
        let categories = FoodItemCategory.allCases

        for category in categories {
            XCTAssertFalse(category.displayName.isEmpty, "\(category) should have a display name")
        }
    }

    func testFoodItemCategoryIconName() {
        let categories = FoodItemCategory.allCases

        for category in categories {
            XCTAssertFalse(category.iconName.isEmpty, "\(category) should have an icon name")
        }
    }

    // MARK: - Equatable Tests

    func testFoodItemEquality() {
        let id = UUID()
        let item1 = FoodItem(id: id, name: "Test")
        let item2 = FoodItem(id: id, name: "Test")

        XCTAssertEqual(item1, item2)
    }

    func testFoodItemInequality() {
        let item1 = TestDataFactory.makeFoodItem(name: "Item A")
        let item2 = TestDataFactory.makeFoodItem(name: "Item B")

        XCTAssertNotEqual(item1, item2)
    }
}
