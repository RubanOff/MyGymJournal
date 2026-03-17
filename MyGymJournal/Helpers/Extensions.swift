import SwiftUI

// Расширение для placeholder (если нужно)
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// Расширение для DragDirection (если нужно вынести)
enum DragDirection {
    case none, left, right
}
