import Foundation

/// Protocol defining food item (favorites/templates) data operations.
protocol FoodItemRepositoryProtocol {
    /// Fetches all food items
    func getAllItems() async throws -> [FoodItem]

    /// Fetches all favorite food items
    func getFavorites() async throws -> [FoodItem]

    /// Fetches recently used food items
    func getRecentItems(limit: Int) async throws -> [FoodItem]

    /// Fetches frequently used food items
    func getFrequentItems(limit: Int) async throws -> [FoodItem]

    /// Searches food items by name
    func searchItems(query: String) async throws -> [FoodItem]

    /// Gets a food item by ID
    func getItem(id: UUID) async throws -> FoodItem?

    /// Adds a new food item
    func addItem(_ item: FoodItem) async throws -> FoodItem

    /// Updates an existing food item
    func updateItem(_ item: FoodItem) async throws -> FoodItem

    /// Deletes a food item
    func deleteItem(_ item: FoodItem) async throws

    /// Toggles favorite status for a food item
    func toggleFavorite(_ item: FoodItem) async throws -> FoodItem

    /// Increments the use count for a food item
    func incrementUseCount(_ item: FoodItem) async throws
}
