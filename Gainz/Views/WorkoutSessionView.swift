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
        @State private var isEditing = false
        @State private var activeAddSetWorkoutID: NSManagedObjectID? = nil
        @State private var newSetReps = ""
        @State private var newSetWeight = ""
        
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
                    
                    // Use a scroll + cards so each exercise is visually separated
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(sortedWorkouts) { workout in
                                VStack(spacing: 8) {
                                    // Header (navigates to detail)
                                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(workout.name ?? "Unnamed")
                                                    .font(.headline)
                                                Text("\(workout.sets?.count ?? 0) sets")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            if !isEditing {
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    // Sets list inside the card
                                    VStack(spacing: 8) {
                                        ForEach(Array(sortedSets(for: workout).enumerated()), id: \.element) { index, set in
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("Set \(index + 1)")
                                                        .font(.subheadline)
                                                        .fontWeight(.semibold)
                                                    Text("\(set.reps) reps × \(String(format: "%.1f", set.weight)) lbs")
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                                Spacer()
                                                if isEditing {
                                                    Button(role: .destructive) {
                                                        deleteSet(set)
                                                    } label: {
                                                        Image(systemName: "trash")
                                                            .foregroundColor(.red)
                                                    }
                                                }
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                    
                                    Divider()
                                    
                                    // Add set controls
                                    if activeAddSetWorkoutID == workout.objectID {
                                        VStack(spacing: 8) {
                                            HStack {
                                                TextField("Reps", text: $newSetReps)
                                                    .keyboardType(.numberPad)
                                                    .textFieldStyle(.roundedBorder)
                                                    .frame(width: 100)
                                                Spacer()
                                                TextField("Weight", text: $newSetWeight)
                                                    .keyboardType(.decimalPad)
                                                    .textFieldStyle(.roundedBorder)
                                                    .frame(width: 120)
                                            }
                                            
                                            HStack(spacing: 12) {
                                                Button(action: { addSet(to: workout) }) {
                                                    Text("Add Set")
                                                        .frame(maxWidth: .infinity)
                                                        .padding(8)
                                                        .background(Color.green)
                                                        .foregroundColor(.white)
                                                        .cornerRadius(8)
                                                }
                                                
                                                Button(action: {
                                                    activeAddSetWorkoutID = nil
                                                    newSetReps = ""
                                                    newSetWeight = ""
                                                }) {
                                                    Text("Cancel")
                                                        .frame(maxWidth: .infinity)
                                                        .padding(8)
                                                        .background(Color(.systemGray5))
                                                        .cornerRadius(8)
                                                }
                                            }
                                        }
                                        .padding()
                                    } else {
                                        Button(action: {
                                            activeAddSetWorkoutID = workout.objectID
                                            newSetReps = ""
                                            newSetWeight = ""
                                        }) {
                                            Text("Add Set")
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.green)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                        }
                                        .padding([.horizontal, .bottom])
                                    }
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
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
            let workoutsSet = session.workouts as? Swift.Set<Workout> ?? []
            return workoutsSet.sorted { $0.order < $1.order }
        }
        
        private func sortedSets(for workout: Workout) -> [Set] {
            let setsArray = (workout.sets as? NSSet)?.allObjects as? [Set] ?? []
            return setsArray.sorted { $0.order < $1.order }
        }
        
        private func addSet(to workout: Workout) {
            guard !newSetReps.isEmpty, !newSetWeight.isEmpty,
                  let reps = Int32(newSetReps),
                  let weight = Double(newSetWeight) else {
                return
            }

            withAnimation {
                let newSet = Set(context: viewContext)
                newSet.reps = reps
                newSet.weight = weight
                newSet.order = Int32((workout.sets?.count ?? 0))
                newSet.workout = workout

                do {
                    try viewContext.save()
                    newSetReps = ""
                    newSetWeight = ""
                    activeAddSetWorkoutID = nil
                } catch {
                    let nsError = error as NSError
                    print("Error saving set: \(nsError), \(nsError.userInfo)")
                }
            }
        }
        
        private func deleteSet(_ set: Set) {
            withAnimation {
                viewContext.delete(set)
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    print("Error deleting set: \(nsError), \(nsError.userInfo)")
                }
            }
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
        let controller = PersistenceController.preview
        let viewContext = controller.container.viewContext
        
        // Try to fetch an active session from the seeded preview data
        let sessionFetch: NSFetchRequest<WorkoutSession> = WorkoutSession.fetchRequest()
        sessionFetch.predicate = NSPredicate(format: "endDate == nil")
        sessionFetch.sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutSession.startDate, ascending: false)]
        let sessions = (try? viewContext.fetch(sessionFetch)) ?? []
        let session = sessions.first ?? {
            let s = WorkoutSession(context: viewContext)
            s.startDate = Date()
            return s
        }()
        
        return WorkoutSessionView(session: session)
            .environment(\.managedObjectContext, viewContext)
    }
