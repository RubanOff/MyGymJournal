import SwiftUI

struct WorkoutListView: View {
    let workouts: [Workout]
    let dataManager: DataManager
    let onEdit: (Workout) -> Void
    let deleteWorkout: (Workout) -> Void
    
    @State private var showingDeleteConfirmation = false
    @State private var workoutToDelete: Workout?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(workouts) { workout in
                    NavigationLink {
                        WorkoutDetailView(workout: workout, dataManager: dataManager)
                    } label: {
                        ModernWorkoutCard(workout: workout)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contextMenu {
                        Button(action: { onEdit(workout) }) {
                            Label("Редактировать", systemImage: "pencil")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            workoutToDelete = workout
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color.clear)
        // Кастомный алерт удаления
        .overlay {
            if showingDeleteConfirmation, let workout = workoutToDelete {
                DeleteConfirmationView(
                    isPresented: $showingDeleteConfirmation,
                    itemName: workout.name,
                    itemType: "тренировку",
                    onDelete: {
                        deleteWorkout(workout)
                        workoutToDelete = nil
                    }
                )
            }
        }
    }
}


// Новая карточка тренировки БЕЗ прогресс-бара
struct ModernWorkoutCard: View {
    let workout: Workout
    
    // Подсчёт выполненных подходов для статистики
    private var completedSetsCount: Int {
        workout.exercises.reduce(0) { $0 + $1.sets.filter { $0.isCompleted }.count }
    }
    
    private var totalSetsCount: Int {
        workout.exercises.reduce(0) { $0 + $1.sets.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Верхняя строка: название и время
            HStack {
                Text(workout.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Время в красивом чипе
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(workout.formattedTime)
                        .font(.caption)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color(.systemGray5))
                )
                .foregroundColor(.gray)
            }
            
            // Статистика
            HStack(spacing: 16) {
                // Упражнения
                Label(
                    title: { Text("\(workout.exercises.count)") },
                    icon: { Image(systemName: "figure.strengthtraining.traditional") }
                )
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.2))
                )
                
                // Подходы
                Label(
                    title: { Text("\(totalSetsCount)") },
                    icon: { Image(systemName: "arrow.counterclockwise") }
                )
                .font(.caption)
                .foregroundColor(.green)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color.green.opacity(0.2))
                )
                
                // Выполнено (если есть выполненные подходы)
                if completedSetsCount > 0 {
                    Label(
                        title: { Text("\(completedSetsCount)✓") },
                        icon: { Image(systemName: "checkmark") }
                    )
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.green.opacity(0.2))
                    )
                }
                
                Spacer()
                
                // Заметка (если есть)
                if !workout.notes.isEmpty {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.orange.opacity(0.2))
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}
