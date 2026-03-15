import Foundation

// Модель для подхода
struct WorkoutSet: Identifiable, Codable {
    var id = UUID()
    var weight: Double
    var repetitions: Int
    var isCompleted: Bool = false
}

// Модель для упражнения
struct Exercise: Identifiable, Codable {
    var id = UUID()
    var name: String
    var sets: [WorkoutSet]
    var notes: String = ""
}

// Модель для тренировки
struct Workout: Identifiable, Codable {
    var id = UUID()
    var name: String
    var date: Date
    var exercises: [Exercise]
    var notes: String = ""
    
    // Форматированное время для отображения справа
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
