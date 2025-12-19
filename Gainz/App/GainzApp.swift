    //
    //  GainzApp.swift
    //  Gainz
    //
    //  Created by Cody Tate on 12/17/25.
    //
    //  DESCRIPTION:
    //  The main entry point for the Gainz workout tracking app.
    //  Initializes the Core Data stack and injects it into the SwiftUI environment.
    //  Sets up ContentView as the root view of the application.
    //
    //  INTERACTIONS:
    //  - PersistenceController: Provides the Core Data container and context
    //  - ContentView: The root view displayed in the main window
    //  - All child views: Inherit the managedObjectContext from environment
    //

    import SwiftUI
    import CoreData

    /// The main application entry point.
    /// Configures Core Data and launches the root ContentView.
    @main
    struct GainzApp: App {
        let persistenceController = PersistenceController.shared

        var body: some Scene {
            WindowGroup {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
