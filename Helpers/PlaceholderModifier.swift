import SwiftUI

// Кастомный модификатор для placeholder
struct PlaceholderModifier: ViewModifier {
    var showPlaceholder: Bool
    var placeholder: String
    
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceholder {
                Text(placeholder)
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.leading, 4)
            }
            content
        }
    }
}
