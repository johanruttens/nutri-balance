import Foundation
import CoreData

/// Programmatic Core Data model definition.
/// This creates the managed object model without requiring an .xcdatamodeld file.
enum CoreDataModel {

    /// Creates and returns the managed object model for NutriBalance
    static func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Create entities
        let userEntity = createUserEntity()
        let foodItemEntity = createFoodItemEntity()
        let foodEntryEntity = createFoodEntryEntity()
        let drinkEntryEntity = createDrinkEntryEntity()
        let weightEntryEntity = createWeightEntryEntity()
        let achievementEntity = createAchievementEntity()
        let mealTemplateEntity = createMealTemplateEntity()

        // Set up relationships
        setupRelationships(
            user: userEntity,
            foodItem: foodItemEntity,
            foodEntry: foodEntryEntity,
            drinkEntry: drinkEntryEntity,
            weightEntry: weightEntryEntity,
            achievement: achievementEntity,
            mealTemplate: mealTemplateEntity
        )

        model.entities = [
            userEntity,
            foodItemEntity,
            foodEntryEntity,
            drinkEntryEntity,
            weightEntryEntity,
            achievementEntity,
            mealTemplateEntity
        ]

        return model
    }

    // MARK: - Entity Definitions

    private static func createUserEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "CDUser"
        entity.managedObjectClassName = "CDUser"

        entity.properties = [
            attribute("id", type: .UUIDAttributeType, optional: false),
            attribute("firstName", type: .stringAttributeType, optional: false),
            attribute("lastName", type: .stringAttributeType, optional: true),
            attribute("email", type: .stringAttributeType, optional: true),
            attribute("profileImageData", type: .binaryDataAttributeType, optional: true),
            attribute("currentWeight", type: .doubleAttributeType, optional: false, defaultValue: 0),
            attribute("targetWeight", type: .doubleAttributeType, optional: false, defaultValue: 0),
            attribute("height", type: .doubleAttributeType, optional: true),
            attribute("birthDate", type: .dateAttributeType, optional: true),
            attribute("targetDate", type: .dateAttributeType, optional: true),
            attribute("dailyCalorieGoal", type: .integer32AttributeType, optional: false, defaultValue: 2000),
            attribute("dailyWaterGoal", type: .doubleAttributeType, optional: false, defaultValue: 2000),
            attribute("targetProtein", type: .doubleAttributeType, optional: true),
            attribute("targetCarbs", type: .doubleAttributeType, optional: true),
            attribute("targetFat", type: .doubleAttributeType, optional: true),
            attribute("activityLevel", type: .integer16AttributeType, optional: false, defaultValue: 2),
            attribute("preferredLanguage", type: .stringAttributeType, optional: false, defaultValue: "en"),
            attribute("notificationsEnabled", type: .booleanAttributeType, optional: false, defaultValue: true),
            attribute("onboardingCompleted", type: .booleanAttributeType, optional: false, defaultValue: false),
            attribute("createdAt", type: .dateAttributeType, optional: false),
            attribute("updatedAt", type: .dateAttributeType, optional: false)
        ]

        return entity
    }

    private static func createFoodItemEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "CDFoodItem"
        entity.managedObjectClassName = "CDFoodItem"

        entity.properties = [
            attribute("id", type: .UUIDAttributeType, optional: false),
            attribute("name", type: .stringAttributeType, optional: false),
            attribute("brand", type: .stringAttributeType, optional: true),
            attribute("caloriesPer100", type: .doubleAttributeType, optional: true),
            attribute("proteinPer100", type: .doubleAttributeType, optional: true),
            attribute("carbsPer100", type: .doubleAttributeType, optional: true),
            attribute("fatPer100", type: .doubleAttributeType, optional: true),
            attribute("fiberPer100", type: .doubleAttributeType, optional: true),
            attribute("sugarPer100", type: .doubleAttributeType, optional: true),
            attribute("defaultServingSize", type: .doubleAttributeType, optional: false, defaultValue: 100),
            attribute("defaultServingUnit", type: .stringAttributeType, optional: false, defaultValue: "g"),
            attribute("category", type: .stringAttributeType, optional: true),
            attribute("tags", type: .transformableAttributeType, optional: true),
            attribute("isFavorite", type: .booleanAttributeType, optional: false, defaultValue: false),
            attribute("useCount", type: .integer32AttributeType, optional: false, defaultValue: 0),
            attribute("lastUsedAt", type: .dateAttributeType, optional: true),
            attribute("createdAt", type: .dateAttributeType, optional: false),
            attribute("updatedAt", type: .dateAttributeType, optional: false)
        ]

        return entity
    }

    private static func createFoodEntryEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "CDFoodEntry"
        entity.managedObjectClassName = "CDFoodEntry"

        entity.properties = [
            attribute("id", type: .UUIDAttributeType, optional: false),
            attribute("date", type: .dateAttributeType, optional: false),
            attribute("mealCategory", type: .integer16AttributeType, optional: false, defaultValue: 0),
            attribute("foodName", type: .stringAttributeType, optional: false),
            attribute("portionSize", type: .doubleAttributeType, optional: false, defaultValue: 0),
            attribute("portionUnit", type: .stringAttributeType, optional: false, defaultValue: "g"),
            attribute("calories", type: .integer32AttributeType, optional: true),
            attribute("protein", type: .doubleAttributeType, optional: true),
            attribute("carbs", type: .doubleAttributeType, optional: true),
            attribute("fat", type: .doubleAttributeType, optional: true),
            attribute("fiber", type: .doubleAttributeType, optional: true),
            attribute("sugar", type: .doubleAttributeType, optional: true),
            attribute("notes", type: .stringAttributeType, optional: true),
            attribute("hungerLevel", type: .integer16AttributeType, optional: true),
            attribute("moodEmoji", type: .stringAttributeType, optional: true),
            attribute("createdAt", type: .dateAttributeType, optional: false),
            attribute("updatedAt", type: .dateAttributeType, optional: false)
        ]

        return entity
    }

    private static func createDrinkEntryEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "CDDrinkEntry"
        entity.managedObjectClassName = "CDDrinkEntry"

        entity.properties = [
            attribute("id", type: .UUIDAttributeType, optional: false),
            attribute("date", type: .dateAttributeType, optional: false),
            attribute("drinkType", type: .integer16AttributeType, optional: false, defaultValue: 0),
            attribute("name", type: .stringAttributeType, optional: true),
            attribute("amount", type: .doubleAttributeType, optional: false, defaultValue: 0),
            attribute("calories", type: .integer32AttributeType, optional: true),
            attribute("caffeineContent", type: .doubleAttributeType, optional: true),
            attribute("sugarContent", type: .doubleAttributeType, optional: true),
            attribute("notes", type: .stringAttributeType, optional: true),
            attribute("createdAt", type: .dateAttributeType, optional: false),
            attribute("updatedAt", type: .dateAttributeType, optional: false)
        ]

        return entity
    }

    private static func createWeightEntryEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "CDWeightEntry"
        entity.managedObjectClassName = "CDWeightEntry"

        entity.properties = [
            attribute("id", type: .UUIDAttributeType, optional: false),
            attribute("date", type: .dateAttributeType, optional: false),
            attribute("weight", type: .doubleAttributeType, optional: false, defaultValue: 0),
            attribute("notes", type: .stringAttributeType, optional: true),
            attribute("bodyFatPercentage", type: .doubleAttributeType, optional: true),
            attribute("muscleMass", type: .doubleAttributeType, optional: true),
            attribute("waistCircumference", type: .doubleAttributeType, optional: true),
            attribute("hipCircumference", type: .doubleAttributeType, optional: true),
            attribute("createdAt", type: .dateAttributeType, optional: false)
        ]

        return entity
    }

    private static func createAchievementEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "CDAchievement"
        entity.managedObjectClassName = "CDAchievement"

        entity.properties = [
            attribute("id", type: .UUIDAttributeType, optional: false),
            attribute("type", type: .stringAttributeType, optional: false),
            attribute("unlockedAt", type: .dateAttributeType, optional: true),
            attribute("progress", type: .doubleAttributeType, optional: false, defaultValue: 0)
        ]

        return entity
    }

    private static func createMealTemplateEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "CDMealTemplate"
        entity.managedObjectClassName = "CDMealTemplate"

        entity.properties = [
            attribute("id", type: .UUIDAttributeType, optional: false),
            attribute("name", type: .stringAttributeType, optional: false),
            attribute("mealCategory", type: .integer16AttributeType, optional: false, defaultValue: 0),
            attribute("isFavorite", type: .booleanAttributeType, optional: false, defaultValue: false),
            attribute("useCount", type: .integer32AttributeType, optional: false, defaultValue: 0),
            attribute("lastUsedAt", type: .dateAttributeType, optional: true),
            attribute("applicableDays", type: .transformableAttributeType, optional: true),
            attribute("createdAt", type: .dateAttributeType, optional: false)
        ]

        return entity
    }

    // MARK: - Relationships

    private static func setupRelationships(
        user: NSEntityDescription,
        foodItem: NSEntityDescription,
        foodEntry: NSEntityDescription,
        drinkEntry: NSEntityDescription,
        weightEntry: NSEntityDescription,
        achievement: NSEntityDescription,
        mealTemplate: NSEntityDescription
    ) {
        // User -> FoodEntry (one-to-many)
        let userToFoodEntries = NSRelationshipDescription()
        userToFoodEntries.name = "foodEntries"
        userToFoodEntries.destinationEntity = foodEntry
        userToFoodEntries.deleteRule = .cascadeDeleteRule
        userToFoodEntries.isOptional = true

        let foodEntryToUser = NSRelationshipDescription()
        foodEntryToUser.name = "user"
        foodEntryToUser.destinationEntity = user
        foodEntryToUser.deleteRule = .nullifyDeleteRule
        foodEntryToUser.maxCount = 1
        foodEntryToUser.isOptional = true

        userToFoodEntries.inverseRelationship = foodEntryToUser
        foodEntryToUser.inverseRelationship = userToFoodEntries

        // User -> DrinkEntry (one-to-many)
        let userToDrinkEntries = NSRelationshipDescription()
        userToDrinkEntries.name = "drinkEntries"
        userToDrinkEntries.destinationEntity = drinkEntry
        userToDrinkEntries.deleteRule = .cascadeDeleteRule
        userToDrinkEntries.isOptional = true

        let drinkEntryToUser = NSRelationshipDescription()
        drinkEntryToUser.name = "user"
        drinkEntryToUser.destinationEntity = user
        drinkEntryToUser.deleteRule = .nullifyDeleteRule
        drinkEntryToUser.maxCount = 1
        drinkEntryToUser.isOptional = true

        userToDrinkEntries.inverseRelationship = drinkEntryToUser
        drinkEntryToUser.inverseRelationship = userToDrinkEntries

        // User -> WeightEntry (one-to-many)
        let userToWeightEntries = NSRelationshipDescription()
        userToWeightEntries.name = "weightEntries"
        userToWeightEntries.destinationEntity = weightEntry
        userToWeightEntries.deleteRule = .cascadeDeleteRule
        userToWeightEntries.isOptional = true

        let weightEntryToUser = NSRelationshipDescription()
        weightEntryToUser.name = "user"
        weightEntryToUser.destinationEntity = user
        weightEntryToUser.deleteRule = .nullifyDeleteRule
        weightEntryToUser.maxCount = 1
        weightEntryToUser.isOptional = true

        userToWeightEntries.inverseRelationship = weightEntryToUser
        weightEntryToUser.inverseRelationship = userToWeightEntries

        // User -> Achievement (one-to-many)
        let userToAchievements = NSRelationshipDescription()
        userToAchievements.name = "achievements"
        userToAchievements.destinationEntity = achievement
        userToAchievements.deleteRule = .cascadeDeleteRule
        userToAchievements.isOptional = true

        let achievementToUser = NSRelationshipDescription()
        achievementToUser.name = "user"
        achievementToUser.destinationEntity = user
        achievementToUser.deleteRule = .nullifyDeleteRule
        achievementToUser.maxCount = 1
        achievementToUser.isOptional = true

        userToAchievements.inverseRelationship = achievementToUser
        achievementToUser.inverseRelationship = userToAchievements

        // FoodItem -> FoodEntry (one-to-many)
        let foodItemToEntries = NSRelationshipDescription()
        foodItemToEntries.name = "entries"
        foodItemToEntries.destinationEntity = foodEntry
        foodItemToEntries.deleteRule = .nullifyDeleteRule
        foodItemToEntries.isOptional = true

        let foodEntryToItem = NSRelationshipDescription()
        foodEntryToItem.name = "linkedFoodItem"
        foodEntryToItem.destinationEntity = foodItem
        foodEntryToItem.deleteRule = .nullifyDeleteRule
        foodEntryToItem.maxCount = 1
        foodEntryToItem.isOptional = true

        foodItemToEntries.inverseRelationship = foodEntryToItem
        foodEntryToItem.inverseRelationship = foodItemToEntries

        // MealTemplate -> FoodItem (many-to-many)
        let templateToItems = NSRelationshipDescription()
        templateToItems.name = "items"
        templateToItems.destinationEntity = foodItem
        templateToItems.deleteRule = .nullifyDeleteRule
        templateToItems.isOptional = true

        let itemToTemplates = NSRelationshipDescription()
        itemToTemplates.name = "templates"
        itemToTemplates.destinationEntity = mealTemplate
        itemToTemplates.deleteRule = .nullifyDeleteRule
        itemToTemplates.isOptional = true

        templateToItems.inverseRelationship = itemToTemplates
        itemToTemplates.inverseRelationship = templateToItems

        // Add relationships to entities
        user.properties.append(contentsOf: [userToFoodEntries, userToDrinkEntries, userToWeightEntries, userToAchievements])
        foodEntry.properties.append(contentsOf: [foodEntryToUser, foodEntryToItem])
        drinkEntry.properties.append(drinkEntryToUser)
        weightEntry.properties.append(weightEntryToUser)
        achievement.properties.append(achievementToUser)
        foodItem.properties.append(contentsOf: [foodItemToEntries, itemToTemplates])
        mealTemplate.properties.append(templateToItems)
    }

    // MARK: - Helper

    private static func attribute(
        _ name: String,
        type: NSAttributeType,
        optional: Bool,
        defaultValue: Any? = nil
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = optional
        if let defaultValue = defaultValue {
            attribute.defaultValue = defaultValue
        }
        return attribute
    }
}
