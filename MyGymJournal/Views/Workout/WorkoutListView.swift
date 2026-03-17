import SwiftUI

struct WorkoutListView: View {
    let workouts: [Workout]
    let dataManager: DataManager
    let onEdit: (Workout) -> Void
    let deleteWorkout: (Workout) -> Void
    
    var body: some View {
        List {
            ForEach(workouts) { workout in
                NavigationLink {
                    WorkoutDetailView(workout: workout, dataManager: dataManager)
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(workout.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            Label("\(workout.exercises.count) упражнений", systemImage: "figure.strengthtraining.traditional")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                            
                            Spacer()
                            
                            Text(workout.formattedTime)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            if !workout.notes.isEmpty {
                                Label("Заметка", systemImage: "note.text")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(8)
                            } else {
                                Color.clear
                                    .frame(width: 1, height: 1)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .contextMenu {
                    Button(action: {
                        onEdit(workout)
                    }) {
                        Label("Редактировать", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        deleteWorkout(workout)
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}
