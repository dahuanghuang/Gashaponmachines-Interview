import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

extension String {
    func localized(withComment: String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: withComment)
    }
}

extension String {
    func isEmpty() -> Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
    }

    func isValidPhoneNumber() -> Bool {
        return self.count == 11 &&
            (self.starts(with: "13") ||
                self.starts(with: "14") ||
                self.starts(with: "15") ||
                self.starts(with: "17") ||
                self.starts(with: "18") ||
                self.starts(with: "16"))
    }
}

extension String {
    func toJSON() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                QLog.error(error.localizedDescription)
            }
        }
        return nil
    }
}

extension String {
    static func hourTimeStringFrom(second: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: second)
        let formatter = DateFormatter()
        if second / 3600 >= 1 {
            formatter.dateFormat = "HH:mm:ss"
        } else {
            formatter.dateFormat = "mm:ss"
        }
        return formatter.string(from: date)
    }
}

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}

extension String {
    static func dateNow() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "zh-Hans")
        let str = formatter.string(from: Date())
        return str
    }

    /// 时间戳转时间
    /// - Parameter timestamp: 13位时间戳
    /// - Returns: 时间(ex: 2020-09-09 12:24:36)
    static func time(timestamp: Double) -> String? {
        if let time = TimeInterval(exactly: timestamp/1000) {
            let date = Date(timeIntervalSince1970: time)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss:SSS"
            return dateFormatter.string(from: date).description
        }
        return nil
    }
}

extension String {
    /// 获取扭蛋过期的富文本
    mutating func getEggExpiredAttrString() -> NSMutableAttributedString {

        // 获取颜色
        let startIndex = self.firstIndex(of: "#")!
        let endIndex = self.index(startIndex, offsetBy: 6)
        let colorStr = String(self[startIndex...endIndex])

        // 获取文字
        for _ in 0...1 {
            let startIndex = self.firstIndex(of: "<")!
            let endIndex = self.firstIndex(of: ">")!
            self.replaceSubrange(startIndex...endIndex, with: ",")
        }
        let strings = self.components(separatedBy: ",")

        // 拼接
        let attrStrM = NSMutableAttributedString.init()
        for index in 0...strings.count-1 {
            let str = strings[index]
            let textColor = (index == 1 ? UIColor(hex: colorStr) : UIColor.qu_lightGray)!
            let attrStr = NSAttributedString.init(string: str, attributes: [.foregroundColor: textColor, .font: UIFont.withBoldPixel(20)])
            attrStrM.append(attrStr)
        }
        return attrStrM
    }

    func toExpiredDateString(_ fontPixel: CGFloat = 24, textColor: UIColor = .qu_lightGray, attributedColor: UIColor = .qu_orange) -> NSAttributedString {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let expireDate = dateFormatter.date(from: self)!
        let str = expireDate.offset(from: Date())
        let totalStr = "剩余 \(str) 自动换取蛋壳"
        let string = NSMutableAttributedString(string: totalStr, attributes: [
            NSAttributedString.Key.font: UIFont.withBoldPixel(fontPixel),
            NSAttributedString.Key.foregroundColor: textColor
            ])
        let range = totalStr.range(of: str)!
        let nsRange = NSRange(range, in: totalStr)
        string.addAttributes([NSAttributedString.Key.foregroundColor: attributedColor], range: nsRange)
        return string
    }
}

extension String {
    func removeWhitespaces() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
}

extension String {
    var md5: String? {
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }

        let hash = data.withUnsafeBytes { (bytes: UnsafePointer<Data>) -> [UInt8] in
            var hash: [UInt8] = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes, CC_LONG(data.count), &hash)
            return hash
        }

        return hash.map { String(format: "%02x", $0) }.joined()
    }

    static func random(length: Int) -> String {

        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
}

extension String {

    func heightWithString(fontSize: CGFloat, width: CGFloat) -> CGFloat {
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: fontSize)], context: nil)
        return rect.height
    }

    func widthWithString(fontSize: CGFloat, height: CGFloat) -> CGFloat {
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: fontSize)], context: nil)
        return rect.width
    }

    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }

    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }

    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }

    func requiredHeight(font: UIFont, maxWidth: CGFloat) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: maxWidth, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = self
        return label.frame.height
    }
}

extension String {
    func unicodeStr() -> String {
        let tempStr1 = self.replacingOccurrences(of: "\\u", with: "\\U")
        let tempStr2 = tempStr1.replacingOccurrences(of: "\"", with: "\\\"")
        let tempStr3 = "\"".appending(tempStr2).appending("\"")
        let tempData = tempStr3.data(using: String.Encoding.utf8)
        var returnStr: String = ""
        do {
            returnStr = try PropertyListSerialization.propertyList(from: tempData!, options: [.mutableContainers], format: nil) as! String
        } catch {
            QLog.error(error.localizedDescription)
        }
        return returnStr.replacingOccurrences(of: "\\r\\n", with: "\n")
    }
}

// 比较版本号
extension String {
    func ck_compare(with version: String) -> ComparisonResult {
        return compare(version, options: .numeric, range: nil, locale: nil)
    }

    func isNewer(than aVersionString: String) -> Bool {
        return ck_compare(with: aVersionString) == .orderedDescending
    }

    func isOlder(than aVersionString: String) -> Bool {
        return ck_compare(with: aVersionString) == .orderedAscending
    }

    func isSame(to aVersionString: String) -> Bool {
        return ck_compare(with: aVersionString) == .orderedSame
    }
}
