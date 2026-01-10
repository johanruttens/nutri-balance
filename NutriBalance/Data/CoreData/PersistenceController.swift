import CoreData

/// Manages the Core Data stack for the application.
/// Provides access to the managed object context and handles persistence operations.
final class PersistenceController {

    // MARK: - Singleton

    static let shared = PersistenceController()

    // MARK: - Preview Support

    @MainActor
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        // Create sample data for previews
        let context = controller.container.viewContext

        // Add sample user
        let user = CDUser(context: context)
        user.id = UUID()
        user.firstName = "Johan"
        user.lastName = "Ruttens"
        user.currentWeight = 85.0
        user.targetWeight = 81.0
        user.dailyCalorieGoal = 1800
        user.dailyWaterGoal = 2500
        user.activityLevel = 2
        user.preferredLanguage = "en"
        user.notificationsEnabled = true
        user.onboardingCompleted = true
        user.createdAt = Date()
        user.updatedAt = Date()

        // Add sample food entries
        let breakfast = CDFoodEntry(context: context)
        breakfast.id = UUID()
        breakfast.date = Date()
        breakfast.mealCategory = 0 // breakfast
        breakfast.foodName = "Oatmeal with Berries"
        breakfast.portionSize = 250
        breakfast.portionUnit = "g"
        breakfast.calories = 350
        breakfast.protein = 12
        breakfast.carbs = 55
        breakfast.fat = 8
        breakfast.createdAt = Date()
        breakfast.updatedAt = Date()
        breakfast.user = user

        // Add sample drink entries
        let water = CDDrinkEntry(context: context)
        water.id = UUID()
        water.date = Date()
        water.drinkType = 0 // water
        water.amount = 250
        water.createdAt = Date()
        water.updatedAt = Date()
        water.user = user

        do {
            try context.save()
        } catch {
            fatalError("Failed to save preview data: \(error)")
        }

        return controller
    }()

    // MARK: - Container

    let container: NSPersistentContainer

    // MARK: - Initialization

    init(inMemory: Bool = false) {
        // Create container with programmatic model
        container = NSPersistentContainer(
            name: "NutriBalance",
            managedObjectModel: CoreDataModel.createModel()
        )

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stores: \(error)")
            }
        }

        // Configure view context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        // Enable lightweight migration
        let description = container.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        description?.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
    }

    // MARK: - Context Access

    /// Main view context for UI operations
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    /// Creates a new background context for heavy operations
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    // MARK: - Save Operations

    /// Saves the view context if there are changes
    func save() {
        let context = viewContext
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            // Log error in production
            print("Failed to save context: \(error)")
        }
    }

    /// Saves the view context, throwing on error
    func saveOrThrow() throws {
        let context = viewContext
        guard context.hasChanges else { return }
        try context.save()
    }

    /// Saves a background context
    func save(context: NSManagedObjectContext) {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            print("Failed to save background context: \(error)")
        }
    }

    // MARK: - Batch Operations

    /// Performs a batch delete for a fetch request
    func batchDelete<T: NSManagedObject>(
        _ type: T.Type,
        predicate: NSPredicate? = nil
    ) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type))
        fetchRequest.predicate = predicate

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs

        let result = try container.persistentStoreCoordinator.execute(
            deleteRequest,
            with: viewContext
        ) as? NSBatchDeleteResult

        // Merge changes into context
        if let objectIDs = result?.result as? [NSManagedObjectID] {
            let changes = [NSDeletedObjectsKey: objectIDs]
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: changes,
                into: [viewContext]
            )
        }
    }

    // MARK: - Reset

    /// Resets the entire Core Data store (use with caution)
    func resetStore() throws {
        guard let storeURL = container.persistentStoreDescriptions.first?.url else {
            return
        }

        try container.persistentStoreCoordinator.destroyPersistentStore(
            at: storeURL,
            ofType: NSSQLiteStoreType,
            options: nil
        )

        try container.persistentStoreCoordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL,
            options: nil
        )
    }
}

// MARK: - Managed Object Context Extensions

extension NSManagedObjectContext {
    /// Performs save if there are changes, ignoring errors
    func saveIfNeeded() {
        guard hasChanges else { return }
        do {
            try save()
        } catch {
            print("Context save failed: \(error)")
        }
    }

    /// Performs a save and throws on error
    func saveOrThrow() throws {
        guard hasChanges else { return }
        try save()
    }
}
