import SwiftUI

// Убираем повторное объявление WaveShape, так как оно уже есть в ContentView.swift

struct WorkoutDetailView: View {
    let workout: Workout
    @ObservedObject var dataManager: DataManager
    @State private var showingAddExerciseAlert = false
    @State private var showingNotesEditor = false
    @State private var workoutNotes = ""
    @State private var showingTimer = false
    
    // Состояния для редактирования упражнения
    @State private var showingEditExerciseAlert = false
    @State private var editingExercise: Exercise?
    @State private var editingExerciseName = ""
    
    // Состояния для удаления подхода
    @State private var showingDeleteSetAlert = false
    @State private var setToDelete: (set: WorkoutSet, exercise: Exercise)?
    
    var body: some View {
        ZStack {
            // 🔥 ФОН - как в Telegram (используем WaveShape из ContentView)
            ZStack {
                // Основной цвет
                Color(.systemGray6)
                
                // Мягкие волны
                WaveShape()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.15), .purple.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 300)
                    .offset(y: 250)
                    .blur(radius: 20)
                
                // Ещё одна волна
                WaveShape()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.15), .blue.opacity(0.1)],
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        )
                    )
                    .frame(height: 400)
                    .offset(y: 150)
                    .rotationEffect(.degrees(180))
                    .blur(radius: 25)
                
                // Третья маленькая волна для глубины
                WaveShape()
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.1), .pink.opacity(0.1)],
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )
                    )
                    .frame(height: 200)
                    .offset(y: 50)
                    .blur(radius: 30)
            }
            .ignoresSafeArea()
            
            // Основной контент
            ScrollView {
                VStack(spacing: 20) {
                    // Шапка тренировки
                    workoutHeader
                        .padding(.horizontal, 16)
                    
                    // Список упражнений
                    exercisesList
                        .padding(.horizontal, 16)
                    
                    // Кнопка добавления упражнения
                    addExerciseButton
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    // Кнопка заметки
                    Button(action: {
                        workoutNotes = workout.notes
                        showingNotesEditor = true
                    }) {
                        Image(systemName: workout.notes.isEmpty ? "note" : "note.text")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(workout.notes.isEmpty ? .gray : .blue)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color(.systemGray5))
                            )
                    }
                    
                    // Кнопка таймера
                    Button(action: { showingTimer = true }) {
                        Image(systemName: "timer")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.orange)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color(.systemGray5))
                            )
                    }
                    
                    // Кнопка добавления
                    Button(action: { showingAddExerciseAlert = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color(.systemGray5))
                            )
                    }
                }
            }
        }
        .sheet(isPresented: $showingNotesEditor) {
            NotesEditorView(notes: $workoutNotes, workout: workout, dataManager: dataManager, isPresented: $showingNotesEditor)
        }
        .sheet(isPresented: $showingTimer) {
            RestTimerView()
        }
        // Кастомный алерт для добавления упражнения
        .overlay {
            if showingAddExerciseAlert {
                AddExerciseAlertView(
                    isPresented: $showingAddExerciseAlert,
                    onSave: { name in
                        dataManager.addExercise(to: workout, name: name)
                    }
                )
            }
        }
        // Кастомный алерт для редактирования упражнения
        .overlay {
            if showingEditExerciseAlert, let exercise = editingExercise {
                EditExerciseAlertView(
                    isPresented: $showingEditExerciseAlert,
                    originalName: exercise.name,
                    onSave: { newName in
                        updateExerciseName(exercise, newName: newName)
                    }
                )
            }
        }
        // 👇 НОВЫЙ АЛЕРТ ДЛЯ УДАЛЕНИЯ ПОДХОДА
        .overlay {
            if showingDeleteSetAlert, let setToDelete = setToDelete {
                DeleteConfirmationView(
                    isPresented: $showingDeleteSetAlert,
                    itemName: "Подход \(getSetIndex(for: setToDelete.set, in: setToDelete.exercise) + 1)",
                    itemType: "подход",
                    onDelete: {
                        deleteSet()
                        showingDeleteSetAlert = false
                    }
                )
            }
        }
    }
    
    // Шапка тренировки
    private var workoutHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Название и дата
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            // Статистика
            HStack(spacing: 20) {
                statItem(
                    value: "\(workout.exercises.count)",
                    title: "упражнений",
                    icon: "figure.strengthtraining.traditional",
                    color: .blue
                )
                
                statItem(
                    value: "\(totalSets)",
                    title: "подходов",
                    icon: "arrow.counterclockwise",
                    color: .green
                )
                
                statItem(
                    value: "\(totalReps)",
                    title: "повторений",
                    icon: "repeat",
                    color: .orange
                )
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6).opacity(0.8))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    // Форматированная дата
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy 'в' HH:mm"
        return formatter.string(from: workout.date)
    }
    
    // Элемент статистики
    private func statItem(value: String, title: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Text(value)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5).opacity(0.5))
        )
    }
    
    // Список упражнений
    private var exercisesList: some View {
        VStack(spacing: 16) {
            ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { index, exercise in
                ExerciseCard(
                    exercise: exercise,
                    exerciseIndex: index,
                    workout: workout,
                    dataManager: dataManager,
                    onDelete: {
                        deleteExercise(exercise)
                    },
                    onEdit: {
                        editingExercise = exercise
                        editingExerciseName = exercise.name
                        showingEditExerciseAlert = true
                    },
                    onDeleteSet: { set, exercise in  // 👈 НОВОЕ ЗАМЫКАНИЕ
                        setToDelete = (set, exercise)
                        showingDeleteSetAlert = true
                    }
                )
            }
        }
    }
    
    // Кнопка добавления упражнения
    private var addExerciseButton: some View {
        Button(action: { showingAddExerciseAlert = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("Добавить упражнение")
                    .font(.headline)
            }
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    // Подсчет общего количества подходов
    private var totalSets: Int {
        workout.exercises.reduce(0) { $0 + $1.sets.count }
    }
    
    // Подсчет общего количества повторений
    private var totalReps: Int {
        workout.exercises.reduce(0) { $0 + $1.sets.reduce(0) { $0 + $1.repetitions } }
    }
    
    // Функция удаления упражнения
    private func deleteExercise(_ exercise: Exercise) {
        if let workoutIndex = dataManager.workouts.firstIndex(where: { $0.id == workout.id }),
           let exerciseIndex = dataManager.workouts[workoutIndex].exercises.firstIndex(where: { $0.id == exercise.id }) {
            dataManager.workouts[workoutIndex].exercises.remove(at: exerciseIndex)
            dataManager.saveData()
        }
    }
    
    // Функция обновления названия упражнения
    private func updateExerciseName(_ exercise: Exercise, newName: String) {
        if let workoutIndex = dataManager.workouts.firstIndex(where: { $0.id == workout.id }),
           let exerciseIndex = dataManager.workouts[workoutIndex].exercises.firstIndex(where: { $0.id == exercise.id }) {
            dataManager.workouts[workoutIndex].exercises[exerciseIndex].name = newName
            dataManager.saveData()
        }
    }
    
    private func deleteSet() {
        guard let (set, exercise) = setToDelete else { return }
        
        if let workoutIndex = dataManager.workouts.firstIndex(where: { $0.id == workout.id }),
           let exerciseIndex = dataManager.workouts[workoutIndex].exercises.firstIndex(where: { $0.id == exercise.id }),
           let setIndex = dataManager.workouts[workoutIndex].exercises[exerciseIndex].sets.firstIndex(where: { $0.id == set.id }) {
            dataManager.workouts[workoutIndex].exercises[exerciseIndex].sets.remove(at: setIndex)
            dataManager.saveData()
            setToDelete = nil
        }
    }
    
    // Вспомогательная функция для получения индекса подхода
    private func getSetIndex(for set: WorkoutSet, in exercise: Exercise) -> Int {
        return exercise.sets.firstIndex(where: { $0.id == set.id }) ?? 0
    }
}
