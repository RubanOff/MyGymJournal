import SwiftUI

struct WeekRowView: View {
    let weekDays: [Date]
    @Binding var selectedDate: Date
    let hasWorkout: (Date) -> Bool
    let dayWidth: CGFloat
    let offset: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(weekDays.enumerated()), id: \.element) { index, date in
                DayCell(
                    date: date,
                    isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                    isToday: Calendar.current.isDateInToday(date),
                    hasWorkout: hasWorkout(date),
                    width: dayWidth
                )
                .onTapGesture {
                    withAnimation {
                        selectedDate = date
                    }
                }
            }
        }
        .offset(x: offset)
    }
}
