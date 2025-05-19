import UIKit
import Kingfisher

class ImageDownloadManager {
    static let shared = ImageDownloadManager()

    /// 顺序下载多个图片
    /// - Parameters:
    ///   - imageStrs: 图片URL
    ///   - completionHandler: 所有图片下载完成回调
    func downloadImages(imageStrs: [String], completionHandler: ((_ images: [UIImage]) -> Void)? = nil) {
        if imageStrs.isEmpty { return }

        var result = [Int: Any]()

        for (i, imageStr) in imageStrs.enumerated() {
            if imageStr.isEmpty { return }

            guard let url = URL(string: imageStr) else {
                QLog.debug("无效的图片URL地址 \(imageStr)")
                return
            }

            KingfisherManager.shared.downloader.downloadImage(with: url, options: [.fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: { completion in

                switch completion {
                case .success(let imgResult):
                    result[i] = imgResult.image
                case .failure(let e):
                    result[i] = e
                    QLog.debug("第\(i)张图片下载失败, error: \(e.localizedDescription)")
                }
                
                if result.count == imageStrs.count, let completion = completionHandler {
                    completion(self.getImagesFromResultDict(result))
                }
            })
        }
    }

    /// 取出图片数组
    func getImagesFromResultDict(_ result: [Int: Any]) -> [UIImage] {
        var images = [UIImage]()
        for i in 0..<result.count {
            if let img = result[i] as? UIImage {
                images.append(img)
            }
        }
        return images
    }
}
