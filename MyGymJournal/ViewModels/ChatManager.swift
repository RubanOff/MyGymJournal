import Foundation
import SwiftUI

@MainActor
class ChatManager: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    
    private var conversationHistory: [[String: String]] = []
    private let endpoint = "https://models.inference.ai.azure.com/chat/completions"
    // ⚡️ Вставь свой GitHub токен
    private var token: String {
        Secrets.githubToken
    }
    
    func sendMessage(_ text: String, workoutData: String) async -> String {
        isLoading = true
        defer { isLoading = false }
        
        // Добавляем сообщение пользователя в историю
        conversationHistory.append(["role": "user", "content": text])
        
        // Системный промпт с данными тренировок
        let systemPrompt = """
        Ты - профессиональный фитнес-тренер. Анализируй данные и давай советы.
        
        Данные тренировок пользователя за последние 30 дней:
        \(workoutData)
        
        Отвечай кратко (2-3 предложения), мотивирующе, на русском языке. Используй эмодзи 💪
        """
        
        var messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        messages.append(contentsOf: conversationHistory)
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 200
        ]
        
        guard let url = URL(string: endpoint) else {
            return "Ошибка соединения"
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            // Парсим ответ
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                // Проверяем наличие choices
                if let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    conversationHistory.append(["role": "assistant", "content": content])
                    return content
                    
                } else if let error = json["error"] as? [String: Any] {
                    return "Ошибка: \(error["message"] as? String ?? "неизвестная ошибка")"
                } else {
                    return "Неожиданный формат ответа от сервера"
                }
            } else {
                return "Не удалось распарсить ответ от сервера"
            }
            
        } catch {
            print("Error: \(error)")
            return "Ошибка сети: \(error.localizedDescription)"
        }
    }
    
    func clearHistory() {
        conversationHistory = []
        messages = []
    }
}
