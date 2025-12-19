    //
    //  Persistence.swift
    //  Gainz
    //
    //  Created by Cody Tate on 12/17/25.
    //
    //  DESCRIPTION:
    //  Core Data persistence controller that manages the app's data stack.
    //  Provides access to the NSPersistentContainer and managed object context.
    //  Includes a preview instance with sample data for SwiftUI previews.
    //
    //  INTERACTIONS:
    //  - Gainz.xcdatamodeld: The Core Data model defining entities
    //  - GainzApp.swift: Injects the viewContext into the environment
    //  - All Views: Access viewContext via @Environment for CRUD operations
    //  - Core Data Entities: WorkoutSession, Workout, Set
    //

    import CoreData

    /// Manages the Core Data stack for the Gainz app.
    /// Provides shared and preview instances for production and testing.
    struct PersistenceController {
        static let shared = PersistenceController()

        @MainActor
        static let preview: PersistenceController = {
            let result = PersistenceController(inMemory: true)
            let viewContext = result.container.viewContext
            
            // Create a sample active workout session
            let activeSession = WorkoutSession(context: viewContext)
            activeSession.startDate = Date().addingTimeInterval(-3600) // 1 hour ago
            activeSession.endDate = nil
            
            // Add some sample workouts to the session
            let workout1 = Workout(context: viewContext)
            workout1.name = "Bench Press"
            workout1.order = 0
            workout1.session = activeSession
            
            let set1 = Set(context: viewContext)
            set1.weight = 225
            set1.reps = 8
            set1.order = 0
            set1.workout = workout1
            
            let set2 = Set(context: viewContext)
            set2.weight = 225
            set2.reps = 6
            set2.order = 1
            set2.workout = workout1
            
            let workout2 = Workout(context: viewContext)
            workout2.name = "Incline Dumbbell Press"
            workout2.order = 1
            workout2.session = activeSession
            
            let set3 = Set(context: viewContext)
            set3.weight = 80
            set3.reps = 10
            set3.order = 0
            set3.workout = workout2
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            return result
        }()

        let container: NSPersistentContainer

        init(inMemory: Bool = false) {
            container = NSPersistentContainer(name: "Gainz")
            if inMemory {
                container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            }
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            container.viewContext.automaticallyMergesChangesFromParent = true
        }
    }
