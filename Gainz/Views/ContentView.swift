    //
    //  ContentView.swift
    //  Gainz
    //
    //  Created by Cody Tate on 12/17/25.
    //
    //  DESCRIPTION:
    //  The root view of the application containing the main TabView navigation.
    //  Manages the app's primary navigation between:
    //  - Active Session tab: Shows current workout or option to start new one
    //  - History tab: Shows past completed workout sessions
    //
    //  INTERACTIONS:
    //  - WorkoutSession (Core Data entity): Fetches and creates workout sessions
    //  - WorkoutSessionView: Presented when there's an active session
    //  - SessionHistoryView: Displayed in the History tab
    //  - Persistence.swift: Core Data stack for data operations
    //  - GainzApp.swift: Parent that provides the managed object context
    //

    import SwiftUI
    import CoreData

    /// The main container view for the Gainz app.
    /// Provides tab-based navigation between active workout and history views.
    /// Automatically detects and displays any active (non-ended) workout session.
    struct ContentView: View {
        @Environment(\.managedObjectContext) private var viewContext
        @State private var activeSession: WorkoutSession?
        @State private var showingNewSession = false
        
        @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutSession.startDate, ascending: false)],
            predicate: NSPredicate(format: "endDate == nil"),
            animation: .default
        )
        private var activeSessions: FetchedResults<WorkoutSession>
        
        var body: some View {
            TabView {
                // Active Session Tab
                VStack {
                    if activeSessions.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "dumbbell.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            Text("No Active Session")
                                .font(.headline)
                            Text("Start a new workout session to begin")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Button(action: startNewSession) {
                                Label("Start Workout", systemImage: "play.circle.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground))
                    } else if let session = activeSessions.first, activeSession == nil {
                        WorkoutSessionView(session: session)
                            .onDisappear {
                                activeSession = nil
                            }
                    } else if let session = activeSession {
                        WorkoutSessionView(session: session)
                            .onDisappear {
                                activeSession = nil
                            }
                    } else {
                        Text("Loading...")
                    }
                }
                .tabItem {
                    Label("Active", systemImage: "play.circle.fill")
                }
                
                // Session History Tab
                SessionHistoryView()
                    .tabItem {
                        Label("History", systemImage: "calendar")
                    }
            }
        }
        
        private func startNewSession() {
            withAnimation {
                let newSession = WorkoutSession(context: viewContext)
                newSession.startDate = Date()
                
                do {
                    try viewContext.save()
                    activeSession = newSession
                } catch {
                    let nsError = error as NSError
                    print("Error creating session: \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }

    #Preview {
        let controller = PersistenceController.preview
        ContentView()
            .environment(\.managedObjectContext, controller.container.viewContext)
    }
