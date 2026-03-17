import SwiftUI

struct ExerciseCard: View {
    let exercise: Exercise
    let exerciseIndex: Int
    let workout: Workout
    @ObservedObject var dataManager: DataManager
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    // Меняем на false, чтобы упражнения были свернуты
    @State private var isExpanded = false
    @State private var showingAddSet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок упражнения (всегда видимый)
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    // Номер и название
                    HStack(spacing: 12) {
                        // Номер в градиентном кружке
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: isExpanded ? [.blue, .purple] : [.gray.opacity(0.5), .gray.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                            
                            Text("\(exerciseIndex + 1)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        Text(exercise.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Статистика и кнопки
                    HStack(spacing: 12) {
                        // Количество подходов
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("\(exercise.sets.count)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Кнопка добавления подхода
                        Button(action: { showingAddSet = true }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                        }
                        
                        // Иконка раскрытия/сворачивания
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(width: 20)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Список подходов (раскрывающийся)
            if isExpanded {
                if !exercise.sets.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { setIndex, set in
                            SetRow(
                                set: set,
                                setIndex: setIndex,
                                exercise: exercise,
                                workout: workout,
                                dataManager: dataManager
                            )
                        }
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    // Пустое состояние (нет подходов)
                    HStack {
                        Text("Нет подходов")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: { showingAddSet = true }) {
                            Text("Добавить")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .transition(.opacity)
                }
            }
        }
        .sheet(isPresented: $showingAddSet) {
            AddSetView(exercise: exercise, workout: workout, dataManager: dataManager)
        }
        // Контекстное меню при долгом нажатии на заголовок
        .contextMenu {
            Button(action: onEdit) {
                Label("Редактировать", systemImage: "pencil")
            }
            
            Button(action: duplicateExercise) {
                Label("Дублировать", systemImage: "doc.on.doc")
            }
            
            Divider()
            
            Button(role: .destructive, action: onDelete) {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
    
    // Функция дублирования упражнения
    private func duplicateExercise() {
        if let workoutIndex = dataManager.workouts.firstIndex(where: { $0.id == workout.id }),
           let exerciseIndex = dataManager.workouts[workoutIndex].exercises.firstIndex(where: { $0.id == exercise.id }) {
            
            let originalExercise = dataManager.workouts[workoutIndex].exercises[exerciseIndex]
            
            let duplicatedExercise = Exercise(
                id: UUID(),
                name: originalExercise.name + " (копия)",
                sets: originalExercise.sets.map { set in
                    WorkoutSet(
                        id: UUID(),
                        weight: set.weight,
                        repetitions: set.repetitions,
                        isCompleted: false
                    )
                },
                notes: originalExercise.notes
            )
            
            dataManager.workouts[workoutIndex].exercises.insert(duplicatedExercise, at: exerciseIndex + 1)
            dataManager.saveData()
        }
    }
}
