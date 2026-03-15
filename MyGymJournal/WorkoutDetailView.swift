import SwiftUI

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
    
    var body: some View {
        ZStack {
            //
            //
            // Основной контент
            ScrollView {
                VStack(spacing: 20) {
                    // Шапка тренировки
                    workoutHeader
                    
                    // Список упражнений
                    exercisesList
                    
                    // Кнопка добавления упражнения
                    addExerciseButton
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemGray6).opacity(0.9),
                        Color(.systemGray5).opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
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
        // Кастомный алерт для редактирования упражнения (НА ВЕРХНЕМ УРОВНЕ)
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
        .padding(.bottom, 8)
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
                        // Передаем упражнение для редактирования на верхний уровень
                        editingExercise = exercise
                        editingExerciseName = exercise.name
                        showingEditExerciseAlert = true
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
        .padding(.top, 8)
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
}

// Карточка упражнения
struct ExerciseCard: View {
    let exercise: Exercise
    let exerciseIndex: Int
    let workout: Workout
    @ObservedObject var dataManager: DataManager
    let onDelete: () -> Void
    let onEdit: () -> Void  // Добавляем замыкание для редактирования
    
    @State private var isExpanded = true
    @State private var showingAddSet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок упражнения
            Button(action: { withAnimation(.spring()) { isExpanded.toggle() } }) {
                HStack {
                    // Номер и название
                    HStack(spacing: 12) {
                        Text("\(exerciseIndex + 1)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                        
                        Text(exercise.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Статистика упражнения
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
                        
                        // Кнопка меню (три точки)
                        Menu {
                            // Кнопка редактирования названия
                            Button(action: onEdit) {  // Вызываем замыкание
                                Label("Редактировать", systemImage: "pencil")
                            }
                            
                            // Кнопка дублирования упражнения
                            Button(action: duplicateExercise) {
                                Label("Дублировать", systemImage: "doc.on.doc")
                            }
                            
                            Divider()
                            
                            // Кнопка удаления (красная)
                            Button(role: .destructive, action: onDelete) {
                                Label("Удалить", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.gray)
                                .font(.title3)
                                .frame(width: 24, height: 24)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(Color(.systemGray5))
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray5))
                )
            }
            
            // Список подходов (раскрывающийся)
            if isExpanded && !exercise.sets.isEmpty {
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
            }
            
            // Пустое состояние (нет подходов)
            if isExpanded && exercise.sets.isEmpty {
                HStack {
                    Text("Нет подходов")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: { showingAddSet = true }) {
                        Text("Добавить")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .transition(.opacity)
            }
        }
        .sheet(isPresented: $showingAddSet) {
            AddSetView(exercise: exercise, workout: workout, dataManager: dataManager)
        }
    }
    
    // Функция дублирования упражнения
    private func duplicateExercise() {
        if let workoutIndex = dataManager.workouts.firstIndex(where: { $0.id == workout.id }),
           let exerciseIndex = dataManager.workouts[workoutIndex].exercises.firstIndex(where: { $0.id == exercise.id }) {
            
            let originalExercise = dataManager.workouts[workoutIndex].exercises[exerciseIndex]
            
            // Создаем копию упражнения с новым ID и названием + " копия"
            let duplicatedExercise = Exercise(
                id: UUID(),
                name: originalExercise.name + " (копия)",
                sets: originalExercise.sets.map { set in
                    WorkoutSet(
                        id: UUID(),
                        weight: set.weight,
                        repetitions: set.repetitions,
                        isCompleted: false // Сбрасываем статус выполнения
                    )
                },
                notes: originalExercise.notes
            )
            
            // Вставляем после текущего упражнения
            dataManager.workouts[workoutIndex].exercises.insert(duplicatedExercise, at: exerciseIndex + 1)
            dataManager.saveData()
        }
    }
}

// Строка подхода
struct SetRow: View {
    let set: WorkoutSet
    let setIndex: Int
    let exercise: Exercise
    let workout: Workout
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        HStack {
            // Номер подхода
            Text("\(setIndex + 1)")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 24)
            
            // Кнопка выполнения
            Button(action: {
                dataManager.toggleSet(set, in: exercise, workout: workout)
            }) {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(set.isCompleted ? .green : .gray)
                    .font(.title3)
            }
            
            // Вес и повторения
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
            
            // Кнопка удаления подхода
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
    
    // Удаление подхода
    private func deleteSet() {
        if let workoutIndex = dataManager.workouts.firstIndex(where: { $0.id == workout.id }),
           let exerciseIndex = dataManager.workouts[workoutIndex].exercises.firstIndex(where: { $0.id == exercise.id }),
           let setIndex = dataManager.workouts[workoutIndex].exercises[exerciseIndex].sets.firstIndex(where: { $0.id == set.id }) {
            dataManager.workouts[workoutIndex].exercises[exerciseIndex].sets.remove(at: setIndex)
            dataManager.saveData()
        }
    }
}

// Редактор заметок
struct NotesEditorView: View {
    @Binding var notes: String
    let workout: Workout
    @ObservedObject var dataManager: DataManager
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $notes)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding()
            }
            .navigationTitle("Заметки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        if let index = dataManager.workouts.firstIndex(where: { $0.id == workout.id }) {
                            dataManager.workouts[index].notes = notes
                            dataManager.saveData()
                        }
                        isPresented = false
                    }
                    .bold()
                }
            }
        }
    }
}
