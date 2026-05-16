import Testing
import Foundation
@testable import WallOut

@Suite("TimeSlot")
struct TimeSlotTests {
    @Test("Current slot resolves correctly for each hour band")
    func currentSlotByHour() {
        let calendar = Calendar.current
        let slots: [(Int, TimeSlot)] = [
            (5, .dawn), (7, .dawn),
            (8, .morning), (11, .morning),
            (12, .afternoon), (16, .afternoon),
            (17, .evening), (20, .evening),
            (21, .night), (0, .night), (4, .night),
        ]
        for (hour, expected) in slots {
            var components = calendar.dateComponents([.year, .month, .day], from: .now)
            components.hour = hour
            components.minute = 0
            guard let date = calendar.date(from: components) else { continue }
            #expect(TimeSlot.current(for: date, calendar: calendar) == expected,
                    "Expected \(expected) for hour \(hour)")
        }
    }

    @Test("Next transition interval is always positive")
    func transitionIntervalPositive() {
        for slot in TimeSlot.allCases {
            let interval = slot.timeUntilNextTransition()
            #expect(interval > 0)
        }
    }
}

@Suite("WallpaperContext")
struct WallpaperContextTests {
    @Test("Contexts with same values are equal")
    func equality() {
        let a = WallpaperContext(timeSlot: .morning, appearanceMode: .light)
        let b = WallpaperContext(timeSlot: .morning, appearanceMode: .light)
        #expect(a == b)
    }

    @Test("Contexts with different appearance modes are not equal")
    func inequality() {
        let a = WallpaperContext(timeSlot: .morning, appearanceMode: .light)
        let b = WallpaperContext(timeSlot: .morning, appearanceMode: .dark)
        #expect(a != b)
    }
}
