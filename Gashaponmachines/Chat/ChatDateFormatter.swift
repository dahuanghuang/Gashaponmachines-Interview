import SwiftDate

class ChatDateFormatter {
    // MARK: - Properties

    public static let shared = ChatDateFormatter()

    private let formatter = DateFormatter()

    // MARK: - Initializer

    private init() {}

    public func string(from date: Date) -> String {
        return configureDateFormatter(for: date)
    }

    open func configureDateFormatter(for date: Date) -> String {
        formatter.locale = Locale(identifier: "zh_CN")

        switch true {
        case Calendar.current.isDateInToday(date):
            if let minsBet = (Date() - date).minute {
                if minsBet < 1 {
                    return "刚刚"
                } else if minsBet < 3 {
                    return "三分钟前"
                } else {
                    formatter.dateFormat = "a h:mm"
                }
            }
        case Calendar.current.isDateInYesterday(date):
            formatter.dateFormat = "'昨天'a h:mm"
        case Calendar.current.isDateInWeekend(date):
            if let daysBet = (Date() - date).day {
                if daysBet <= 2 && daysBet > 1 {
                    formatter.dateFormat = "'前天'a h:mm"
                } else {
                    formatter.dateFormat = "EEEE h:mm"
                }
            }
        case Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month):
            formatter.dateFormat = "M'月'd'日' a h:mm"
        default:
            formatter.dateFormat = "yyyy'年'M'月'd'日' a h:mm"
        }
        return formatter.string(from: date)
    }
}
