import SwiftUI

struct SetRow: View {
    let set: WorkoutSet
    let setIndex: Int
    let exercise: Exercise
    let workout: Workout
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        HStack {
            Text("\(setIndex + 1)")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 24)
            
            Button(action: {
                dataManager.toggleSet(set, in: exercise, workout: workout)
            }) {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(set.isCompleted ? .green : .gray)
                    .font(.title3)
            }
            
            HStack(spacing: 4) {
                Text("\(String(format: "%.1f", set.weight))")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("кг")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("×")
                    .font(.body)
                    .foregroundColor(.gray)
                
                Text("\(set.repetitions)")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("раз")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .strikethrough(set.isCompleted)
            .opacity(set.isCompleted ? 0.7 : 1)
            
            Spacer()
            
            Menu {
                Button(role: .destructive) {
                    deleteSet()
                } label: {
                    Label("Удалить подход", systemImage: "trash")
                }
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.7))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.red.opacity(0.1))
                    )
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    private func deleteSet() {
        if let workoutIndex = dataManager.workouts.firstIndex(where: { $0.id == workout.id }),
           let exerciseIndex = dataManager.workouts[workoutIndex].exercises.firstIndex(where: { $0.id == exercise.id }),
           let setIndex = dataManager.workouts[workoutIndex].exercises[exerciseIndex].sets.firstIndex(where: { $0.id == set.id }) {
            dataManager.workouts[workoutIndex].exercises[exerciseIndex].sets.remove(at: setIndex)
            dataManager.saveData()
        }
    }
}
