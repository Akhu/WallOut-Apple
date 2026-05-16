import Foundation

enum TimeSlot: String, CaseIterable, Sendable {
    case dawn      // 05:00–08:00
    case morning   // 08:00–12:00
    case afternoon // 12:00–17:00
    case evening   // 17:00–21:00
    case night     // 21:00–05:00

    static func current(for date: Date = .now, calendar: Calendar = .current) -> TimeSlot {
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 5..<8:   return .dawn
        case 8..<12:  return .morning
        case 12..<17: return .afternoon
        case 17..<21: return .evening
        default:      return .night
        }
    }

    var displayName: String {
        switch self {
        case .dawn:      return "Dawn"
        case .morning:   return "Morning"
        case .afternoon: return "Afternoon"
        case .evening:   return "Evening"
        case .night:     return "Night"
        }
    }

    /// The next hour at which the slot changes, used to schedule the next update.
    var nextTransitionHour: Int {
        switch self {
        case .dawn:      return 8
        case .morning:   return 12
        case .afternoon: return 17
        case .evening:   return 21
        case .night:     return 29 // 05:00 next day → 24+5
        }
    }

    func timeUntilNextTransition(from date: Date = .now, calendar: Calendar = .current) -> TimeInterval {
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        let targetHour = nextTransitionHour % 24
        let daysToAdd = nextTransitionHour >= 24 ? 1 : 0
        components.hour = targetHour
        components.minute = 0
        components.second = 0
        guard var target = calendar.date(from: components) else { return 3600 }
        if daysToAdd > 0 {
            target = calendar.date(byAdding: .day, value: 1, to: target) ?? target
        }
        let interval = target.timeIntervalSince(date)
        return max(interval, 60)
    }
}
