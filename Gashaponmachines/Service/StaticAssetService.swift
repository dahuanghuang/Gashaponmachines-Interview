import Kingfisher
import ZIPFoundation

enum StaticAssetType: String, CaseIterable {

    // UIImage
    case indexRoof // 首页屋顶图
    case onePieceRoof // 元气赏页屋顶图
    case mallRoof // 商城页屋顶图
    case selfBackground // “我的”页面背景图
    case playSpinner // 扭蛋按钮【旋转】图片
    case playSpinnerDark // 扭蛋按钮【旋转】淡出图片
    case openScreenPicture  // 开屏图片

    // 新版游戏界面素材
    case newPlayButton
    case newPlayButtonDark

    // Zip
    case flashLightsLeft // 左跑马灯动画
    case flashLightsRight // 右跑马灯动画
    case playButton // 扭蛋按钮【旋转变换】动画 zip 包
    case playFlash // 扭蛋按钮【点击开始】动画 zip 包
}

//protocol StaticAssetUpdateable: class {
//    func updateAsset()
//}

/// 这个类主要管理后台配置的静态资源
class StaticAssetService: NSObject {

    static let openScreenUserDefaultKey = "com.gashaponmachines.staticasset.openscreenpicture"

    private var sessionConfig: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return config
    }

    private lazy var session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

    private let fm = FileManager.default

    subscript(key: StaticAssetType) -> Any? {
        return properties[key] ?? [:]
    }

//    weak var delegate: StaticAssetUpdateable?

//    private static let indexRoof = UIImage(named: "index_nav_bg")

    /// 获取开屏页(可能为空)
    class func getOpenScreenPicture() -> UIImage? {
//        if let storedKey = AppEnvironment.userDefault.value(forKey: StaticAssetService.openScreenUserDefaultKey) as? String {
//            return KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: storedKey)
//        }
        return nil
    }

    /// 默认的素材
    var properties: [StaticAssetType: Any?] = [
        StaticAssetType.indexRoof: UIImage(named: ""),
        StaticAssetType.onePieceRoof: UIImage(named: ""),
        StaticAssetType.mallRoof: UIImage(named: ""),
        StaticAssetType.selfBackground: nil,
        StaticAssetType.openScreenPicture: nil,
        StaticAssetType.flashLightsLeft: nil,
        StaticAssetType.flashLightsRight: nil,
        StaticAssetType.playButton: nil,
        StaticAssetType.playFlash: nil,
        StaticAssetType.newPlayButton: UIImage(named: "game_n_btn"),
        StaticAssetType.playSpinner: UIImage(named: "animateButton_19"),
        StaticAssetType.newPlayButtonDark: UIImage(named: "game_n_btn_fade"),
        StaticAssetType.playSpinnerDark: UIImage(named: "game_playing_idle")]
//    {
//        didSet {
//            if let img = properties[.indexRoof] as? UIImage, img != StaticAssetService.indexRoof {
//                self.delegate?.updateAsset()
//            }
//        }
//    }
    
    /// 资源
    var envelope: StaticAssetsEnvelope?

    static let shared = StaticAssetService()

    /// 下载资源
    func startDownloadTasks(by envelope: StaticAssetsEnvelope?) {

        guard let envelope = envelope else { return }

        StaticAssetType.allCases.forEach { type in
            if let value = envelope[type.rawValue] as? String, let url = URL(string: value) {
                cacheProcess(type: type, url: url)
            }

            // 开屏页特殊处理(为空时清空缓存)
            if envelope[StaticAssetType.openScreenPicture.rawValue] as? String == "" {
                self.removeOpenScreenPictureCacheKey()
            }
        }
    }

    /// 缓存处理
    func cacheProcess(type: StaticAssetType, url: URL) {
        switch type {
        case .indexRoof, .onePieceRoof, .mallRoof, .selfBackground, .playSpinner, .playSpinnerDark, .openScreenPicture, .newPlayButton, .newPlayButtonDark:
            cacheSingleImage(by: type, url: url)
        case .playButton, .playFlash, .flashLightsLeft, .flashLightsRight:
            cacheZipFile(by: type, url: url)
        }
    }

    private func isFileExist(at path: String) -> Bool {
        return fm.fileExists(atPath: path)
    }

    private func clearDocumentFolder(at path: String) {
        do {
            let filePaths = try fm.contentsOfDirectory(atPath: path)
            for filePath in filePaths {
                try fm.removeItem(atPath: path + "/" + filePath)
            }
        } catch {
            QLog.error("error clearing file : \(error)")
        }
    }

    private func cacheZipFile(by type: StaticAssetType, url: URL) {

        let nameOnly = url.absoluteURL.deletingPathExtension().lastPathComponent
        let filename = url.absoluteURL.lastPathComponent

        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let sourceURL = URL(fileURLWithPath: path).appendingPathComponent(filename)
        let destinationURL = URL(fileURLWithPath: path).appendingPathComponent(nameOnly)

        // uncomment it to clear Document folder
        // clearDocumentFolder(at: path)

        // existed
        if isFileExist(at: destinationURL.path) {
            self.properties[type] = destinationURL.appendingPathComponent("data.json")
            QLog.debug("\(destinationURL.path) existed")
        } else {
            self.session.dataTask(with: url) { [weak self] (data, response, error) in
                if let e = error {
                    QLog.error("Failure: \(e.localizedDescription)")
                    return
                }

                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    QLog.debug("Success: \(statusCode)")
                }

                do {
                    try data?.write(to: sourceURL)
                    self?.unzipFile(at: sourceURL, to: destinationURL)
                    self?.properties[type] = destinationURL.appendingPathComponent("data.json")
                } catch {
                    QLog.error("error writing file \(filename) : \(error)")
                }
            }.resume()
        }
    }

    /// 解压缩 zip 包
    ///
    /// - Parameters:
    ///   - sourceURL: zip 包位置
    ///   - destinationURL: 目标目录位置
    private func unzipFile(at sourceURL: URL, to destinationURL: URL) {
        do {
            try fm.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try fm.unzipItem(at: sourceURL, to: destinationURL)
        } catch {
            QLog.error("Extraction of ZIP archive failed with error:\(error)")
        }
    }

    /// 缓存图片素材
    ///
    /// - Parameters:
    ///   - type: 类型
    ///   - url: 素材地址
    private func cacheSingleImage(by type: StaticAssetType, url: URL) {

//        let resource = ImageResource(downloadURL: url)
//
//        KingfisherManager.shared.cache.retrieveImage(forKey: resource.cacheKey, options: nil, completionHandler: { [weak self] (cacheImage, cacheType) in
//
//            if let cacheImage = cacheImage {
//                self?.properties[type] = cacheImage
//
//                if type == .openScreenPicture {
//                    self?.saveOpenScreenPictureCacheKey(key: resource.cacheKey)
//                }
//
//            } else {
//                KingfisherManager.shared.downloader.downloadImage(with: url, options: nil, progressBlock: nil, completionHandler: { (image, error, imageURL, originalData) in
//                    if let e = error {
//                        QLog.error("KingfisherManager DOWNLOAD Error: \(e.localizedDescription)")
//                    }
//
//                    if let image = image, let originalData = originalData {
//                        KingfisherManager.shared.cache.store(image,
//                                                             original: originalData,
//                                                             forKey: resource.cacheKey,
//                                                             toDisk: true,
//                                                             completionHandler: nil)
//                        self?.properties[type] = image
//
//                        // 如果是开屏，需要单独处理
//                        if type == .openScreenPicture {
//                            self?.saveOpenScreenPictureCacheKey(key: resource.cacheKey)
//                        }
//
//                        QLog.debug("DOWNLOAD Image success: image type: \(type), image url is \(url)")
//                    }
//                })
//            }
//        })
    }

    /// 移除开屏页cacheKey
    func removeOpenScreenPictureCacheKey() {
        AppEnvironment.userDefault.removeObject(forKey: StaticAssetService.openScreenUserDefaultKey)
    }

    /// 缓存开屏页cacheKey
    func saveOpenScreenPictureCacheKey(key: String) {
        AppEnvironment.userDefault.set(key, forKey: StaticAssetService.openScreenUserDefaultKey)
        AppEnvironment.userDefault.synchronize()
    }
}
