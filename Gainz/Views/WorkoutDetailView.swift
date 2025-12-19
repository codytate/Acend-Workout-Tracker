    //
    //  WorkoutDetailView.swift
    //  Gainz
    //
    //  Created by Cody Tate on 12/17/25.
    //

    import SwiftUI
    import CoreData

    struct WorkoutDetailView: View {
        @Environment(\.managedObjectContext) private var viewContext
        @ObservedObject var workout: Workout
        @State private var showingAddSet = false
        @State private var newSetReps = ""
        @State private var newSetWeight = ""
        
        var body: some View {
            VStack {
                // Workout header
                VStack(alignment: .leading, spacing: 8) {
                    Text(workout.name ?? "Unnamed Workout")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                
                // List of sets
                List {
                    ForEach(Array(sortedSets.enumerated()), id: \.element) { index, set in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Set \(index + 1)")
                                    .font(.headline)
                                Text("\(set.reps) reps × \(String(format: "%.1f", set.weight)) lbs")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                    }
                    .onDelete(perform: deleteSets)
                }
                
                // Add set button
                Button(action: { showingAddSet = true }) {
                    Label("Add Set", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Sets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddSet) {
                AddSetView(
                    reps: $newSetReps,
                    weight: $newSetWeight,
                    onAdd: addSet,
                    isPresented: $showingAddSet
                )
            }
        }
        
        private var sortedSets: [Set] {
            let setsArray = (workout.sets as? NSSet)?.allObjects as? [Set] ?? []
            return setsArray.sorted { $0.order < $1.order }
        }
        
        private func addSet() {
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
                } catch {
                    let nsError = error as NSError
                    print("Error saving set: \(nsError), \(nsError.userInfo)")
                }
            }
        }
        
        private func deleteSets(offsets: IndexSet) {
            withAnimation {
                offsets.map { sortedSets[$0] }.forEach(viewContext.delete)
                
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    print("Error deleting set: \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }

    // MARK: - Add Set View
    /// A modal sheet form for adding a new set to a workout.
    /// Contains input fields for reps and weight with validation.
    /// Presented from WorkoutDetailView when user taps "Add Set".
    struct AddSetView: View {
        @Binding var reps: String
        @Binding var weight: String
        var onAdd: () -> Void
        @Binding var isPresented: Bool
        
        var body: some View {
            NavigationView {
                Form {
                    Section("Set Details") {
                        HStack {
                            Text("Reps")
                            Spacer()
                            TextField("Number of reps", text: $reps)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }
                        
                        HStack {
                            Text("Weight (lbs)")
                            Spacer()
                            TextField("Weight in pounds", text: $weight)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }
                    }
                }
                .navigationTitle("Add Set")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            isPresented = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add") {
                            onAdd()
                            isPresented = false
                        }
                        .disabled(reps.isEmpty || weight.isEmpty)
                    }
                }
            }
        }
    }

    #Preview {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let workout = Workout(context: viewContext)
        workout.name = "Bench Press"
        
        let set = Set(context: viewContext)
        set.reps = 10
        set.weight = 225.0
        set.order = 0
        set.workout = workout
        
        return WorkoutDetailView(workout: workout)
            .environment(\.managedObjectContext, viewContext)
    }
