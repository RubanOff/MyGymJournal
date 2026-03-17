import SwiftUI

struct AddExerciseAlertView: View {
    @Binding var isPresented: Bool
    @State private var exerciseName = ""
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
                    .fill(LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 70, height: 70)
                
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
            
            // Заголовки
            VStack(spacing: 8) {
                Text("Новое упражнение")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Введите название упражнения")
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
                
                TextField("", text: $exerciseName)
                    .focused($isTextFieldFocused)
                    .overlay(
                        // Кастомный placeholder через overlay
                        Group {
                            if exerciseName.isEmpty {
                                HStack {
                                    Text("Например: Жим лежа")
                                        .foregroundColor(.gray.opacity(0.6))
                                        .padding(.leading, 16)
                                    Spacer()
                                }
                            }
                        }
                    )
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6).opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isTextFieldFocused ? Color.green : Color.clear, lineWidth: 2)
                            )
                    )
                    .foregroundColor(.white)
                    .autocapitalization(.sentences)
                    .submitLabel(.done)
                    .onSubmit {
                        if !exerciseName.isEmpty {
                            onSave(exerciseName)
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
                    if !exerciseName.isEmpty {
                        onSave(exerciseName)
                        dismissAlert()
                    }
                }) {
                    Text("Добавить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Group {
                                if exerciseName.isEmpty {
                                    Color.green.opacity(0.5)
                                } else {
                                    LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        )
                }
                .disabled(exerciseName.isEmpty)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(.systemGray6).opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(colors: [.green.opacity(0.5), .blue.opacity(0.5)],
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
