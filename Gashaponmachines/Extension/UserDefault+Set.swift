import Foundation

// UserDefault is not support for storing set. FUCK!
extension UserDefaults {

    func setForKey(key: String) -> Set<String>? {
        let array = self.array(forKey: key) as? [String]
        if let arr = array {
            return Set(arr)
        } else {
            return nil
        }
    }

    func setSet(_ set: Set<String>?, for key: String) {
        if let s = set {
            self.set(Array(s), forKey: key)
        } else {
            self.set(nil, forKey: key)
        }
    }
}

extension UserDefaults {

    static let defaults = UserDefaults.standard

    static var lastAccessDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: "lastAccessDate") as? Date
        }
        set {
            guard let newValue = newValue else { return }
            guard let lastAccessDate = lastAccessDate else {
                UserDefaults.standard.set(newValue, forKey: "lastAccessDate")
                return
            }
            if !Calendar.current.isDateInToday(lastAccessDate) {
                QLog.debug("remove Persistent Domain")
                UserDefaults.reset()
            }
            UserDefaults.standard.set(newValue, forKey: "lastAccessDate")
        }
    }

    static func reset() {
//        UserDefaults.standard.remove
    }
}
