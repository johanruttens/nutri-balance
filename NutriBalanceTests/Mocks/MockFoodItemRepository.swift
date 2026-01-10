import Foundation
@testable import NutriBalance

/// Mock implementation of FoodItemRepositoryProtocol for testing.
final class MockFoodItemRepository: FoodItemRepositoryProtocol {
    // MARK: - Stored Data

    var storedItems: [FoodItem] = []

    // MARK: - Call Tracking

    var createItemCalled = false
    var getItemCalled = false
    var getAllItemsCalled = false
    var getFavoritesCalled = false
    var getRecentCalled = false
    var searchCalled = false
    var updateItemCalled = false
    var deleteItemCalled = false

    var lastCreatedItem: FoodItem?
    var lastSearchQuery: String?
    var lastItemId: UUID?

    // MARK: - Error Simulation

    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockError", code: -1)

    // MARK: - FoodItemRepositoryProtocol

    func createItem(_ item: FoodItem) async throws -> FoodItem {
        createItemCalled = true
        if shouldThrowError { throw errorToThrow }
        lastCreatedItem = item
        storedItems.append(item)
        return item
    }

    func getItem(id: UUID) async throws -> FoodItem? {
        getItemCalled = true
        if shouldThrowError { throw errorToThrow }
        lastItemId = id
        return storedItems.first { $0.id == id }
    }

    func getAllItems() async throws -> [FoodItem] {
        getAllItemsCalled = true
        if shouldThrowError { throw errorToThrow }
        return storedItems
    }

    func getFavorites() async throws -> [FoodItem] {
        getFavoritesCalled = true
        if shouldThrowError { throw errorToThrow }
        return storedItems.filter(\.isFavorite)
    }

    func getRecent(limit: Int) async throws -> [FoodItem] {
        getRecentCalled = true
        if shouldThrowError { throw errorToThrow }
        return Array(storedItems
            .filter { $0.lastUsedAt != nil }
            .sorted { ($0.lastUsedAt ?? .distantPast) > ($1.lastUsedAt ?? .distantPast) }
            .prefix(limit))
    }

    func search(query: String) async throws -> [FoodItem] {
        searchCalled = true
        if shouldThrowError { throw errorToThrow }
        lastSearchQuery = query
        let lowercaseQuery = query.lowercased()
        return storedItems.filter { item in
            item.name.lowercased().contains(lowercaseQuery) ||
            (item.brand?.lowercased().contains(lowercaseQuery) ?? false)
        }
    }

    func updateItem(_ item: FoodItem) async throws -> FoodItem {
        updateItemCalled = true
        if shouldThrowError { throw errorToThrow }
        if let index = storedItems.firstIndex(where: { $0.id == item.id }) {
            storedItems[index] = item
        }
        return item
    }

    func deleteItem(id: UUID) async throws {
        deleteItemCalled = true
        if shouldThrowError { throw errorToThrow }
        storedItems.removeAll { $0.id == id }
    }

    // MARK: - Test Helpers

    func reset() {
        storedItems = []
        createItemCalled = false
        getItemCalled = false
        getAllItemsCalled = false
        getFavoritesCalled = false
        getRecentCalled = false
        searchCalled = false
        updateItemCalled = false
        deleteItemCalled = false
        lastCreatedItem = nil
        lastSearchQuery = nil
        lastItemId = nil
        shouldThrowError = false
    }

    func addItem(_ item: FoodItem) {
        storedItems.append(item)
    }
}
