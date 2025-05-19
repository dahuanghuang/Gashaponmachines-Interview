import Foundation

extension Dictionary {

    static func + <K, V>(left: [K: V], right: [K: V]?) -> [K: V] {
        guard let right = right else { return left }
        return left.reduce(right) {
            var new = $0 as [K: V]
            new.updateValue($1.1, forKey: $1.0)
            return new
        }
    }
}
