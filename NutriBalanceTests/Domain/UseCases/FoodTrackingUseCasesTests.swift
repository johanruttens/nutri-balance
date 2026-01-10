import XCTest
@testable import NutriBalance

final class AddFoodEntryUseCaseTests: XCTestCase {
    var mockRepository: MockFoodEntryRepository!
    var sut: AddFoodEntryUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockFoodEntryRepository()
        sut = AddFoodEntryUseCase(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        sut = nil
        super.tearDown()
    }

    func testExecuteCreatesEntry() async throws {
        let entry = TestDataFactory.makeFoodEntry(foodName: "Oatmeal")

        let result = try await sut.execute(entry: entry)

        XCTAssertTrue(mockRepository.createEntryCalled)
        XCTAssertEqual(result.foodName, "Oatmeal")
    }

    func testExecuteStoresEntryInRepository() async throws {
        let entry = TestDataFactory.makeFoodEntry()

        _ = try await sut.execute(entry: entry)

        XCTAssertEqual(mockRepository.storedEntries.count, 1)
        XCTAssertEqual(mockRepository.storedEntries.first?.id, entry.id)
    }

    func testExecuteThrowsErrorWhenRepositoryFails() async {
        mockRepository.shouldThrowError = true
        let entry = TestDataFactory.makeFoodEntry()

        do {
            _ = try await sut.execute(entry: entry)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(mockRepository.createEntryCalled)
        }
    }
}

final class GetDailyEntriesUseCaseTests: XCTestCase {
    var mockRepository: MockFoodEntryRepository!
    var sut: GetDailyEntriesUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockFoodEntryRepository()
        sut = GetDailyEntriesUseCase(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        sut = nil
        super.tearDown()
    }

    func testExecuteReturnsEntriesForDate() async throws {
        let today = Date()
        let entry1 = TestDataFactory.makeFoodEntry(date: today, foodName: "Breakfast")
        let entry2 = TestDataFactory.makeFoodEntry(date: today, foodName: "Lunch")
        mockRepository.addEntry(entry1)
        mockRepository.addEntry(entry2)

        let results = try await sut.execute(for: today)

        XCTAssertTrue(mockRepository.getEntriesForDateCalled)
        XCTAssertEqual(results.count, 2)
    }

    func testExecuteFiltersEntriesByDate() async throws {
        let today = Date()
        let yesterday = TestDataFactory.date(daysAgo: 1)

        let todayEntry = TestDataFactory.makeFoodEntry(date: today, foodName: "Today's Food")
        let yesterdayEntry = TestDataFactory.makeFoodEntry(date: yesterday, foodName: "Yesterday's Food")
        mockRepository.addEntry(todayEntry)
        mockRepository.addEntry(yesterdayEntry)

        let results = try await sut.execute(for: today)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.foodName, "Today's Food")
    }

    func testExecuteReturnsEmptyArrayWhenNoEntries() async throws {
        let results = try await sut.execute(for: Date())

        XCTAssertTrue(results.isEmpty)
    }
}

final class DeleteFoodEntryUseCaseTests: XCTestCase {
    var mockRepository: MockFoodEntryRepository!
    var sut: DeleteFoodEntryUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockFoodEntryRepository()
        sut = DeleteFoodEntryUseCase(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        sut = nil
        super.tearDown()
    }

    func testExecuteDeletesEntry() async throws {
        let entry = TestDataFactory.makeFoodEntry()
        mockRepository.addEntry(entry)

        try await sut.execute(entryId: entry.id)

        XCTAssertTrue(mockRepository.deleteEntryCalled)
        XCTAssertEqual(mockRepository.lastDeletedEntryId, entry.id)
        XCTAssertTrue(mockRepository.storedEntries.isEmpty)
    }

    func testExecuteThrowsErrorWhenRepositoryFails() async {
        mockRepository.shouldThrowError = true

        do {
            try await sut.execute(entryId: UUID())
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(mockRepository.deleteEntryCalled)
        }
    }
}
