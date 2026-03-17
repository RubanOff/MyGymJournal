import Foundation

class DataManager: ObservableObject {
    @Published var workouts: [Workout] = []
    
    private let saveKey = "SavedWorkouts"
    
    init() {
        loadData()
    }
    
    // Сохранение данных
    func saveData() {
        if let encoded = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    // Загрузка данных
    func loadData() {
        if let savedData = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Workout].self, from: savedData) {
            workouts = decoded
        }
    }
    
    // Добавление новой тренировки с названием и ДАТОЙ
    func addWorkout(name: String, date: Date) {  // 👈 Добавили параметр date
        let newWorkout = Workout(
            id: UUID(),
            name: name,
            date: date,  // 👈 Используем переданную дату
            exercises: [],
            notes: ""
        )
        workouts.append(newWorkout)
        saveData()
    }
    
    // Удаление тренировки
    func deleteWorkout(at indexSet: IndexSet) {
        workouts.remove(atOffsets: indexSet)
        saveData()
    }
    
    // Добавление упражнения в тренировку
    func addExercise(to workout: Workout, name: String) {
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            let newExercise = Exercise(
                id: UUID(),
                name: name,
                sets: [],
                notes: ""
            )
            workouts[index].exercises.append(newExercise)
            saveData()
        }
    }
    
    // Добавление подхода к упражнению
    func addSet(to exercise: Exercise, in workout: Workout, weight: Double, reps: Int) {
        if let workoutIndex = workouts.firstIndex(where: { $0.id == workout.id }),
           let exerciseIndex = workouts[workoutIndex].exercises.firstIndex(where: { $0.id == exercise.id }) {
            let newSet = WorkoutSet(
                id: UUID(),
                weight: weight,
                repetitions: reps,
                isCompleted: false
            )
            workouts[workoutIndex].exercises[exerciseIndex].sets.append(newSet)
            saveData()
        }
    }
    
    // Обновление статуса выполнения подхода
    func toggleSet(_ set: WorkoutSet, in exercise: Exercise, workout: Workout) {
        if let workoutIndex = workouts.firstIndex(where: { $0.id == workout.id }),
           let exerciseIndex = workouts[workoutIndex].exercises.firstIndex(where: { $0.id == exercise.id }),
           let setIndex = workouts[workoutIndex].exercises[exerciseIndex].sets.firstIndex(where: { $0.id == set.id }) {
            workouts[workoutIndex].exercises[exerciseIndex].sets[setIndex].isCompleted.toggle()
            saveData()
        }
    }
}
