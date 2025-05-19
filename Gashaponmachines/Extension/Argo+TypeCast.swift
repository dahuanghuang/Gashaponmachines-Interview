import Argo

/// Convert Int type into String on the fly.
/// See this thread for more info: https://github.com/thoughtbot/Argo/issues/457
///
/// - Parameter number:
/// - Returns:
func toString(number: Int) -> Decoded<String> {
    return .success(String(number))
}

/// Convert String type into Bool on the fly.
extension String {
    static func toBool(_ string: String?) -> Bool {
        if string == "1" {
            return true
        } else {
            return false
        }
    }

    static func toBool(_ string: String) -> Bool {
        if string == "1" {
            return true
        } else if string == "0" {
            return false
        } else {
            return false
        }
    }

    static func toInt(_ string: String) -> Int {
        return Int(string) ?? 0
    }

    static func toInt(_ string: String?) -> Int {
        return Int(string ?? "0") ?? 0
    }

    static func toFloat(_ string: String?) -> Float {
        return Float(string ?? "0.0") ?? 0.0
    }
}

extension Int {
    static func toString(_ int: Int) -> String {
        return "\(int)"
    }

    static func toString(_ int: Int?) -> String {
        if let intValue = int {
            return "\(intValue)"
        } else {
            return ""
        }
    }
}
