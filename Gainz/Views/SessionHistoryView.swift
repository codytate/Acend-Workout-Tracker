    //
    //  SessionHistoryView.swift
    //  Gainz
    //
    //  Created by Cody Tate on 12/17/25.
    //

    import SwiftUI
    import CoreData

    struct SessionHistoryView: View {
        @Environment(\.managedObjectContext) private var viewContext
        
        @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutSession.startDate, ascending: false)],
            animation: .default
        )
        private var sessions: FetchedResults<WorkoutSession>
        
        var body: some View {
            NavigationView {
                VStack {
                    if sessions.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No Workout Sessions")
                                .font(.headline)
                            Text("Start a new workout session to see it here")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground))
                    } else {
                        List {
                            ForEach(sessions) { session in
                                NavigationLink(destination: SessionDetailView(session: session)) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(session.startDate ?? Date(), style: .date)
                                                .font(.headline)
                                            Spacer()
                                            if session.endDate != nil {
                                                Text("Completed")
                                                    .font(.caption)
                                                    .foregroundColor(.green)
                                            } else {
                                                Text("Active")
                                                    .font(.caption)
                                                    .foregroundColor(.orange)
                                            }
                                        }
                                        
                                        Text("\(session.workouts?.count ?? 0) workouts")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                        if let duration = sessionDuration(session) {
                                            Text(duration)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                            .onDelete(perform: deleteSessions)
                        }
                    }
                }
                .navigationTitle("Session History")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if !sessions.isEmpty {
                            EditButton()
                        }
                    }
                }
            }
        }
        
        private func sessionDuration(_ session: WorkoutSession) -> String? {
            guard let startDate = session.startDate else { return nil }
            let end = session.endDate ?? Date()
            let duration = Calendar.current.dateComponents([.hour, .minute], from: startDate, to: end)
            
            if let hour = duration.hour, hour > 0 {
                return "\(hour)h \(duration.minute ?? 0)m"
            } else if let minute = duration.minute {
                return "\(minute)m"
            }
            return nil
        }
        
        private func deleteSessions(offsets: IndexSet) {
            withAnimation {
                offsets.map { sessions[$0] }.forEach(viewContext.delete)
                
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    print("Error deleting session: \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }

    // MARK: - Session Detail View
    /// Displays detailed information about a single workout session.
    /// Shows session date, status, and a list of all workouts performed.
    /// Accessed by tapping a session row in SessionHistoryView.
    struct SessionDetailView: View {
        @ObservedObject var session: WorkoutSession
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Date")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(session.startDate ?? Date(), style: .date)
                            .font(.headline)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Status")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(session.endDate != nil ? "Completed" : "Active")
                            .font(.headline)
                            .foregroundColor(session.endDate != nil ? .green : .orange)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                Text("Workouts")
                    .font(.headline)
                    .padding(.horizontal)
                
                List {
                    ForEach((session.workouts as? [Workout] ?? []).sorted { ($0.order) < ($1.order) }) { workout in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(workout.name ?? "Unnamed")
                                .font(.headline)
                            Text("\(workout.sets?.count ?? 0) sets")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    #Preview {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let session = WorkoutSession(context: viewContext)
        session.startDate = Date()
        session.endDate = Date().addingTimeInterval(3600)
        
        let workout = Workout(context: viewContext)
        workout.name = "Chest Day"
        workout.order = 0
        workout.session = session
        
        return SessionHistoryView()
            .environment(\.managedObjectContext, viewContext)
    }
