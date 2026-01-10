import Foundation

/// Use case for adding a food item to favorites.
struct AddToFavoritesUseCase {
    private let repository: FoodItemRepositoryProtocol

    init(repository: FoodItemRepositoryProtocol) {
        self.repository = repository
    }

    func execute(item: FoodItem) async throws -> FoodItem {
        var updatedItem = item
        updatedItem.isFavorite = true
        return try await repository.updateItem(updatedItem)
    }
}

/// Use case for getting favorite food items.
struct GetFavoritesUseCase {
    private let repository: FoodItemRepositoryProtocol

    init(repository: FoodItemRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [FoodItem] {
        try await repository.getFavorites()
    }
}

/// Use case for getting recently used food items.
struct GetRecentFoodsUseCase {
    private let repository: FoodItemRepositoryProtocol

    init(repository: FoodItemRepositoryProtocol) {
        self.repository = repository
    }

    func execute(limit: Int = 10) async throws -> [FoodItem] {
        try await repository.getRecentItems(limit: limit)
    }
}
