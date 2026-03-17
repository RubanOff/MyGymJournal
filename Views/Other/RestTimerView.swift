import SwiftUI

struct RestTimerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var timeRemaining: Int
    @State private var timerIsRunning = false
    @State private var showingTimePicker = false
    @State private var selectedMinutes = 1
    @State private var selectedSeconds = 30
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Сохраняем настройки времени
    @AppStorage("restMinutes") private var savedMinutes = 1
    @AppStorage("restSeconds") private var savedSeconds = 30
    
    init() {
        // Сначала читаем из UserDefaults напрямую
        let minutes = Int(UserDefaults.standard.integer(forKey: "restMinutes"))
        let seconds = Int(UserDefaults.standard.integer(forKey: "restSeconds"))
        
        // Инициализируем состояния
        _selectedMinutes = State(initialValue: minutes > 0 ? minutes : 1)
        _selectedSeconds = State(initialValue: seconds > 0 ? seconds : 30)
        
        // Теперь можно использовать значения для timeRemaining
        let totalSeconds = (minutes > 0 ? minutes : 1) * 60 + (seconds > 0 ? seconds : 30)
        _timeRemaining = State(initialValue: totalSeconds)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Таймер отдыха")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Круговой прогресс
                ZStack {
                    Circle()
                        .stroke(lineWidth: 15)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(timeRemaining) / CGFloat((selectedMinutes * 60) + selectedSeconds))
                        .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                        .foregroundColor(timerColor)
                        .rotationEffect(Angle(degrees: -90))
                    
                    VStack {
                        Text("\(timeString(from: timeRemaining))")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(timerColor)
                        
                        Text("осталось")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 250, height: 250)
                .padding()
                
                // Кнопки управления
                HStack(spacing: 30) {
                    // Кнопка сброса
                    Button(action: resetTimer) {
                        VStack {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.title2)
                            Text("Сброс")
                                .font(.caption)
                        }
                        .frame(width: 70, height: 70)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                    }
                    
                    // Кнопка старт/пауза
                    Button(action: { timerIsRunning.toggle() }) {
                        VStack {
                            Image(systemName: timerIsRunning ? "pause.fill" : "play.fill")
                                .font(.title2)
                            Text(timerIsRunning ? "Пауза" : "Старт")
                                .font(.caption)
                        }
                        .frame(width: 70, height: 70)
                        .background(timerIsRunning ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                        .cornerRadius(15)
                    }
                    
                    // Кнопка настройки времени
                    Button(action: { showingTimePicker = true }) {
                        VStack {
                            Image(systemName: "gear")
                                .font(.title2)
                            Text("Настройки")
                                .font(.caption)
                        }
                        .frame(width: 70, height: 70)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(15)
                    }
                }
                
                // Отображение текущего времени
                Text("\(selectedMinutes) мин \(selectedSeconds) сек")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.top)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            // Окно настройки времени
            .sheet(isPresented: $showingTimePicker) {
                TimePickerView(selectedMinutes: $selectedMinutes, selectedSeconds: $selectedSeconds) {
                    saveTimeSettings()
                }
            }
        }
        .onReceive(timer) { _ in
            if timerIsRunning && timeRemaining > 0 {
                timeRemaining -= 1
            }
            if timeRemaining == 0 {
                timerIsRunning = false
                // Вибрация когда таймер закончился
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }
    }
    
    // Цвет таймера в зависимости от оставшегося времени
    var timerColor: Color {
        let totalTime = (selectedMinutes * 60) + selectedSeconds
        let percentage = Double(timeRemaining) / Double(totalTime)
        
        if percentage > 0.6 {
            return .green
        } else if percentage > 0.3 {
            return .orange
        } else {
            return .red
        }
    }
    
    // Форматирование времени в минуты:секунды
    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    // Сброс таймера
    func resetTimer() {
        timeRemaining = (selectedMinutes * 60) + selectedSeconds
        timerIsRunning = false
    }
    
    // Сохранение настроек времени
    func saveTimeSettings() {
        savedMinutes = selectedMinutes
        savedSeconds = selectedSeconds
        timeRemaining = (selectedMinutes * 60) + selectedSeconds
        timerIsRunning = false
    }
}

// Окно выбора времени
struct TimePickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedMinutes: Int
    @Binding var selectedSeconds: Int
    var onSave: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    // Выбор минут
                    Picker("Минуты", selection: $selectedMinutes) {
                        ForEach(0..<6) { minute in
                            Text("\(minute) мин").tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 120)
                    
                    Text(":")
                        .font(.largeTitle)
                    
                    // Выбор секунд
                    Picker("Секунды", selection: $selectedSeconds) {
                        ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { second in
                            Text("\(second) сек").tag(second)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 120)
                }
                .padding()
                
                Text("Всего: \((selectedMinutes * 60) + selectedSeconds) секунд")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .navigationTitle("Время отдыха")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        onSave()
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}
