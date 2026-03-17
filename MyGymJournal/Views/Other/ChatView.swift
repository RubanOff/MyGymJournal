import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var chatManager = ChatManager()
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            VStack {
                // Список сообщений
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                            }
                            
                            if chatManager.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .padding()
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                
                // Поле ввода
                HStack {
                    TextField("Спроси ИИ-тренера...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(chatManager.isLoading)
                    
                    Button(action: sendMessage) {
                        if chatManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(width: 40, height: 40)
                        } else {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .disabled(messageText.isEmpty || chatManager.isLoading)
                }
                .padding()
            }
            .navigationTitle("ИИ-тренер")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Очистить") {
                        messages = []
                        chatManager.clearHistory()
                    }
                }
            }
        }
    }
    
    private func sendMessage() {
        let userMessage = ChatMessage(text: messageText, isUser: true)
        messages.append(userMessage)
        
        let userText = messageText
        messageText = ""
        
        Task {
            let response = await chatManager.sendMessage(
                userText,
                workoutData: getWorkoutData()
            )
            
            await MainActor.run {
                let aiMessage = ChatMessage(text: response, isUser: false)
                messages.append(aiMessage)
            }
        }
    }
    
    private func getWorkoutData() -> String {
        let workouts = dataManager.workouts
        
        // Статистика за последние 30 дней
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date())!
        
        let recentWorkouts = workouts.filter { $0.date >= thirtyDaysAgo }
        
        let totalWorkouts = recentWorkouts.count
        let totalExercises = recentWorkouts.reduce(0) { $0 + $1.exercises.count }
        let totalSets = recentWorkouts.reduce(0) { $0 + $1.exercises.reduce(0) { $0 + $1.sets.count } }
        let totalWeight = recentWorkouts.reduce(0.0) { $0 + $1.exercises.reduce(0.0) { $0 + $1.sets.reduce(0.0) { $0 + $1.weight * Double($1.repetitions) } } }
        
        // Самые частые упражнения
        let allExercises = recentWorkouts.flatMap { $0.exercises.map { $0.name } }
        let frequency = Dictionary(grouping: allExercises, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { "\($0.key) (\($0.value) раз)" }
            .joined(separator: ", ")
        
        return """
        За последние 30 дней:
        - Тренировок: \(totalWorkouts)
        - Упражнений: \(totalExercises)
        - Подходов: \(totalSets)
        - Общий вес: \(Int(totalWeight)) кг
        - Любимые упражнения: \(frequency.isEmpty ? "нет данных" : frequency)
        """
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            Text(message.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    message.isUser ?
                    LinearGradient(colors: [.blue, .purple],
                                 startPoint: .topLeading,
                                 endPoint: .bottomTrailing) :
                    LinearGradient(colors: [Color(.systemGray5)],
                                 startPoint: .leading,
                                 endPoint: .trailing)
                )
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(18)
                .frame(maxWidth: 300, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}
