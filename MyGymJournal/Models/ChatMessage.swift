import Foundation

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp = Date()
    
    // Для совместимости с JSON
    enum CodingKeys: String, CodingKey {
        case text, isUser, timestamp
    }
}
