import XCTest
@testable import NutriBalance

final class UserTests: XCTestCase {

    // MARK: - Initialization Tests

    func testUserInitialization() {
        let user = TestDataFactory.makeUser(
            firstName: "John",
            lastName: "Doe",
            currentWeight: 85.0,
            targetWeight: 75.0,
            dailyCalorieGoal: 1800,
            dailyWaterGoal: 2500
        )

        XCTAssertEqual(user.firstName, "John")
        XCTAssertEqual(user.lastName, "Doe")
        XCTAssertEqual(user.currentWeight, 85.0)
        XCTAssertEqual(user.targetWeight, 75.0)
        XCTAssertEqual(user.dailyCalorieGoal, 1800)
        XCTAssertEqual(user.dailyWaterGoal, 2500)
    }

    func testUserDefaultValues() {
        let user = User(
            firstName: "Test",
            currentWeight: 70,
            targetWeight: 65,
            activityLevel: .moderatelyActive,
            preferredLanguage: "en",
            notificationsEnabled: true
        )

        XCTAssertEqual(user.dailyCalorieGoal, 2000)
        XCTAssertEqual(user.dailyWaterGoal, 2000)
        XCTAssertNil(user.lastName)
        XCTAssertNil(user.email)
        XCTAssertNil(user.height)
    }

    // MARK: - Display Name Tests

    func testDisplayNameWithFullName() {
        let user = TestDataFactory.makeUser(
            firstName: "John",
            lastName: "Doe"
        )
        XCTAssertEqual(user.displayName, "John Doe")
    }

    func testDisplayNameWithFirstNameOnly() {
        let user = TestDataFactory.makeUser(
            firstName: "Jane",
            lastName: nil
        )
        XCTAssertEqual(user.displayName, "Jane")
    }

    func testDisplayNameWithEmptyLastName() {
        let user = User(
            firstName: "Alice",
            lastName: "",
            currentWeight: 70,
            targetWeight: 65,
            activityLevel: .moderatelyActive,
            preferredLanguage: "en",
            notificationsEnabled: true
        )
        XCTAssertEqual(user.displayName, "Alice")
    }

    // MARK: - Weight Calculations Tests

    func testWeightToLosePositive() {
        let user = TestDataFactory.makeUser(
            currentWeight: 80.0,
            targetWeight: 70.0
        )
        XCTAssertEqual(user.weightToLose, 10.0)
    }

    func testWeightToLoseNegative() {
        let user = TestDataFactory.makeUser(
            currentWeight: 60.0,
            targetWeight: 65.0
        )
        XCTAssertEqual(user.weightToLose, -5.0)
    }

    func testWeightToLoseZero() {
        let user = TestDataFactory.makeUser(
            currentWeight: 70.0,
            targetWeight: 70.0
        )
        XCTAssertEqual(user.weightToLose, 0.0)
    }

    // MARK: - BMI Calculation Tests

    func testBMICalculation() {
        let user = User(
            firstName: "Test",
            currentWeight: 70,
            targetWeight: 65,
            height: 175,
            activityLevel: .moderatelyActive,
            preferredLanguage: "en",
            notificationsEnabled: true
        )

        let expectedBMI = 70 / ((175 / 100) * (175 / 100))
        XCTAssertEqual(user.bmi, expectedBMI, accuracy: 0.01)
    }

    func testBMIReturnsNilWithoutHeight() {
        let user = TestDataFactory.makeUser()
        XCTAssertNil(user.bmi)
    }

    func testBMIReturnsNilWithZeroHeight() {
        let user = User(
            firstName: "Test",
            currentWeight: 70,
            targetWeight: 65,
            height: 0,
            activityLevel: .moderatelyActive,
            preferredLanguage: "en",
            notificationsEnabled: true
        )
        XCTAssertNil(user.bmi)
    }

    // MARK: - Activity Level Tests

    func testActivityLevelMultiplier() {
        XCTAssertEqual(ActivityLevel.sedentary.multiplier, 1.2)
        XCTAssertEqual(ActivityLevel.lightlyActive.multiplier, 1.375)
        XCTAssertEqual(ActivityLevel.moderatelyActive.multiplier, 1.55)
        XCTAssertEqual(ActivityLevel.veryActive.multiplier, 1.725)
        XCTAssertEqual(ActivityLevel.extraActive.multiplier, 1.9)
    }

    func testActivityLevelDisplayName() {
        let levels = ActivityLevel.allCases

        for level in levels {
            XCTAssertFalse(level.displayName.isEmpty, "\(level) should have a display name")
        }
    }

    func testActivityLevelDescription() {
        let levels = ActivityLevel.allCases

        for level in levels {
            XCTAssertFalse(level.description.isEmpty, "\(level) should have a description")
        }
    }

    // MARK: - Equatable Tests

    func testUserEquality() {
        let id = UUID()
        let user1 = User(
            id: id,
            firstName: "Test",
            currentWeight: 70,
            targetWeight: 65,
            activityLevel: .moderatelyActive,
            preferredLanguage: "en",
            notificationsEnabled: true
        )
        let user2 = User(
            id: id,
            firstName: "Test",
            currentWeight: 70,
            targetWeight: 65,
            activityLevel: .moderatelyActive,
            preferredLanguage: "en",
            notificationsEnabled: true
        )

        XCTAssertEqual(user1, user2)
    }

    func testUserInequality() {
        let user1 = TestDataFactory.makeUser(firstName: "Alice")
        let user2 = TestDataFactory.makeUser(firstName: "Bob")

        XCTAssertNotEqual(user1, user2)
    }
}
