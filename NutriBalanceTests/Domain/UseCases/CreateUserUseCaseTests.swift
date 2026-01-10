import XCTest
@testable import NutriBalance

final class CreateUserUseCaseTests: XCTestCase {
    var mockRepository: MockUserRepository!
    var sut: CreateUserUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        sut = CreateUserUseCase(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Create User Tests

    func testExecuteCreatesUser() async throws {
        let user = TestDataFactory.makeUser(firstName: "John")

        let result = try await sut.execute(user: user)

        XCTAssertTrue(mockRepository.createUserCalled)
        XCTAssertEqual(result.firstName, "John")
        XCTAssertEqual(mockRepository.lastCreatedUser?.firstName, "John")
    }

    func testExecuteStoresUserInRepository() async throws {
        let user = TestDataFactory.makeUser()

        _ = try await sut.execute(user: user)

        XCTAssertNotNil(mockRepository.storedUser)
        XCTAssertEqual(mockRepository.storedUser?.id, user.id)
    }

    func testExecuteThrowsErrorWhenRepositoryFails() async {
        mockRepository.shouldThrowError = true
        let user = TestDataFactory.makeUser()

        do {
            _ = try await sut.execute(user: user)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(mockRepository.createUserCalled)
        }
    }
}
