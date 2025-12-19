import XCTest
import CoreData
@testable import Gainz

/// Tests for workout reordering and exercise card functionality
final class WorkoutSessionReorderTests: XCTestCase {
    
    var persistenceController: PersistenceController!
    var viewContext: NSManagedObjectContext!
    var session: WorkoutSession!
    
    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
        viewContext = persistenceController.container.viewContext
        
        // Create a test session
        session = WorkoutSession(context: viewContext)
        session.startDate = Date()
        
        try viewContext.save()
    }
    
    override func tearDownWithError() throws {
        session = nil
        viewContext = nil
        persistenceController = nil
    }
    
    // MARK: - Helper Methods
    
    private func createWorkout(name: String, order: Int32) -> Workout {
        let workout = Workout(context: viewContext)
        workout.name = name
        workout.order = order
        workout.session = session
        return workout
    }
    
    private func sortedWorkouts() -> [Workout] {
        let workoutsSet = session.workouts as? Swift.Set<Workout> ?? []
        return workoutsSet.sorted { $0.order < $1.order }
    }
    
    // MARK: - Reorder Tests
    
    func testMoveWorkoutDown() throws {
        // Arrange: Create 3 workouts in order 0, 1, 2
        let workout1 = createWorkout(name: "Bench Press", order: 0)
        let workout2 = createWorkout(name: "Squat", order: 1)
        let workout3 = createWorkout(name: "Deadlift", order: 2)
        try viewContext.save()
        
        // Act: Move workout1 (order 0) to position of workout3 (order 2)
        moveWorkout(from: workout1, to: workout3)
        try viewContext.save()
        
        // Assert: Order should be Squat (0), Deadlift (1), Bench Press (2)
        let sorted = sortedWorkouts()
        XCTAssertEqual(sorted[0].name, "Squat")
        XCTAssertEqual(sorted[0].order, 0)
        XCTAssertEqual(sorted[1].name, "Deadlift")
        XCTAssertEqual(sorted[1].order, 1)
        XCTAssertEqual(sorted[2].name, "Bench Press")
        XCTAssertEqual(sorted[2].order, 2)
    }
    
    func testMoveWorkoutUp() throws {
        // Arrange: Create 3 workouts in order 0, 1, 2
        let workout1 = createWorkout(name: "Bench Press", order: 0)
        let workout2 = createWorkout(name: "Squat", order: 1)
        let workout3 = createWorkout(name: "Deadlift", order: 2)
        try viewContext.save()
        
        // Act: Move workout3 (order 2) to position of workout1 (order 0)
        moveWorkout(from: workout3, to: workout1)
        try viewContext.save()
        
        // Assert: Order should be Deadlift (0), Bench Press (1), Squat (2)
        let sorted = sortedWorkouts()
        XCTAssertEqual(sorted[0].name, "Deadlift")
        XCTAssertEqual(sorted[0].order, 0)
        XCTAssertEqual(sorted[1].name, "Bench Press")
        XCTAssertEqual(sorted[1].order, 1)
        XCTAssertEqual(sorted[2].name, "Squat")
        XCTAssertEqual(sorted[2].order, 2)
    }
    
    func testMoveWorkoutToAdjacentPosition() throws {
        // Arrange: Create 3 workouts
        let workout1 = createWorkout(name: "Bench Press", order: 0)
        let workout2 = createWorkout(name: "Squat", order: 1)
        let workout3 = createWorkout(name: "Deadlift", order: 2)
        try viewContext.save()
        
        // Act: Swap adjacent positions (1 <-> 2)
        moveWorkout(from: workout2, to: workout3)
        try viewContext.save()
        
        // Assert: Bench (0), Deadlift (1), Squat (2)
        let sorted = sortedWorkouts()
        XCTAssertEqual(sorted[0].name, "Bench Press")
        XCTAssertEqual(sorted[1].name, "Deadlift")
        XCTAssertEqual(sorted[2].name, "Squat")
    }
    
    func testMoveWorkoutToSamePosition() throws {
        // Arrange
        let workout1 = createWorkout(name: "Bench Press", order: 0)
        try viewContext.save()
        
        let originalOrder = workout1.order
        
        // Act: Move to same position (no-op)
        moveWorkout(from: workout1, to: workout1)
        
        // Assert: Order unchanged
        XCTAssertEqual(workout1.order, originalOrder)
    }
    
    // MARK: - Delete Tests
    
    func testDeleteWorkoutReordersRemaining() throws {
        // Arrange: Create 3 workouts
        let workout1 = createWorkout(name: "Bench Press", order: 0)
        let workout2 = createWorkout(name: "Squat", order: 1)
        let workout3 = createWorkout(name: "Deadlift", order: 2)
        try viewContext.save()
        
        // Act: Delete middle workout
        deleteWorkout(workout2)
        try viewContext.save()
        
        // Assert: Remaining workouts should be reordered
        let sorted = sortedWorkouts()
        XCTAssertEqual(sorted.count, 2)
        XCTAssertEqual(sorted[0].name, "Bench Press")
        XCTAssertEqual(sorted[0].order, 0)
        XCTAssertEqual(sorted[1].name, "Deadlift")
        XCTAssertEqual(sorted[1].order, 1)
    }
    
    func testDeleteFirstWorkout() throws {
        // Arrange
        let workout1 = createWorkout(name: "Bench Press", order: 0)
        let workout2 = createWorkout(name: "Squat", order: 1)
        try viewContext.save()
        
        // Act
        deleteWorkout(workout1)
        try viewContext.save()
        
        // Assert
        let sorted = sortedWorkouts()
        XCTAssertEqual(sorted.count, 1)
        XCTAssertEqual(sorted[0].name, "Squat")
        XCTAssertEqual(sorted[0].order, 0)
    }
    
    // MARK: - Add Set Tests
    
    func testAddSetToWorkout() throws {
        // Arrange
        let workout = createWorkout(name: "Bench Press", order: 0)
        try viewContext.save()
        
        // Act
        let newSet = Set(context: viewContext)
        newSet.reps = 10
        newSet.weight = 135.0
        newSet.order = 0
        newSet.workout = workout
        try viewContext.save()
        
        // Assert
        XCTAssertEqual(workout.sets?.count, 1)
        let sets = (workout.sets as? NSSet)?.allObjects as? [Set]
        XCTAssertEqual(sets?.first?.reps, 10)
        XCTAssertEqual(sets?.first?.weight, 135.0)
    }
    
    func testDeleteSetFromWorkout() throws {
        // Arrange
        let workout = createWorkout(name: "Bench Press", order: 0)
        
        let set1 = Set(context: viewContext)
        set1.reps = 10
        set1.weight = 135.0
        set1.order = 0
        set1.workout = workout
        
        let set2 = Set(context: viewContext)
        set2.reps = 8
        set2.weight = 155.0
        set2.order = 1
        set2.workout = workout
        
        try viewContext.save()
        XCTAssertEqual(workout.sets?.count, 2)
        
        // Act
        viewContext.delete(set1)
        try viewContext.save()
        
        // Assert
        XCTAssertEqual(workout.sets?.count, 1)
    }
    
    // MARK: - View Loading Tests
    
    func testWorkoutSessionViewLoadsWithNewComponents() throws {
        // Arrange
        let workout = createWorkout(name: "Test Workout", order: 0)
        try viewContext.save()
        
        // Act & Assert - View should initialize without crashing
        let view = WorkoutSessionView(session: session)
            .environment(\.managedObjectContext, viewContext)
        
        XCTAssertNotNil(view)
    }
    
    func testExerciseCardViewLoads() throws {
        // Arrange
        let workout = createWorkout(name: "Test Workout", order: 0)
        try viewContext.save()
        
        // State bindings
        @State var activeID: NSManagedObjectID? = nil
        @State var reps = ""
        @State var weight = ""
        
        // Act & Assert - ExerciseCardView should initialize
        let cardView = ExerciseCardView(
            workout: workout,
            activeAddSetWorkoutID: .constant(nil),
            newSetReps: .constant(""),
            newSetWeight: .constant(""),
            onAddSet: {},
            onDeleteSet: { _ in },
            onDeleteWorkout: {}
        )
        .environment(\.managedObjectContext, viewContext)
        
        XCTAssertNotNil(cardView)
    }
    
    // MARK: - Helper Methods (Replicating View Logic for Testing)
    
    private func moveWorkouts(from source: IndexSet, to destination: Int) {
        var workouts = sortedWorkouts()
        workouts.move(fromOffsets: source, toOffset: destination)
        
        // Update order for all workouts
        for (index, workout) in workouts.enumerated() {
            workout.order = Int32(index)
        }
    }
    
    private func deleteWorkout(_ workout: Workout) {
        let deletedOrder = workout.order
        for w in sortedWorkouts() where w.order > deletedOrder {
            w.order -= 1
        }
        viewContext.delete(workout)
    }
}
