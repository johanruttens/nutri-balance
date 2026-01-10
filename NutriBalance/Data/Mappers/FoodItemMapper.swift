import Foundation
import CoreData

/// Maps between CDFoodItem (Core Data) and FoodItem (Domain) models.
enum FoodItemMapper {

    /// Converts a Core Data food item to a domain food item
    static func toDomain(_ cdItem: CDFoodItem) -> FoodItem {
        FoodItem(
            id: cdItem.id,
            name: cdItem.name,
            brand: cdItem.brand,
            caloriesPer100: cdItem.caloriesPer100?.doubleValue,
            proteinPer100: cdItem.proteinPer100?.doubleValue,
            carbsPer100: cdItem.carbsPer100?.doubleValue,
            fatPer100: cdItem.fatPer100?.doubleValue,
            fiberPer100: cdItem.fiberPer100?.doubleValue,
            sugarPer100: cdItem.sugarPer100?.doubleValue,
            defaultServingSize: cdItem.defaultServingSize,
            defaultServingUnit: PortionUnit(rawValue: cdItem.defaultServingUnit) ?? .grams,
            category: cdItem.category.flatMap { FoodItemCategory(rawValue: $0) },
            tags: cdItem.tags ?? [],
            isFavorite: cdItem.isFavorite,
            useCount: Int(cdItem.useCount),
            lastUsedAt: cdItem.lastUsedAt,
            createdAt: cdItem.createdAt,
            updatedAt: cdItem.updatedAt
        )
    }

    /// Updates a Core Data food item from a domain food item
    static func toEntity(_ item: FoodItem, entity: CDFoodItem) {
        entity.id = item.id
        entity.name = item.name
        entity.brand = item.brand
        entity.caloriesPer100 = item.caloriesPer100.map { NSNumber(value: $0) }
        entity.proteinPer100 = item.proteinPer100.map { NSNumber(value: $0) }
        entity.carbsPer100 = item.carbsPer100.map { NSNumber(value: $0) }
        entity.fatPer100 = item.fatPer100.map { NSNumber(value: $0) }
        entity.fiberPer100 = item.fiberPer100.map { NSNumber(value: $0) }
        entity.sugarPer100 = item.sugarPer100.map { NSNumber(value: $0) }
        entity.defaultServingSize = item.defaultServingSize
        entity.defaultServingUnit = item.defaultServingUnit.rawValue
        entity.category = item.category?.rawValue
        entity.tags = item.tags
        entity.isFavorite = item.isFavorite
        entity.useCount = Int32(item.useCount)
        entity.lastUsedAt = item.lastUsedAt
        entity.updatedAt = Date()
    }

    /// Creates a new Core Data food item from a domain food item
    static func createEntity(_ item: FoodItem, in context: NSManagedObjectContext) -> CDFoodItem {
        let entity = CDFoodItem(context: context)
        entity.createdAt = item.createdAt
        toEntity(item, entity: entity)
        return entity
    }
}
