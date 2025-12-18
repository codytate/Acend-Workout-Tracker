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
}
