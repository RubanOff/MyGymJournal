import SwiftUI

// Добавляем структуру WaveShape для фона
struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control1: CGPoint(x: rect.width * 0.25, y: rect.maxY - 50),
            control2: CGPoint(x: rect.width * 0.75, y: rect.midY - 30)
        )
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

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
            // 🔥 НОВЫЙ ФОН - как в Telegram (Вариант 5)
            .background(
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
            )
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
                            dataManager.addWorkout(name: name, date: selectedDate)
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
            // Чат
            .sheet(isPresented: $showingChat) {
                ChatView(dataManager: dataManager)
            }
        }
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
