    //
    //  WorkoutSessionView.swift
    //  Gainz
    //
    //  Created by Cody Tate on 12/17/25.
    //
    //  DESCRIPTION:
    //  This view displays an active workout session, allowing users to:
    //  - View and manage exercises (workouts) within the session
    //  - Add, reorder (via drag-and-drop), and delete exercises
    //  - Add and delete sets for each exercise
    //  - Navigate to detailed workout views
    //  - End the current session
    //
    //  INTERACTIONS:
    //  - WorkoutSession (Core Data entity): The main data model for the session
    //  - Workout (Core Data entity): Individual exercises within a session
    //  - Set (Core Data entity): Sets within each workout/exercise
    //  - WorkoutDetailView: Navigation destination for detailed workout editing
    //  - Persistence.swift: Core Data stack for saving/loading data
    //  - ContentView.swift: Parent view that presents this view for active sessions
    //

    import SwiftUI
    import CoreData

// MARK: - Main View
/// The primary view for managing an active workout session.
/// Displays a list of exercises that can be reordered via drag-and-drop,
/// with support for adding/deleting exercises and sets.
struct WorkoutSessionView: View {
        @Environment(\.managedObjectContext) private var viewContext
        @Environment(\.dismiss) var dismiss
        
        @ObservedObject var session: WorkoutSession
        @State private var showingAddWorkout = false
        @State private var newWorkoutName = ""
        @State private var activeAddSetWorkoutID: NSManagedObjectID? = nil
        @State private var newSetReps = ""
        @State private var newSetWeight = ""
        @State private var draggedWorkout: Workout?
        
        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    sessionHeader
                    workoutList
                    addWorkoutButton
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
        
        // MARK: - View Components
        
        private var sessionHeader: some View {
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
        }
        
        private var workoutList: some View {
            List {
                ForEach(sortedWorkouts) { workout in
                    ExerciseCardView(
                        workout: workout,
                        activeAddSetWorkoutID: $activeAddSetWorkoutID,
                        newSetReps: $newSetReps,
                        newSetWeight: $newSetWeight,
                        onAddSet: { addSet(to: workout) },
                        onDeleteSet: deleteSet,
                        onDeleteWorkout: { deleteWorkout(workout) }
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
                }
                .onMove(perform: moveWorkouts)
                .onDelete(perform: deleteWorkouts)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        
private var addWorkoutButton: some View {
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
    
    // MARK: - Computed Properties
    private var sortedWorkouts: [Workout] {
        let workoutsSet = session.workouts as? Swift.Set<Workout> ?? []
        return workoutsSet.sorted { $0.order < $1.order }
    }
    
    // MARK: - Haptic Feedback
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // MARK: - Reorder Logic
    func moveWorkouts(from source: IndexSet, to destination: Int) {
        var workouts = sortedWorkouts
        workouts.move(fromOffsets: source, toOffset: destination)
        
        // Update order for all workouts
        withAnimation {
            for (index, workout) in workouts.enumerated() {
                workout.order = Int32(index)
            }
            
            do {
                try viewContext.save()
                triggerHapticFeedback()
            } catch {
                let nsError = error as NSError
                print("Error reordering workout: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteWorkouts(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                viewContext.delete(sortedWorkouts[index])
            }
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting workouts: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - CRUD Operations
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
    
    private func deleteWorkout(_ workout: Workout) {
        withAnimation {
            // Reorder remaining workouts
            let deletedOrder = workout.order
            for w in sortedWorkouts where w.order > deletedOrder {
                w.order -= 1
            }
            
            viewContext.delete(workout)
            
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

// MARK: - Exercise Card View
/// A card component displaying a single exercise/workout with its sets.
/// Features a blue accent bar, drag handle indicator, and expandable add-set form.
/// Used within WorkoutSessionView's list for each exercise.
struct ExerciseCardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var workout: Workout
    
    @Binding var activeAddSetWorkoutID: NSManagedObjectID?
    @Binding var newSetReps: String
    @Binding var newSetWeight: String
    
    let onAddSet: () -> Void
    let onDeleteSet: (Set) -> Void
    let onDeleteWorkout: () -> Void
    
    private var sortedSets: [Set] {
        let setsArray = (workout.sets as? NSSet)?.allObjects as? [Set] ?? []
        return setsArray.sorted { $0.order < $1.order }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Colored accent bar at top with rounded corners matching card
            UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 16)
                .fill(Color.blue.gradient)
                .frame(height: 4)
            
            VStack(spacing: 12) {
                // Header with drag hint
                NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                    HStack {
                        // Drag handle indicator
                        Image(systemName: "line.3.horizontal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.trailing, 4)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(workout.name ?? "Unnamed")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("\(workout.sets?.count ?? 0) sets")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Sets list
                if !sortedSets.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(Array(sortedSets.enumerated()), id: \.element) { index, set in
                            SetRowView(set: set, index: index + 1)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                Divider()
                    .padding(.horizontal, 16)
                
                // Add set controls
                if activeAddSetWorkoutID == workout.objectID {
                    AddSetFormView(
                        newSetReps: $newSetReps,
                        newSetWeight: $newSetWeight,
                        onAddSet: onAddSet,
                        onCancel: {
                            activeAddSetWorkoutID = nil
                            newSetReps = ""
                            newSetWeight = ""
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                } else {
                    // Compact Add Set button
                    Button(action: {
                        activeAddSetWorkoutID = workout.objectID
                        newSetReps = ""
                        newSetWeight = ""
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.subheadline)
                            Text("Add Set")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                    .padding(.bottom, 12)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
    }
}

// MARK: - Set Row View
/// Displays a single set within an exercise card.
/// Shows the set number, reps, and weight in a compact row format.
struct SetRowView: View {
    let set: Set
    let index: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Set \(index)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("\(set.reps) reps × \(String(format: "%.1f", set.weight)) lbs")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Add Set Form View
/// An inline form for adding a new set to an exercise.
/// Contains text fields for reps and weight, plus Add/Cancel buttons.
/// Displayed when the user taps "Add Set" on an exercise card.
struct AddSetFormView: View {
    @Binding var newSetReps: String
    @Binding var newSetWeight: String
    let onAddSet: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                TextField("Reps", text: $newSetReps)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
                
                TextField("Weight (lbs)", text: $newSetWeight)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
            }
            
            HStack(spacing: 12) {
                Button(action: onAddSet) {
                    Text("Add Set")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
            }
        }
    }
}

// MARK: - Drag Preview
/// A lightweight preview shown while dragging an exercise card.
/// Displays the exercise name with a drag handle icon.
/// Note: Currently unused as we switched to List-based reordering with EditButton.
struct ExerciseCardDragPreview: View {
    let workoutName: String
    
    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.secondary)
            Text(workoutName)
                .font(.headline)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Preview
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
