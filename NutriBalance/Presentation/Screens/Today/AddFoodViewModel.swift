import Foundation
import SwiftUI
import Combine

/// View model for adding food entries.
@MainActor
final class AddFoodViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var searchQuery = ""
    @Published var selectedCategory: MealCategory
    @Published var recentFoods: [FoodItem] = []
    @Published var favorites: [FoodItem] = []
    @Published var searchResults: [FoodItem] = []
    @Published var isSearching = false
    @Published var selectedFood: FoodItem?
    @Published var showCustomFood = false
    @Published var error: Error?

    // MARK: - Properties

    let container: DependencyContainer
    let date: Date

    // MARK: - Private Properties

    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(container: DependencyContainer, mealCategory: MealCategory, date: Date) {
        self.container = container
        self.selectedCategory = mealCategory
        self.date = date

        // Set up debounced search
        setupSearchDebounce()
    }

    private func setupSearchDebounce() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                Task { @MainActor in
                    await self.performSearch(query: query)
                }
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            isSearching = false
            return
        }

        // Cancel any existing search task
        searchTask?.cancel()

        searchTask = Task {
            isSearching = true

            do {
                try await Task.sleep(nanoseconds: 50_000_000) // Small delay for cancellation check
                guard !Task.isCancelled else { return }

                let repository = container.foodItemRepository
                let results = try await repository.searchItems(query: query)

                guard !Task.isCancelled else { return }
                searchResults = results
            } catch {
                if !Task.isCancelled {
                    self.error = error
                    searchResults = []
                }
            }

            isSearching = false
        }

        await searchTask?.value
    }

    // MARK: - Public Methods

    func loadInitialData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadRecentFoods() }
            group.addTask { await self.loadFavorites() }
        }
    }

    /// Manual search trigger (for submit button)
    func search() async {
        await performSearch(query: searchQuery)
    }

    func selectFood(_ food: FoodItem) {
        selectedFood = food
    }

    // MARK: - Private Methods

    private func loadRecentFoods() async {
        do {
            let useCase = container.makeGetRecentFoodsUseCase()
            recentFoods = try await useCase.execute(limit: 5)
        } catch {
            recentFoods = []
        }
    }

    private func loadFavorites() async {
        do {
            let useCase = container.makeGetFavoritesUseCase()
            favorites = try await useCase.execute()
        } catch {
            favorites = []
        }
    }
}
