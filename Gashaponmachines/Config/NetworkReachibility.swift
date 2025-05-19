// 这个类为了解决 iOS 10 首次安装网络权限无效的问题
import Alamofire
import CoreTelephony

struct NetworkReachibility {

    static let shared = NetworkReachibility()

    func setup(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?, completion: @escaping ((_ state: CTCellularDataRestrictedState, _ success: Bool) -> Void)) {
        if #available(iOS 10.0, *) {
            //    CTCellularData只能检测蜂窝权限，不能检测WiFi权限 因此模拟器直接过
            if !Platform.isSimulator {
                networkStatus(application: application, didFinishLaunchingWithOptions: launchOptions, completion: completion)
            } else {
                completion(.notRestricted, true)
            }
        } else {
            completion(.notRestricted, true)
        }
    }

//    CTCellularData在iOS9之前是私有类，权限设置是iOS10开始的，所以App Store审核没有问题
    func networkStatus(application: UIApplication, didFinishLaunchingWithOptions option: [UIApplication.LaunchOptionsKey: Any]?, completion: @escaping ((_ state: CTCellularDataRestrictedState, _ success: Bool) -> Void)) {
        let cellularData = CTCellularData()

        cellularData.cellularDataRestrictionDidUpdateNotifier = { state in
            switch state {
            case .restricted:
                // 2.1权限关闭的情况下 再次请求网络数据会弹出设置网络提示
                QLog.debug("CTCellularData restricted")
                self.requestAppInitAPI(completion: { success in
                    completion(.restricted, success)
                })
            case .notRestricted:
                // 2.2已经开启网络权限 监听网络状态
                self.addReachibilityManager(application: application, didFinishLaunchingWithOptions: option)
                QLog.debug("CTCellularData not restricted")
                completion(.notRestricted, true)
            case .restrictedStateUnknown:
                // 2.3未知情况 （还没有遇到推测是有网络但是连接不正常的情况下）
                QLog.debug("CTCellularData restrictedStateUnknown")
                self.requestAppInitAPI(completion: { success in
                    completion(.restrictedStateUnknown, success)
                })
            }
        }
    }

    /**
     实时检查当前网络状态
     */
    func addReachibilityManager(application: UIApplication, didFinishLaunchingWithOptions option: [UIApplication.LaunchOptionsKey: Any]?) {

        // CHANGE
        let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.baidu.com")
        reachabilityManager?.startListening(onUpdatePerforming: { status in
            switch status {

            case .notReachable:
                QLog.debug("The network is not reachable")
            case .unknown :
                QLog.debug("It is unknown whether the network is reachable")
            case .reachable(.ethernetOrWiFi):
                QLog.debug("The network is reachable over the WiFi connection")
            case .reachable(.cellular):
                QLog.debug("The network is reachable over the WWAN connection")
            }
        })
    }

    /// 请求APP初始化数据, 更新App环境
    func requestAppInitAPI(completion: ((_ success: Bool) -> Void)) {
        getAppInitData(completion: { data in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                        
                        if AppDelegate.enabledLog {
                            print("请求成功 ========> https://https.quqqi.com/dev/0/public/appInit, \(json)")
                        }

                        let result = json["data"] as! [String: Any]

                        // 没有值就默认为展示一番赏
                        var isYfs: Bool = true
                        if let isEnableOnePieceTask = result["isEnableOnePieceTask"] as? String {
                            isYfs = isEnableOnePieceTask == "1"
                        }
                        
                        // 没有值就不展示苹果登录
                        var isAppleLogin: Bool = false
                        if let isEnableAppleLogin = result["signInWithApple"] as? Bool {
                            isAppleLogin = isEnableAppleLogin
                        }
                        
                        // 是否要显示tabbar的点击动画
                        var isAnimation: Bool = false
                        if let isEnableAnimation = result["isAnimation"] as? Bool {
                            isAnimation = isEnableAnimation
                        }

                        // 没有值就默认不打开日志
                        var isEnableLog: Bool = false
                        if let isLog = result["isEnableLog"] as? String {
                            isEnableLog = isLog == "1"
                        }

                        // 是否为审核版本
                        let isReviewing = (result["isReviewing"] as? String == "1")
                        let isReviewingVersionEqual = (result["isReviewingVersion"] as? String) == DeviceInfo.getAppVersion()
                        let isReal = isReviewingVersionEqual && isReviewing
                        let siteURLs = result["siteURLs"] as! [String: String]
                        let version = result["latestVersion"] as! String
                        let desc = result["updateDescription"] as! String

                        var fImageInfo = [String: String]()
                        if let fi = result["floatImageInfo"] as? [String: String] {
                            fImageInfo = fi
                        }

                        AppEnvironment.updateConfig(Config(isReal: isReal, siteURLs: siteURLs, isYfs: isYfs, isAppleLogin: isAppleLogin, isAnimation: isAnimation, version: version, desc: desc, isEnableLog: isEnableLog, floatImageInfo: fImageInfo))

                        completion(true)
                    }
                } catch {
                    HUD.showError(second: 2, text: error.localizedDescription, completion: nil)
                    QLog.error(error.localizedDescription)
                }

            } else {
//                AppEnvironment.updateConfig(Config(isReviewing: false, siteURLs: [:]))
//                HUD.alert(title: "无法连接到远程服务器",
//                          message: "如果在 iOS 10 下遇到元气扭蛋不能联网的问题，可以尝试以下几种方式解决：\n1.重启手机再尝试打开元气扭蛋 \n2.在 iPhone 的「设置」>「蜂窝移动网络」>「使用无线局域网与蜂窝移动的应用」中尝试更改元气扭蛋的联网权限设置 \n3.在 iPhone 的「设置」>「蜂窝移动网络」中打开「无线局域网助理」，再尝试打开元气扭蛋，问题修复后即可选择关闭「无线局域网助理」",
//                          confirmCompletion: nil)
                completion(false)
            }
        })
    }

    func getAppInitData(completion: ((Data?) -> Void)) {
        var path: String
        switch AppEnvironment.current.stage {
        case .stage:
            path = "/stage/0/public/appInit"
        case .test:
            path = "/dev/0/public/appInit"
        default:
            path = "/0/public/appInit"
        }

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 3
        let session = URLSession(configuration: config)
//        let url = URL(string: "https://https.quqqi.com/0/public/appInit")!
        let url = URL(string: "https://https.quqqi.com\(path)")!
        var request = URLRequest(url: url)
        let param = DeviceInfo.deviceInfo()
        let paramData = try? JSONSerialization.data(withJSONObject: param, options: [])
        request.httpBody = paramData
        request.httpMethod = "POST"

        let builder = AliCloudGatewayHelper()
        let dict = builder.buildHeader("https",
                                       method: "POST",
                                       host: url.host!,
//                                       path: "/0/public/appInit",
                                       path: path,
                                       pathParams: nil,
                                       queryParams: nil,
                                       formParams: nil,
                                       body: paramData,
                                       requestContentType: CLOUDAPI_CONTENT_TYPE_JSON,
                                       acceptContentType: CLOUDAPI_CONTENT_TYPE_JSON,
                                       headerParams: nil)
        request.allHTTPHeaderFields = dict.allHTTPHeaderFields

        let handler = session.synchronousDataTask(with: request)
        let data = handler.0
        completion(data)
    }
}
