import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @State private var showingCustomAlert = false
    @State private var selectedDate = Date()
    @State private var currentWeekOffset = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    // Состояние для чата
    @State private var showingChat = false
    
    // Состояния для редактирования тренировки
    @State private var showingEditAlert = false
    @State private var editingWorkout: Workout?
    
    // Форматтер для месяца
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()
    
    // Получаем дни текущей недели
    var weekDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let weekStart = calendar.date(byAdding: .day, value: currentWeekOffset * 7, to: startOfWeek)!
        
        return (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: weekStart)
        }
    }
    
    // Получаем следующую неделю
    var nextWeekDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let weekStart = calendar.date(byAdding: .day, value: (currentWeekOffset + 1) * 7, to: startOfWeek)!
        
        return (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: weekStart)
        }
    }
    
    // Получаем предыдущую неделю
    var previousWeekDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let weekStart = calendar.date(byAdding: .day, value: (currentWeekOffset - 1) * 7, to: startOfWeek)!
        
        return (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: weekStart)
        }
    }
    
    // Функция для перехода к следующему дню
    private func goToNextDay() {
        let calendar = Calendar.current
        if let nextDate = calendar.date(byAdding: .day, value: 1, to: selectedDate) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedDate = nextDate
                
                // Проверяем, нужно ли обновить неделю
                if !weekDays.contains(where: { calendar.isDate($0, inSameDayAs: nextDate) }) {
                    if nextDate > weekDays.last ?? Date() {
                        currentWeekOffset += 1
                    }
                }
            }
        }
    }
    
    // Функция для перехода к предыдущему дню
    private func goToPreviousDay() {
        let calendar = Calendar.current
        if let previousDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedDate = previousDate
                
                // Проверяем, нужно ли обновить неделю
                if !weekDays.contains(where: { calendar.isDate($0, inSameDayAs: previousDate) }) {
                    if previousDate < weekDays.first ?? Date() {
                        currentWeekOffset -= 1
                    }
                }
            }
        }
    }
    
    // Тренировки для выбранного дня
    var workoutsForSelectedDay: [Workout] {
        let calendar = Calendar.current
        return dataManager.workouts.filter { workout in
            calendar.isDate(workout.date, inSameDayAs: selectedDate)
        }
    }
    
    // Подсчет общего количества тренировок за день
    private var totalWorkoutsForDay: Int {
        workoutsForSelectedDay.count
    }
    
    // Подсчет общего количества упражнений за день
    private var totalExercisesForDay: Int {
        workoutsForSelectedDay.reduce(0) { $0 + $1.exercises.count }
    }
    
    // Подсчет общего количества подходов за день
    private var totalSetsForDay: Int {
        workoutsForSelectedDay.reduce(0) { $0 + $1.exercises.reduce(0) { $0 + $1.sets.count } }
    }
    
    // Подсчет общего количества повторений за день
    private var totalRepsForDay: Int {
        workoutsForSelectedDay.reduce(0) { $0 + $1.exercises.reduce(0) { $0 + $1.sets.reduce(0) { $0 + $1.repetitions } } }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Шапка с месяцем
                Text(monthFormatter.string(from: weekDays[3]).capitalized)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                
                // Календарь с эффектом барабана
                WeekCarouselView(
                    currentWeekDays: weekDays,
                    nextWeekDays: nextWeekDays,
                    previousWeekDays: previousWeekDays,
                    selectedDate: $selectedDate,
                    hasWorkout: hasWorkout,
                    dragOffset: $dragOffset,
                    isDragging: $isDragging,
                    onSwipeComplete: { direction in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            if direction == .left {
                                currentWeekOffset += 1
                            } else if direction == .right {
                                currentWeekOffset -= 1
                            }
                            dragOffset = 0
                        }
                    }
                )
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.top, 8)
                
                // Основной контент с поддержкой свайпов
                ZStack {
                    if workoutsForSelectedDay.isEmpty {
                        EmptyStateView()
                    } else {
                        VStack(spacing: 0) {
                            // Плашка с итогами дня
                            summaryCardSection
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            
                            // Список тренировок
                            WorkoutListView(
                                workouts: workoutsForSelectedDay,
                                dataManager: dataManager,
                                onEdit: { workout in
                                    editingWorkout = workout
                                    showingEditAlert = true
                                },
                                deleteWorkout: deleteWorkout
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { value in
                            let horizontalAmount = value.translation.width
                            let verticalAmount = value.translation.height
                            
                            if abs(horizontalAmount) > abs(verticalAmount) {
                                if horizontalAmount < -50 {
                                    // Свайп влево - следующий день
                                    goToNextDay()
                                } else if horizontalAmount > 50 {
                                    // Свайп вправо - предыдущий день
                                    goToPreviousDay()
                                }
                            }
                        }
                )
            }
            .navigationTitle("Мои тренировки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Левая кнопка - чат
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingChat = true }) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .purple],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "message.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCustomAlert = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // Кастомный алерт для добавления
            .overlay {
                if showingCustomAlert {
                    CustomAlertView(
                        isPresented: $showingCustomAlert,
                        onSave: { name in
                            dataManager.addWorkout(name: name)
                        }
                    )
                }
            }
            // Кастомный алерт для редактирования
            .overlay {
                if showingEditAlert, let workout = editingWorkout {
                    EditWorkoutAlertView(
                        isPresented: $showingEditAlert,
                        originalName: workout.name,
                        onSave: { newName in
                            updateWorkoutName(workout, newName: newName)
                        }
                    )
                }
            }
            // 👇 ДОБАВЬ ЭТОТ КОД 👇
            .sheet(isPresented: $showingChat) {
                ChatView(dataManager: dataManager)
            }
        }
    }
    
    // Карточка с итогами дня
    private var summaryCardSection: some View {
        VStack(spacing: 16) {
            // Основная информация
            HStack {
                // Иконка-штанга слева
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    Image(systemName: "dumbbell.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Сегодняшние итоги")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(totalWorkoutsForDay)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(wordEnding(count: totalWorkoutsForDay, words: ["тренировка", "тренировки", "тренировок"]))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Статистика справа
                VStack(alignment: .trailing, spacing: 6) {
                    Text("упражнений")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(totalExercisesForDay)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.caption)
                            .foregroundColor(.blue.opacity(0.7))
                    }
                }
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Детальная статистика
            HStack {
                // Подходы
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.1))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "arrow.counterclockwise")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(totalSetsForDay)")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("подходов")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Повторения
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "repeat")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(totalRepsForDay)")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("повторений")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Общий вес (если есть)
                if totalWeightForDay > 0 {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.purple.opacity(0.1))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "scalemass")
                                .font(.subheadline)
                                .foregroundColor(.purple)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(totalWeightForDay)")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("кг")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding()
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
    
    // Подсчет общего веса за день
    private var totalWeightForDay: Int {
        let total = workoutsForSelectedDay.reduce(0) { $0 + $1.exercises.reduce(0) { $0 + $1.sets.reduce(0) { $0 + $1.weight * Double($1.repetitions) } } }
        return Int(total)
    }
    
    // Функция для склонения слов
    private func wordEnding(count: Int, words: [String]) -> String {
        let preLastDigit = count % 100 / 10
        if preLastDigit == 1 {
            return words[2]
        }
        
        switch count % 10 {
        case 1: return words[0]
        case 2...4: return words[1]
        default: return words[2]
        }
    }
    
    // Проверка, есть ли тренировка в этот день
    private func hasWorkout(on date: Date) -> Bool {
        let calendar = Calendar.current
        return dataManager.workouts.contains { workout in
            calendar.isDate(workout.date, inSameDayAs: date)
        }
    }
    
    private func deleteWorkout(_ workout: Workout) {
        if let index = dataManager.workouts.firstIndex(where: { $0.id == workout.id }) {
            dataManager.workouts.remove(at: index)
            dataManager.saveData()
        }
    }
    
    private func updateWorkoutName(_ workout: Workout, newName: String) {
        if let index = dataManager.workouts.firstIndex(where: { $0.id == workout.id }) {
            dataManager.workouts[index].name = newName
            dataManager.saveData()
        }
    }
}
