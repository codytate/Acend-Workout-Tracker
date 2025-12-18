//
//  WorkoutSessionView.swift
//  Gainz
//
//  Created by Cody Tate on 12/17/25.
//

import SwiftUI
import CoreData

struct WorkoutSessionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var session: WorkoutSession
    @State private var showingAddWorkout = false
    @State private var newWorkoutName = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Session header with elapsed time
                HStack {
                    VStack(alignment: .leading) {
                        Text("Workout Session")
                            .font(.headline)
                        Text(session.startDate ?? Date(), style: .time)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: endSession) {
                        Label("End", systemImage: "stop.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // List of workouts in this session
                List {
                    ForEach(sortedWorkouts) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(workout.name ?? "Unnamed")
                                    .font(.headline)
                                Text("\(workout.sets?.count ?? 0) sets")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: deleteWorkouts)
                }
                
                // Add workout button
                Button(action: { showingAddWorkout = true }) {
                    Label("Add Workout", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Active Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
        }
        .alert("Add Workout", isPresented: $showingAddWorkout) {
            TextField("Workout name (e.g., Bench Press)", text: $newWorkoutName)
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                addWorkout()
            }
        }
    }
    
    private var sortedWorkouts: [Workout] {
        let workoutsArray = (session.workouts as? NSSet)?.allObjects as? [Workout] ?? []
        return workoutsArray.sorted { $0.order < $1.order }
    }
    
    private func addWorkout() {
        guard !newWorkoutName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        withAnimation {
            let newWorkout = Workout(context: viewContext)
            newWorkout.name = newWorkoutName
            newWorkout.order = Int32((session.workouts?.count ?? 0))
            newWorkout.session = session
            
            do {
                try viewContext.save()
                newWorkoutName = ""
            } catch {
                let nsError = error as NSError
                print("Error saving workout: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteWorkouts(offsets: IndexSet) {
        withAnimation {
            offsets.map { sortedWorkouts[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting workout: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func endSession() {
        withAnimation {
            session.endDate = Date()
            do {
                try viewContext.save()
                dismiss()
            } catch {
                let nsError = error as NSError
                print("Error ending session: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    let controller = PersistenceController(inMemory: true)
    let viewContext = controller.container.viewContext
    
    let session = WorkoutSession(context: viewContext)
    session.startDate = Date()
    
    return WorkoutSessionView(session: session)
        .environment(\.managedObjectContext, viewContext)
}
