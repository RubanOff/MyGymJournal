import SwiftUI

struct EditWorkoutAlertView: View {
    @Binding var isPresented: Bool
    @State private var workoutName = ""
    var originalName: String
    var onSave: (String) -> Void
    
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 1.2
    @State private var blur: CGFloat = 10
    @State private var keyboardHeight: CGFloat = 0
    @State private var isKeyboardShowing = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            // Полупрозрачный фон
            Color.black
                .opacity(0.3 * opacity)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissAlert()
                }
            
            // Карточка алерта
            alertCard
                .offset(y: isKeyboardShowing ? -keyboardHeight * 0.25 : 0)
                .scaleEffect(scale)
                .opacity(opacity)
                .blur(radius: blur)
        }
        .ignoresSafeArea()
        .onAppear {
            workoutName = originalName
            opacity = 0
            scale = 1.2
            blur = 10
            
            withAnimation(.easeOut(duration: 0.35)) {
                opacity = 1
                blur = 0
            }
            
            withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 300, damping: 25, initialVelocity: 0)) {
                scale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isTextFieldFocused = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
               let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                withAnimation(.easeOut(duration: animationDuration)) {
                    keyboardHeight = keyboardFrame.height
                    isKeyboardShowing = true
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
            if let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                withAnimation(.easeOut(duration: animationDuration)) {
                    keyboardHeight = 0
                    isKeyboardShowing = false
                }
            }
        }
    }
    
    private var alertCard: some View {
        VStack(spacing: 24) {
            // Иконка
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 70, height: 70)
                
                Image(systemName: "pencil")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
            
            // Заголовки
            VStack(spacing: 8) {
                Text("Редактировать тренировку")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Введите новое название")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // Поле ввода
            VStack(alignment: .leading, spacing: 8) {
                Text("НАЗВАНИЕ")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .padding(.leading, 4)
                
                // Используем кастомный модификатор из другого файла
                TextField("", text: $workoutName)
                    .focused($isTextFieldFocused)
                    .modifier(PlaceholderModifier(
                        showPlaceholder: workoutName.isEmpty,
                        placeholder: "Например: Грудь + бицепс"
                    ))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6).opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isTextFieldFocused ? Color.blue : Color.clear, lineWidth: 2)
                            )
                    )
                    .foregroundColor(.white)
                    .autocapitalization(.sentences)
                    .submitLabel(.done)
                    .onSubmit {
                        if !workoutName.isEmpty && workoutName != originalName {
                            onSave(workoutName)
                            dismissAlert()
                        }
                    }
            }
            
            // Кнопки
            HStack(spacing: 16) {
                Button(action: dismissAlert) {
                    Text("Отмена")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.3))
                        )
                }
                
                Button(action: {
                    if !workoutName.isEmpty && workoutName != originalName {
                        onSave(workoutName)
                        dismissAlert()
                    }
                }) {
                    Text("Сохранить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Group {
                                if workoutName.isEmpty || workoutName == originalName {
                                    Color.blue.opacity(0.5)
                                } else {
                                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        )
                }
                .disabled(workoutName.isEmpty || workoutName == originalName)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(.systemGray6).opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(colors: [.blue.opacity(0.5), .purple.opacity(0.5)],
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal, 20)
    }
    
    private func dismissAlert() {
        withAnimation(.easeIn(duration: 0.2)) {
            opacity = 0
            scale = 0.8
            blur = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }
}
