import SwiftUI

struct ExerciseCard: View {
    let exercise: Exercise
    let exerciseIndex: Int
    let workout: Workout
    @ObservedObject var dataManager: DataManager
    let onDelete: () -> Void
    let onEdit: () -> Void
    let onDeleteSet: (WorkoutSet, Exercise) -> Void  // 👈 НОВОЕ ЗАМЫКАНИЕ
    
    @State private var isExpanded = false
    @State private var showingAddSet = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок упражнения
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    // Номер и название
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 32, height: 32)
                            
                            Text("\(exerciseIndex + 1)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        Text(exercise.name)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Статистика и кнопки
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text("\(exercise.sets.count)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Button(action: { showingAddSet = true }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.white)
                                .font(.title3)
                        }
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 20)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(.systemGray3))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            .contextMenu {
                Button(action: onEdit) {
                    Label("Редактировать", systemImage: "pencil")
                }
                
                Button(action: duplicateExercise) {
                    Label("Дублировать", systemImage: "doc.on.doc")
                }
                
                Divider()
                
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Удалить", systemImage: "trash")
                }
            }
            .overlay {
                if showingDeleteConfirmation {
                    DeleteConfirmationView(
                        isPresented: $showingDeleteConfirmation,
                        itemName: exercise.name,
                        itemType: "упражнение",
                        onDelete: {
                            onDelete()
                            showingDeleteConfirmation = false
                        }
                    )
                }
            }
            
            // Список подходов
            if isExpanded {
                if !exercise.sets.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { setIndex, set in
                            SetRow(
                                set: set,
                                setIndex: setIndex,
                                exercise: exercise,
                                workout: workout,
                                dataManager: dataManager,
                                onDelete: {  // 👈 ПЕРЕДАЁМ ЗАМЫКАНИЕ
                                    onDeleteSet(set, exercise)
                                }
                            )
                        }
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
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
    }
    
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
