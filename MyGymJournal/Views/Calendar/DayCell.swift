import SwiftUI

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
            Text(weekdayFormatter.string(from: date).uppercased())
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : (isToday ? .blue : .gray))
            
            Text(dateFormatter.string(from: date))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
            
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
