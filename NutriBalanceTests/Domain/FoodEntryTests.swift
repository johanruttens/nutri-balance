import XCTest
@testable import NutriBalance

final class FoodEntryTests: XCTestCase {

    // MARK: - Initialization Tests

    func testFoodEntryInitialization() {
        let entry = TestDataFactory.makeFoodEntry(
            foodName: "Oatmeal",
            portionSize: 150,
            portionUnit: .grams,
            calories: 250,
            protein: 8,
            carbs: 45,
            fat: 5
        )

        XCTAssertEqual(entry.foodName, "Oatmeal")
        XCTAssertEqual(entry.portionSize, 150)
        XCTAssertEqual(entry.portionUnit, .grams)
        XCTAssertEqual(entry.calories, 250)
        XCTAssertEqual(entry.protein, 8)
        XCTAssertEqual(entry.carbs, 45)
        XCTAssertEqual(entry.fat, 5)
    }

    func testFoodEntryWithNilNutrition() {
        let entry = FoodEntry(
            mealCategory: .breakfast,
            foodName: "Unknown Food",
            portionSize: 100,
            portionUnit: .grams
        )

        XCTAssertNil(entry.calories)
        XCTAssertNil(entry.protein)
        XCTAssertNil(entry.carbs)
        XCTAssertNil(entry.fat)
    }

    // MARK: - Computed Properties Tests

    func testPortionStringWithWholeNumber() {
        let entry = TestDataFactory.makeFoodEntry(portionSize: 100, portionUnit: .grams)
        XCTAssertEqual(entry.portionString, "100 g")
    }

    func testPortionStringWithDecimal() {
        let entry = TestDataFactory.makeFoodEntry(portionSize: 1.5, portionUnit: .cups)
        XCTAssertEqual(entry.portionString, "1.5 cup")
    }

    func testPortionStringWithPieces() {
        let entry = TestDataFactory.makeFoodEntry(portionSize: 2, portionUnit: .pieces)
        XCTAssertEqual(entry.portionString, "2 pcs")
    }

    func testHasNutritionInfoWithCalories() {
        let entry = TestDataFactory.makeFoodEntry(calories: 200)
        XCTAssertTrue(entry.hasNutritionInfo)
    }

    func testHasNutritionInfoWithProteinOnly() {
        let entry = FoodEntry(
            mealCategory: .lunch,
            foodName: "Test",
            portionSize: 100,
            portionUnit: .grams,
            protein: 10
        )
        XCTAssertTrue(entry.hasNutritionInfo)
    }

    func testHasNutritionInfoWithNoData() {
        let entry = FoodEntry(
            mealCategory: .lunch,
            foodName: "Test",
            portionSize: 100,
            portionUnit: .grams
        )
        XCTAssertFalse(entry.hasNutritionInfo)
    }

    func testTotalMacros() {
        let entry = TestDataFactory.makeFoodEntry(
            protein: 20,
            carbs: 30,
            fat: 10
        )
        XCTAssertEqual(entry.totalMacros, 60)
    }

    func testTotalMacrosWithNilValues() {
        let entry = FoodEntry(
            mealCategory: .lunch,
            foodName: "Test",
            portionSize: 100,
            portionUnit: .grams,
            protein: 15
        )
        XCTAssertEqual(entry.totalMacros, 15)
    }

    // MARK: - Equatable Tests

    func testFoodEntryEquality() {
        let id = UUID()
        let entry1 = FoodEntry(
            id: id,
            mealCategory: .breakfast,
            foodName: "Test",
            portionSize: 100,
            portionUnit: .grams
        )
        let entry2 = FoodEntry(
            id: id,
            mealCategory: .breakfast,
            foodName: "Test",
            portionSize: 100,
            portionUnit: .grams
        )

        XCTAssertEqual(entry1, entry2)
    }

    func testFoodEntryInequality() {
        let entry1 = TestDataFactory.makeFoodEntry(foodName: "Food A")
        let entry2 = TestDataFactory.makeFoodEntry(foodName: "Food B")

        XCTAssertNotEqual(entry1, entry2)
    }

    // MARK: - Meal Category Tests

    func testAllMealCategories() {
        let categories = MealCategory.allCases

        XCTAssertEqual(categories.count, 7)
        XCTAssertTrue(categories.contains(.breakfast))
        XCTAssertTrue(categories.contains(.morningSnack))
        XCTAssertTrue(categories.contains(.lunch))
        XCTAssertTrue(categories.contains(.afternoonSnack))
        XCTAssertTrue(categories.contains(.dinner))
        XCTAssertTrue(categories.contains(.eveningSnack))
        XCTAssertTrue(categories.contains(.other))
    }

    func testMealCategoryDisplayName() {
        XCTAssertFalse(MealCategory.breakfast.displayName.isEmpty)
        XCTAssertFalse(MealCategory.lunch.displayName.isEmpty)
        XCTAssertFalse(MealCategory.dinner.displayName.isEmpty)
    }

    func testMealCategoryIcon() {
        XCTAssertFalse(MealCategory.breakfast.icon.isEmpty)
        XCTAssertFalse(MealCategory.lunch.icon.isEmpty)
        XCTAssertFalse(MealCategory.dinner.icon.isEmpty)
    }
}
