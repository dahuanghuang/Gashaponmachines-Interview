import UIKit.UIColor

extension UIColor {

    static func UIColorFromRGB(_ rgbValue: UInt, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }

    static func random() -> UIColor {
        return UIColor(hue: CGFloat(drand48()), saturation: 1, brightness: 1, alpha: 1)
    }

    func alpha(_ alpha: CGFloat) -> UIColor {
        return self.withAlphaComponent(alpha)
    }

    public convenience init?(hex: String) {
        self.init(hex: hex, alpha: 1.0)
    }

    public convenience init?(hex: String, alpha: CGFloat) {
        let r, g, b: CGFloat

        if hex.count < 6 || hex.count > 7 {
            QLog.error("输入颜色数值有误!")
            return nil
        }

        var start: String.Index!

        if hex.hasPrefix("#") {
            start = hex.index(hex.startIndex, offsetBy: 1)
        } else {
            start = hex.startIndex
        }

        let hexColor = String(hex[start...])

        if hexColor.count == 6 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                b = CGFloat((hexNumber & 0x0000ff) >> 0) / 255

                self.init(red: r, green: g, blue: b, alpha: alpha)
                return
            }
        }

        return nil
    }
}

extension UIColor {

    static let qu_darkBlue = UIColorFromRGB(0x1fa6cd)

    static let qu_cyanBlue = UIColorFromRGB(0xe4f9ff)

    static let compos_borderColor = UIColorFromRGB(0xc0f0fe)

//    static let compos_borderColor = UIColorFromRGB(0xc0f0fe)

    static let qu_darkGray = UIColorFromRGB(0x8a8a8a)

    static let qu_orange = UIColorFromRGB(0xffa336)

    static let qu_wrongRed = UIColorFromRGB(0xffdede)

    static let qu_green = UIColorFromRGB(0x56bf3d)

    static let qu_red = UIColorFromRGB(0xfd3957)

    static let viewBackgroundColor = UIColorFromRGB(0xf5f4f2)

    static let navigationBarColor = UIColorFromRGB(0xdc2d4e)

    static let introBgColor = UIColorFromRGB(0xbe1838)

    static let tabBarColor = UIColorFromRGB(0xf7f7f7)

    static let qu_yellow = UIColorFromRGB(0xffd712)

    static let qu_lightYellow = UIColorFromRGB(0xfef58f)

    static let qu_brown = UIColorFromRGB(0x4e331d)

    static let qu_lightBrown = UIColorFromRGB(0xc5930c)

    static let qu_separatorLine = UIColorFromRGB(0xececec)

    static let qu_black = UIColorFromRGB(0x3a3a3a)

    static let qu_disableText = UIColorFromRGB(0xcac8c6)

    static let qu_lightGray = UIColorFromRGB(0xbfbfbf)

    static let qu_lightBlue = UIColorFromRGB(0x7a9ac0)

    static let qu_appleHighlight = UIColorFromRGB(0xd9d9d9)

    static let qu_blue = UIColorFromRGB(0x559df3)

    static let textColor = UIColorFromRGB(0xffffff)

    static let flatButtonTextColor = UIColorFromRGB(0xce5200)

    static let lineColor = UIColorFromRGB(0xcccccc)

    static let qu_darkYellow = UIColorFromRGB(0xfc9602)

    static let qu_activityOrange = UIColorFromRGB(0xfba802)

    static let qu_cyanGreen = UIColorFromRGB(0x32cf9d)

    static let qu_popBackgroundColor = UIColor(white: 0, alpha: 0.6)

    static let qu_cornYellow = UIColorFromRGB(0xffee96)
    
    // MARK: - 新改版颜色
    /// 背景色
    static let new_backgroundColor = UIColorFromRGB(0xEFEFEF)
    
    /// 黄色
    static let new_yellow = UIColorFromRGB(0xFFDA60)
    
    /// 背景黄
    static let new_bgYellow = UIColorFromRGB(0xFFE682)
    
    /// 打折文字颜色
    static let new_discountColor = UIColorFromRGB(0xFF602E)
    
    /// 灰色(副标题)
    static let new_gray = UIColorFromRGB(0x797979)
    
    /// 中等灰色
    static let new_middleGray = UIColorFromRGB(0xA6A6A6)
    
    /// 浅灰色(子标题)
    static let new_lightGray = UIColorFromRGB(0xD2D2D2)
    
    /// 橘色
    static let new_orange = UIColorFromRGB(0xFF902B)
    
    /// 棕色
    static let new_brown = UIColorFromRGB(0xA67514)
    
    /// 绿色
    static let new_green = UIColorFromRGB(0x21BFA1)
    
}
