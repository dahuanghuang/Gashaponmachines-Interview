import UIKit
import CoreGraphics

public func image(named name: String,
                  inBundle bundle: Bundle = AppEnvironment.current.mainBundle,
                  compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {

    return UIImage(named: name, in: Bundle(identifier: bundle.bundleIdentifier!), compatibleWith: traitCollection)
}

extension UIImage {

    public func withCapInset(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) -> UIImage {
        return self.resizableImage(withCapInsets: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right))
    }
}

extension UIImage {
    func image(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

//
extension UIImage {
    static func makeRoundedImage(image: UIImage, radius: CGFloat) -> UIImage? {
        let imageLayer = CALayer()
        imageLayer.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        imageLayer.contents = image.cgImage
        imageLayer.masksToBounds = true
        imageLayer.cornerRadius = radius
        UIGraphicsBeginImageContext(image.size)
        imageLayer.render(in: UIGraphicsGetCurrentContext()!)
        let rounderImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rounderImage
    }
}

// MARK: - 高效画圆角
extension UIImageView {
    func ss_addCorner(radius: CGFloat) {
        self.image = self.image?.ss_drawRectWithRoundedCorner(radius: radius, self.bounds.size)
    }
}

// 将当前的view截图下来
extension UIImage {

    /// 截屏
    ///
    /// - Parameter view: 需要截取的View
    convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}

extension UIImage {
    static func cropImage(image: UIImage, cropRect: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(cropRect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()

        context?.translateBy(x: 0.0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height), byTiling: false)
        context?.clip(to: [cropRect])

        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return croppedImage!
    }
}

extension UIImage {
    func ss_drawRectWithRoundedCorner(radius: CGFloat, _ sizetoFit: CGSize) -> UIImage? {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: sizetoFit)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)

        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.allCorners,
                                cornerRadii: CGSize(width: radius, height: radius)).cgPath
        UIGraphicsGetCurrentContext()?.addPath(path)
        UIGraphicsGetCurrentContext()?.clip()
        self.draw(in: rect)
        UIGraphicsGetCurrentContext()?.drawPath(using: .fillStroke)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return output
    }
}

extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
