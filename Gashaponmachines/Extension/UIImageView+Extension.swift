import Kingfisher
import UIKit
import Foundation

private var lastURLKey: Void?

extension UIImageView {

    static func with(imageName: String) -> UIImageView {
        let iv = UIImageView(image: UIImage(named: imageName))
        return iv
    }
}

public extension UIImageView {

    var qu_webURL: URL? {
        return objc_getAssociatedObject(self, &lastURLKey) as? URL
    }

    fileprivate func qu_setWebURL(_ URL: Foundation.URL) {
        objc_setAssociatedObject(self, &lastURLKey, URL, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func cancelNetworkImageDownloadTask() {
        self.kf.cancelDownloadTask()
        self.image = nil
    }

    func qu_setImage(_ image: UIImage, imageURL: URL?) {
        dispatch_sync_safely_main_queue {
            guard imageURL == self.qu_webURL else {
                return
            }
            self.image = image
        }
    }

    typealias ImageProcessor = ((_ image: UIImage) -> UIImage)?
    
    func gas_setImageWithURL(_ URLStr: String?, placeHolder: Placeholder? = nil, completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) {
        guard let urlStr = URLStr else { return }
        
        guard let url = URL(string: urlStr) else {
            QLog.error("无效的 URL 地址 \(urlStr)")
            return
        }

        let options: KingfisherOptionsInfo = []
        
        self.kf.setImage(with: url, placeholder: placeHolder, options: options, progressBlock: nil, completionHandler: completionHandler)
    }
    
    func qu_setImageWithURL(_ URL: Foundation.URL, placeHolder: UIImage? = nil) {
        self.gas_setImageWithURL(URL.absoluteString, placeHolder: placeHolder)
    }

    /// 异步设置图片，注意这会下载缩略图
    ///
    /// - Parameters:
    ///   - URLStr: 图片地址
    ///   - placeHolder: 预加载占位图片
    ///   - targetSize: 图片大小
    ///   - roundingCorner: 是否圆角
//    func gas_setImageWithURL(_ URLStr: String?, placeHolder: Placeholder? = UIImage(named: "index_placeholder"), targetSize: CGFloat, roundingCorner: Bool = false, completionHandler: CompletionHandler? = nil) {
//        guard let URLStr = URLStr else { return }
//
//        let clean = URLStr.replacingOccurrences(of: "\"", with: "")
//        let scale = UIScreen.main.scale
//
//        let imageWidth = Int(targetSize * scale)
//        let imageHeigt = Int(targetSize * scale)
//        var finalStr = clean + "?imageMogr2/thumbnail/\(imageWidth)x\(imageHeigt)"
//
//        if !clean.hasPrefix("http") {
//            finalStr = Constants.kQINIU_CDN_BASE_URL + clean
//        }
//
//        guard let url = URL(string: finalStr) else {
//            QLog.error("无效的 URL 地址 \(finalStr)")
//            return
//        }
//
//        let resource = ImageResource(downloadURL: url)
//
//        var options: KingfisherOptionsInfo = []
//
//        // 如果是圆角
//        if roundingCorner {
//
//            let tarSize = CGSize(width: targetSize * scale, height: targetSize * scale)
//            let reszieProcessor = ResizingImageProcessor(referenceSize: tarSize, mode: .aspectFit)
//            let cornerRadius = targetSize
//            let roundCornerProcessor = RoundCornerImageProcessor(cornerRadius: cornerRadius, targetSize: tarSize, roundingCorners: .all, backgroundColor: nil)
//            options.append(.processor(reszieProcessor >> roundCornerProcessor))
//        }
//
//        self.kf.setImage(with: resource, placeholder: placeHolder, options: options, progressBlock: nil, completionHandler: completionHandler)
//    }

    /// 异步设置图片
    ///
    /// - Parameters:
    ///   - URLStr: 图片地址
    ///   - placeHolder: 预加载占位图片
    ///   - targetSize: 图片大小
    ///   - roundingCorner: 是否圆角
//    func gas_setImageWithURL(_ URLStr: String?, placeHolder: Placeholder? = nil, targetSize: CGSize, roundingCorner: Bool = false, completionHandler: CompletionHandler? = nil) {
//
//        guard let URLStr = URLStr else { return }
//        let scale = UIScreen.main.scale
//        let imageWidth = Int(targetSize.width * scale)
//        let imageHeigt = Int(targetSize.height * scale)
//
//        var finalStr = URLStr + "?imageMogr2/thumbnail/\(imageWidth)x\(imageHeigt)"
//
//        if !URLStr.hasPrefix("http") {
//            finalStr = Constants.kQINIU_CDN_BASE_URL + URLStr
//        }
//
//        guard let url = URL(string: finalStr) else { return }
//        let resource = ImageResource(downloadURL: url)
//
//        var options: KingfisherOptionsInfo = []
//
//        // 如果是圆角
//        if roundingCorner {
//
//            let tarSize = CGSize(width: targetSize.width * scale, height: targetSize.height * scale)
//            let reszieProcessor = ResizingImageProcessor(referenceSize: tarSize, mode: .aspectFit)
//            let cornerRadius = min(targetSize.width, targetSize.height)
//            let roundCornerProcessor = RoundCornerImageProcessor(cornerRadius: cornerRadius, targetSize: tarSize, roundingCorners: .all, backgroundColor: nil)
//            options.append(.processor(reszieProcessor >> roundCornerProcessor))
//        }
//
//        self.kf.setImage(with: resource, placeholder: placeHolder, options: options, progressBlock: nil, completionHandler: completionHandler)
//    }

    /// 异步设置图片，注意这会下载正常大小图片
    /// - Parameters:
    ///   - URL: 图片地址
    ///   - placeHolder: 预加载占位图片
    ///   - imageProcessor: 预处理
//    func qu_setImageWithURL(_ URL: Foundation.URL, placeHolder: UIImage? = nil, imageProcessor: ImageProcessor = nil) {
//
//        self.image = placeHolder
//
//        var urlString: String = URL.absoluteString
//
//        if urlString.isEmpty { return }
//        if !URL.absoluteString.hasPrefix("http") {
//            urlString = Constants.kQINIU_CDN_BASE_URL + URL.absoluteString
//        }
//
//        let url = NSURL(string: urlString)! as URL
//
//        let resource = ImageResource(downloadURL: url)
//
//        qu_setWebURL(resource.downloadURL)
//
//        KingfisherManager.shared.cache.retrieveImage(forKey: resource.cacheKey, options: nil) { (image, cacheType) in
//            if image != nil {
//                dispatch_sync_safely_main_queue {
//                    self.image = image
//                }
//            } else {
//                KingfisherManager.shared.downloader.downloadImage(with: url, options: nil, progressBlock: nil, completionHandler: { (image, error, imageURL, originalData) in
//
//                    if let e = error, e.code == KingfisherError.notModified.rawValue {
//
//                        KingfisherManager.shared.cache.retrieveImage(forKey: resource.cacheKey,
//                                                                     options: nil,
//                                                                     completionHandler: { (cacheImage, cacheType) in
//                            self.qu_setImage(cacheImage!, imageURL: imageURL!)
//                        })
//                        return
//                    }
//
//                    if var image = image, let originalData = originalData {
//
//                        if let processor = imageProcessor {
//                            image = processor(image)
//                        }
//
//                        KingfisherManager.shared.cache.store(image,
//                                                             original: originalData,
//                                                             forKey: resource.cacheKey,
//                                                             toDisk: true,
//                                                             completionHandler: nil)
//
//                        self.qu_setImage(image, imageURL: imageURL!)
//                    }
//                })
//            }
//        }
//    }
}

func qu_defaultCornerRadiusProcessor() -> ((_ image: UIImage) -> UIImage) {
    return { image -> UIImage in
        let roundedImage = image.applyCornerRadius()
        return roundedImage
    }
}

extension UIImage {

    func applyCornerRadius() -> UIImage {
        let w = self.size.width
        let h = self.size.height

    	let cornerRadius = w / 2

        var targetCornerRadius = cornerRadius
        if cornerRadius < 0 {
            targetCornerRadius = 0
        }
        if cornerRadius > min(w, h) {
            targetCornerRadius = min(w, h)
        }

        let imageFrame = CGRect(x: 0, y: 0, width: w, height: h)
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)

        UIBezierPath(roundedRect: imageFrame, cornerRadius: targetCornerRadius).addClip()
        self.draw(in: imageFrame)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
}
