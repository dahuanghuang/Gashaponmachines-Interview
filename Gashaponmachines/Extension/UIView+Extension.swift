import UIKit.UIView
import SnapKit

extension UIView {

    public var width: CGFloat {
        get { return self.frame.size.width }
        set { self.frame.size.width = newValue }
    }

    public var height: CGFloat {
        get { return self.frame.size.height }
        set { self.frame.size.height = newValue }
    }

    public var top: CGFloat {
        get { return self.frame.origin.y }
        set { self.frame.origin.y = newValue }
    }
    public var right: CGFloat {
        get { return self.frame.origin.x + self.width }
        set { self.frame.origin.x = newValue - self.width }
    }
    public var bottom: CGFloat {
        get { return self.frame.origin.y + self.height }
        set { self.frame.origin.y = newValue - self.height }
    }
    public var left: CGFloat {
        get { return self.frame.origin.x }
        set { self.frame.origin.x = newValue }
    }

    public var centerX: CGFloat {
        get { return self.center.x }
        set { self.center = CGPoint(x: newValue, y: self.centerY) }
    }
    public var centerY: CGFloat {
        get { return self.center.y }
        set { self.center = CGPoint(x: self.centerX, y: newValue) }
    }

    public var origin: CGPoint {
        set { self.frame.origin = newValue }
        get { return self.frame.origin }
    }
    public var size: CGSize {
        set { self.frame.size = newValue }
        get { return self.frame.size }
    }
}

extension UIView {

    static func withBackgroundColor(color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        return view
    }

    static func seperatorLine(_ lineColor: UIColor = UIColor.qu_separatorLine) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.qu_separatorLine
        return view
    }

    func addBottomSeperatorLine() {
        let seperatorLine = UIView.seperatorLine()
        seperatorLine.backgroundColor = UIColor.qu_separatorLine
        self.addSubview(seperatorLine)
        seperatorLine.snp.makeConstraints { make in
            make.left.bottom.right.equalTo(self)
            make.height.equalTo(0.5)
        }
    }
}

extension UITableViewCell {

    func addSeperatorLine() {
        let seperatorLine = UIView.seperatorLine()
        seperatorLine.backgroundColor = UIColor.qu_separatorLine
        self.contentView.addSubview(seperatorLine)
        seperatorLine.snp.makeConstraints { make in
            make.left.bottom.right.equalTo(self.contentView)
            make.height.equalTo(0.5)
        }
    }
}

// MARK: - 为 UIView 特定一个角添加圆角
extension UIView {

    /// 添加圆角(Frame布局用)
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }

    /// 添加圆角(Frame布局用)
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat, fillColor: UIColor) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.fillColor = self.backgroundColor?.cgColor
        self.layer.mask = mask
    }

    /// 添加圆角(自动布局)
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat, bounds: CGRect) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }

    /// 添加圆角(自动布局)
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat, fillColor: UIColor, bounds: CGRect) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.fillColor = self.backgroundColor?.cgColor
        self.layer.mask = mask
    }
}

extension UIView {
    public static func withBackgounrdColor(_ color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        return view
    }
}

extension UIView {
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
}

// MARK: - 获取指定的 id
extension UIView {
    public static var defaultReusableId: String {
        return self.description()
            .components(separatedBy: ".")
            .dropFirst()
            .joined(separator: ".")
    }
}

extension UIView {
    var safeArea: ConstraintBasicAttributesDSL {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.snp
        }
        return self.snp
    }
}

extension UIView {
    public func getViewController() -> UIViewController? {
        return UIView.getControllerFromView(view: self)
    }

    public static func getControllerFromView(view: UIView) -> UIViewController? {
        var responder: UIResponder = view
        while let res = responder.next {
            if res.isKind(of: UIViewController.self) {
                return res as? UIViewController
            }
            responder = res
        }
        return nil
    }
}

extension UIView {
    /// 自动计算视图的高度
    public static func autoLayoutHeight(with view: UIView, width: CGFloat) -> CGFloat {

        let constraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width)

        view.addConstraint(constraint)

        let size = UIView.layoutFittingExpandedSize
        let viewH = view.systemLayoutSizeFitting(size).height

        view.removeConstraint(constraint)

        return viewH
    }

    public static func autoLayoutHeight(with view: UIView) -> CGFloat {
        let size = UIView.layoutFittingExpandedSize
        let viewH = view.systemLayoutSizeFitting(size).height
        return viewH
    }
}
