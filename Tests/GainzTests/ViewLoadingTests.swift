import XCTest
import SwiftUI
import UIKit
import CoreData
@testable import Gainz

final class ViewLoadingTests: XCTestCase {

    private func host<V: View>(_ view: V) {
        DispatchQueue.main.sync {
            let host = UIHostingController(rootView: view)
            host.loadViewIfNeeded()
            XCTAssertNotNil(host.view)
        }
    }

    func testContentViewLoads() throws {
        let controller = PersistenceController.preview
        let ctx = controller.container.viewContext

        let content = ContentView()
            .environment(\.managedObjectContext, ctx)

        host(content)
    }

    func testSessionHistoryViewShowsSession() throws {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.viewContext

        // create a session
        let session = WorkoutSession(context: ctx)
        session.startDate = Date()
        try ctx.save()

        let view = SessionHistoryView()
            .environment(\.managedObjectContext, ctx)

        host(view)
    }

    func testWorkoutSessionViewLoads() throws {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.viewContext

        let session = WorkoutSession(context: ctx)
        session.startDate = Date()

        let view = WorkoutSessionView(session: session)
            .environment(\.managedObjectContext, ctx)

        host(view)
    }

    func testWorkoutDetailViewLoads() throws {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.viewContext

        let workout = Workout(context: ctx)
        workout.name = "Test"

        let set = Set(context: ctx)
        set.reps = 5
        set.weight = 100
        set.order = 0
        set.workout = workout

        try ctx.save()

        let view = WorkoutDetailView(workout: workout)
            .environment(\.managedObjectContext, ctx)

        host(view)
    }
    
    // MARK: - New Component Tests
    
    func testExerciseCardViewLoads() throws {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.viewContext
        
        let session = WorkoutSession(context: ctx)
        session.startDate = Date()
        
        let workout = Workout(context: ctx)
        workout.name = "Bench Press"
        workout.order = 0
        workout.session = session
        
        try ctx.save()
        
        let view = ExerciseCardView(
            workout: workout,
            activeAddSetWorkoutID: .constant(nil),
            newSetReps: .constant(""),
            newSetWeight: .constant(""),
            onAddSet: {},
            onDeleteSet: { _ in },
            onDeleteWorkout: {}
        )
        .environment(\.managedObjectContext, ctx)
        
        host(view)
    }
    
    func testSetRowViewLoads() throws {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.viewContext
        
        let workout = Workout(context: ctx)
        workout.name = "Test"
        workout.order = 0
        
        let set = Set(context: ctx)
        set.reps = 10
        set.weight = 135.0
        set.order = 0
        set.workout = workout
        
        try ctx.save()
        
        let view = SetRowView(set: set, index: 1)
        
        host(view)
    }
    
    func testAddSetFormViewLoads() throws {
        let view = AddSetFormView(
            newSetReps: .constant("10"),
            newSetWeight: .constant("135"),
            onAddSet: {},
            onCancel: {}
        )
        
        host(view)
    }
    
    func testExerciseCardDragPreviewLoads() throws {
        let view = ExerciseCardDragPreview(workoutName: "Bench Press")
        
        host(view)
    }
    
    func testWorkoutSessionViewWithMultipleWorkouts() throws {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.viewContext
        
        let session = WorkoutSession(context: ctx)
        session.startDate = Date()
        
        // Create multiple workouts to test reorder functionality
        let workout1 = Workout(context: ctx)
        workout1.name = "Bench Press"
        workout1.order = 0
        workout1.session = session
        
        let workout2 = Workout(context: ctx)
        workout2.name = "Squat"
        workout2.order = 1
        workout2.session = session
        
        let workout3 = Workout(context: ctx)
        workout3.name = "Deadlift"
        workout3.order = 2
        workout3.session = session
        
        // Add sets to workouts
        let set1 = Set(context: ctx)
        set1.reps = 8
        set1.weight = 225.0
        set1.order = 0
        set1.workout = workout1
        
        let set2 = Set(context: ctx)
        set2.reps = 5
        set2.weight = 315.0
        set2.order = 0
        set2.workout = workout2
        
        try ctx.save()
        
        let view = WorkoutSessionView(session: session)
            .environment(\.managedObjectContext, ctx)
        
        host(view)
    }
}
