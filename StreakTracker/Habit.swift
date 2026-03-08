import Foundation
import SwiftData

@Model
final class Habit: Identifiable {
    var id: UUID
    var name: String
    var createdAt: Date
    var completionDates: [Date]

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = .now,
        completionDates: [Date] = []
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.completionDates = completionDates
    }

    var isCompletedToday: Bool {
        completionDates.contains { Calendar.current.isDateInToday($0) }
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        let uniqueDays = Set(completionDates.map { calendar.startOfDay(for: $0) })

        guard let latest = uniqueDays.max() else { return 0 }

        guard calendar.isDateInToday(latest) || calendar.isDateInYesterday(latest) else {
            return 0
        }

        var streak = 0
        var cursor = latest

        while uniqueDays.contains(cursor) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previousDay
        }

        return streak
    }

    func markCompletedTodayIfNeeded() {
        guard !isCompletedToday else { return }
        completionDates.append(.now)
    }
}
