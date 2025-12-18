//
//  GainzApp.swift
//  Gainz
//
//  Created by Cody Tate on 12/17/25.
//

import SwiftUI
import CoreData

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
