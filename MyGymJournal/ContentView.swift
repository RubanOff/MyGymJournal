import SwiftUI

enum DragDirection {
    case none, left, right
}

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @State private var showingCustomAlert = false
    @State private var selectedDate = Date()
    @State private var currentWeekOffset = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
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
    
    // Тренировки для выбранного дня
    var workoutsForSelectedDay: [Workout] {
        let calendar = Calendar.current
        return dataManager.workouts.filter { workout in
            calendar.isDate(workout.date, inSameDayAs: selectedDate)
        }
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
                
                // Список тренировок для выбранного дня
                if workoutsForSelectedDay.isEmpty {
                    EmptyStateView()
                } else {
                    WorkoutListView(
                        workouts: workoutsForSelectedDay,
                        dataManager: dataManager,
                        deleteWorkout: deleteWorkout
                    )
                }
            }
            .navigationTitle("Мои тренировки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCustomAlert = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // Кастомный алерт
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
}


// Карусель с эффектом барабана
struct WeekCarouselView: View {
    let currentWeekDays: [Date]
    let nextWeekDays: [Date]
    let previousWeekDays: [Date]
    @Binding var selectedDate: Date
    let hasWorkout: (Date) -> Bool
    @Binding var dragOffset: CGFloat
    @Binding var isDragging: Bool
    let onSwipeComplete: (DragDirection) -> Void
    
    @State private var dragDirection: DragDirection = .none
    
    var body: some View {
        GeometryReader { geometry in
            let dayWidth = geometry.size.width / 7
            
            ZStack {
                // Предыдущая неделя (слева)
                if dragOffset > 0 {
                    WeekRowView(
                        weekDays: previousWeekDays,
                        selectedDate: $selectedDate,
                        hasWorkout: hasWorkout,
                        dayWidth: dayWidth,
                        offset: dragOffset - geometry.size.width
                    )
                }
                
                // Текущая неделя (центр)
                WeekRowView(
                    weekDays: currentWeekDays,
                    selectedDate: $selectedDate,
                    hasWorkout: hasWorkout,
                    dayWidth: dayWidth,
                    offset: dragOffset
                )
                .zIndex(1)
                
                // Следующая неделя (справа)
                if dragOffset < 0 {
                    WeekRowView(
                        weekDays: nextWeekDays,
                        selectedDate: $selectedDate,
                        hasWorkout: hasWorkout,
                        dayWidth: dayWidth,
                        offset: dragOffset + geometry.size.width
                    )
                }
            }
            .frame(width: geometry.size.width, height: 80)
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { value in
                        withAnimation(.interactiveSpring()) {
                            dragOffset = value.translation.width
                            isDragging = true
                            
                            if value.translation.width > 0 {
                                dragDirection = .right
                            } else if value.translation.width < 0 {
                                dragDirection = .left
                            }
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            let threshold = geometry.size.width / 3
                            
                            if value.translation.width < -threshold {
                                // Свайп влево - следующая неделя
                                dragOffset = -geometry.size.width
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    onSwipeComplete(.left)
                                    isDragging = false
                                }
                            } else if value.translation.width > threshold {
                                // Свайп вправо - предыдущая неделя
                                dragOffset = geometry.size.width
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    onSwipeComplete(.right)
                                    isDragging = false
                                }
                            } else {
                                // Возвращаем на место
                                dragOffset = 0
                                isDragging = false
                            }
                        }
                    }
            )
        }
    }
}

// Ряд с днями недели
struct WeekRowView: View {
    let weekDays: [Date]
    @Binding var selectedDate: Date
    let hasWorkout: (Date) -> Bool
    let dayWidth: CGFloat
    let offset: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(weekDays.enumerated()), id: \.element) { index, date in
                DayCell(
                    date: date,
                    isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                    isToday: Calendar.current.isDateInToday(date),
                    hasWorkout: hasWorkout(date),
                    width: dayWidth
                )
                .onTapGesture {
                    withAnimation {
                        selectedDate = date
                    }
                }
            }
        }
        .offset(x: offset)
    }
}

// Ячейка дня с фиксированной шириной
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasWorkout: Bool
    let width: CGFloat
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d"
        return formatter
    }()
    
    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "E"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 6) {
            // День недели (Пн, Вт и т.д.)
            Text(weekdayFormatter.string(from: date).uppercased())
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : (isToday ? .blue : .gray))
            
            // Число
            Text(dateFormatter.string(from: date))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
            
            // Индикатор тренировки
            if hasWorkout {
                Circle()
                    .fill(isSelected ? .white : .green)
                    .frame(width: 6, height: 6)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(width: width, height: 70)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue : Color.clear)
                .opacity(isSelected ? 0.8 : (isToday ? 0.1 : 0))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isToday ? Color.blue : Color.clear, lineWidth: 1)
        )
    }
}

// Пустое состояние
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "dumbbell")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("Нет тренировок")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Нажмите + чтобы добавить")
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Список тренировок
struct WorkoutListView: View {
    let workouts: [Workout]
    let dataManager: DataManager
    let deleteWorkout: (Workout) -> Void
    
    var body: some View {
        List {
            ForEach(workouts) { workout in
                NavigationLink {
                    WorkoutDetailView(workout: workout, dataManager: dataManager)
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        // Название тренировки
                        Text(workout.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        // Средняя строка: счетчик слева, время по центру
                        HStack {
                            // Синий счетчик упражнений слева
                            Label("\(workout.exercises.count) упражнений", systemImage: "figure.strengthtraining.traditional")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                            
                            Spacer()
                            
                            // Время по центру
                            Text(workout.formattedTime)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            // Зеленая заметка справа (если есть)
                            if !workout.notes.isEmpty {
                                Label("Заметка", systemImage: "note.text")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(8)
                            } else {
                                // Невидимый заполнитель для баланса, если заметки нет
                                Color.clear
                                    .frame(width: 1, height: 1)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .contextMenu {
                    Button(role: .destructive) {
                        deleteWorkout(workout)
                    } label: {
                        Label("Удалить тренировку", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}
