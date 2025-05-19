//
import UIKit
import Kingfisher

private let getDeviceInfo: String = "getDeviceInfo" // 获取设备信息
private let share: String = "share" // 分享
private let wechatShare: String = "wechatShare" // 微信分享
private let getAppInfo: String = "getAppInfo" // 获取版本号
private let setToolBarBgColor: String = "setToolBarBgColor" // 导航栏颜色
private let callWebPay: String = "webPay" // 调用支付(支付宝)

class WKWebViewController: BaseViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    let viewModel = WebPayViewModel()

    var routerHandle: (() -> Void)?

    private static let maxRetryQueryCount: Int = 5
    
    let navBar = UIView.withBackgounrdColor(.black)
    
    lazy var backButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.setTitleColor(.white, for: .normal)
        btn.setImage(UIImage(named: "nav_back_white"), for: .normal)
        btn.setTitle("返回", for: .normal)
        return btn
    }()

    /// 关闭按钮
    lazy var closeButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("关闭", for: .normal)
        return btn
    }()
    
    let titleLb = UILabel.with(textColor: .white, fontSize: 32)

    lazy var webview: WKWebView = {
        let wv = WKWebView(frame: .zero)
        wv.backgroundColor = .qu_yellow
        wv.navigationDelegate = self
        return wv
    }()

    private var url: URL

    private var headers: [String: String]

    private var request: URLRequest?

    var bridge: WKWebViewJavascriptBridge?

    var userShareScreenShotViewController: UserShareScreenShotViewController?

    // MARK: - 初始化函数
    init(url: URL, headers: [String: String] = [:]) {
        self.url = url
        self.headers = headers
        super.init(nibName: nil, bundle: nil)
        self.bridge = WKWebViewJavascriptBridge.init(for: self.webview)
        self.bridge?.setWebViewDelegate(self)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 系统函数
    override func viewDidLoad() {
        super.viewDidLoad()

        AlipayApiManager.shared.delegate = self
        
        view.backgroundColor = .white
        
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }
        
        navBar.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.height.equalTo(Constants.kNavHeight)
        }
        
        navBar.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.height.centerY.equalTo(backButton)
            make.left.equalTo(backButton.snp.right).offset(8)
        }
        
        navBar.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.bottom.height.equalTo(backButton)
            make.centerX.equalToSuperview()
        }

        view.addSubview(webview)
        webview.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        self.webview.load(setupRequest(url: self.url, headers: self.headers))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)

        self.registHandle()

        self.refreshContent()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.bridge?.removeHandler(getDeviceInfo)
    }

    // MARK: - 自定义函数
    private func setupRequest(url: URL, headers: [String: String]) -> URLRequest {
        let request = NSMutableURLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
        var string = ""
        var mutHeaders = headers
        if let token = AppEnvironment.current.apiService.accessToken {
            mutHeaders["userSession"] = token
        }

        for pair in mutHeaders {
            string += "\(pair.key)=\(pair.value)"
        }
        let param = "p=\(QUEncryption.encrypt(withText: string) ?? "")"
        request.addValue(param, forHTTPHeaderField: "gashead")
        let URLRequest = request as URLRequest
        self.request = URLRequest
        return URLRequest
    }

    // 注册回调
    func registHandle() {
        self.setAliPayHandle()
        self.setToolBarBgColorHandle()
        self.getDeviceInfoHandle()
        self.shareHandle()
        self.wechatShareHandle()
        self.getAppInfoHandle()
    }

    func setAliPayHandle() {
        self.bridge?.registerHandler(callWebPay, handler: { [weak self] (data, callback) in
            guard let param = data as? [String: String] else { return }
            if  let type = param["type"] {
                self?.viewModel.requestSign.onNext(type)
            }
        })
    }

    func setToolBarBgColorHandle() {
        self.bridge?.registerHandler(setToolBarBgColor, handler: { [weak self] (data, callback) in

            guard var colorValue = data as? String else {
                if let cb = callback {
                    cb("0")
                }
                return
            }
            
            // 去除#
            colorValue.removeFirst()
            self?.navBar.backgroundColor = UIColor(hex: colorValue)
        })
    }

    func getAppInfoHandle() {
        self.bridge?.registerHandler(getAppInfo, handler: { (data, callback) in
            let info = ["versionName": DeviceInfo.getAppVersion(),
                        "versionCode": DeviceInfo.getBuildVersion()
                ]
            callback!(info)
        })
    }

    func getDeviceInfoHandle() {
        self.bridge?.registerHandler(getDeviceInfo, handler: { (data, callback) in
            var deviceInfo = DeviceInfo.deviceInfo()["deviceInfo"] as! [String: Any]
            // 增加sessionToken和timestamp
            if let token = AppEnvironment.current.apiService.accessToken {
                deviceInfo["sessionToken"] = token
            }
            deviceInfo["timestamp"] = NSDate().timeIntervalSince1970 * 1000
            // 拼接deviceInfo的数据, 如:timestamp=xxx&sessionToken=xxx
            var str = ""
            for pair in deviceInfo {
                str += "\(pair.key)=\(pair.value)"
                str += "&"
            }
            // 删除最后的&
            str = String(str.dropLast())
            if let dataString = data as? String, dataString != "" {
                str += dataString
            }
            // 加密
            let result = QUEncryption.encrypt(withText: str) ?? ""
            callback!(result)
        })
    }

    func shareHandle() {
        self.bridge?.registerHandler(share, handler: { (data, callback) in
            guard let shareParam = data as? [String: String] else {
                if let cb = callback {
                    cb("0")
                }
                return
            }

            let title = shareParam["title"] ?? ""
            let text = shareParam["text"] ?? ""
            let image = shareParam["imageUrl"] ?? ""
            let urlStr = shareParam["urlStr"] ?? ""

            let shareType = shareParam["shareType"] ?? ""
            var type: SSDKPlatformType = .typeUnknown
            if shareType == "1" {
                type = .subTypeWechatTimeline
            } else if shareType == "2" {
                type = .subTypeWechatSession
            } else if shareType == "3" {
                type = .subTypeQQFriend
            } else if shareType == "4" {
                type = .typeSinaWeibo
            }

            let imageURL = NSURL(string: image)! as URL
            let cacheKey = "shareKey"
//            KingfisherManager.shared.cache.retrieveImage(forKey: cacheKey, options: nil) { (image, cacheType) in
//                if image != nil {
//                    ShareService.shareTo(type, title: title, text: text, shareImage: image, urlStr: urlStr, type: .webPage, callback: { success in
//                        callback?(success ? "1" : "0")
//                    })
//
//                } else {
//                    KingfisherManager.shared.downloader.downloadImage(with: imageURL, options: nil, progressBlock: nil, completionHandler: { (image, error, imageURL, originalData) in
//                        if let image = image, let originalData = originalData {
//                            KingfisherManager.shared.cache.store(image,
//                                                                 original: originalData,
//                                                                 forKey: cacheKey,
//                                                                 toDisk: true,
//                                                                 completionHandler: nil)
//                            ShareService.shareTo(type, title: title, text: text, shareImage: image, urlStr: urlStr, type: .webPage, callback: { success in
//                                callback?(success ? "1" : "0")
//                            })
//                        }
//                    })
//                }
//            }
        })
    }

    func wechatShareHandle() {
        self.bridge?.registerHandler(wechatShare, handler: { [weak self] (data, callback) in
            guard let shareParam = data as? [String: String] else {
                if let cb = callback {
                    cb("0")
                }
                return
            }

            let avatar = shareParam["avatar"] ?? ""
            let invitationCode = shareParam["invitationCode"] ?? ""
            let nickname = shareParam["nickname"] ?? ""
            let product = shareParam["productImage"] ?? ""
            let progress = shareParam["progress"] ?? ""
            let info = UserShareInfo(avatar: avatar, invitationCode: invitationCode, nickname: nickname, productImage: product, progress: progress)

//            if let avatarUrl = URL(string: avatar), let productUrl = URL(string: product) {
//
//                ImageDownloader.default.downloadImage(with: avatarUrl, retrieveImageTask: nil, options: [], progressBlock: nil) { (avatarImage, _, _, data) in
//                    ImageDownloader.default.downloadImage(with: productUrl, retrieveImageTask: nil, options: [], progressBlock: nil) { (productImage, _, _, data) in
//                        if let aImage = avatarImage, let pImage = productImage {
//                            self?.userShareScreenShotViewController = UserShareScreenShotViewController(info: info, avatarImage: aImage, productImage: pImage)
//                            guard let image = self?.generateScreenshot() else {
//                                HUD.showError(second: 2, text: "无法生成图片", completion: nil)
//                                return
//                            }
//
//                            let vc = UserSharePopViewController(image: image, inviteCode: invitationCode)
//                            vc.modalPresentationStyle = .overFullScreen
//                            vc.modalTransitionStyle = .crossDissolve
//                            self?.present(vc, animated: true, completion: nil)
//                        }
//                    }
//                }
//
//            } else {
//                HUD.showError(second: 1.0, text: "分享异常", completion: nil)
//            }
        })
    }

    func generateScreenshot() -> UIImage? {
        guard let vc = self.userShareScreenShotViewController else { return nil }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 375, height: 667), false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        vc.renderView.layer.render(in: context)
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return renderedImage
    }

    /// 刷新内容
    func refreshContent() {
        // refresh = 1, 刷新
        let urlStr = self.url.absoluteString
        if urlStr.contains("?") && urlStr.contains("refresh") {
            let index = urlStr.firstIndex(of: "=")
            var params = urlStr[index!...]
            params.removeFirst()
            let closeValue = String(params.first!)
            if closeValue == "1" {
                self.webview.load(setupRequest(url: self.url, headers: self.headers))
            }
        }
    }

    // MARK: - 监听函数
    @objc func backAction() {
//        var count: UInt32 = 0
//        if let nav = self.navigationController?.navigationBar {
//            let propertys = class_copyPropertyList(object_getClass(nav), &count)
//            for item in 0..<count {
//                let property = propertys?[Int(item)]
//                if let p = property {
//                    let cname = property_getName(p)
//                    let name = String(cString: cname)
//                    print("\(name)")
//                }
//            }
//        }
//        print("结束获取 =============")
//
//        if let view = self.navigationController?.navigationBar.value(forKey: "_backgroundView") as? UIView {
//            view.backgroundColor = .green
//        }
        
        if self.webview.canGoBack {
            self.webview.goBack()
        } else {
            closeAction()
        }
    }

    @objc func closeAction() {
        guard let nav = self.navigationController else {
            fatalError("Webview should be wrapped within a navigationController")
        }
        if nav.viewControllers.count > 1 {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }

    override func bindViewModels() {
        // 支付宝订单
        viewModel.aliPayOrderEnvelope
            .subscribe(onNext: { env in
                AlipayApiManager.shared.payOrder(orderStr: env.sign, callback: { res in
                    QLog.debug(res?.debugDescription)
                })
            })
            .disposed(by: disposeBag)

        // 查询订单请求失败
        viewModel.queryOrderError
            .subscribe(onNext: { env in
                HUD.shared.dismiss()
                HUD.alert(title: "网络不佳", message: "无法连接到服务器，请重新进入页面")
            })
            .disposed(by: disposeBag)

        // 查询支付状态
        viewModel.queryedResult
            .subscribe(onNext: { [weak self] env in
                guard let StrongSelf = self else { return }

                if env.code == String(GashaponmachinesError.success.rawValue) {
                    delay(1) {
                        HUD.shared.dismiss()
                        HUD.success(second: 1.5, text: "充值成功", completion: {
                            StrongSelf.webview.load(StrongSelf.setupRequest(url: StrongSelf.url, headers: StrongSelf.headers))
                        })
                    }
                } else {
                    if StrongSelf.viewModel.retryQueryCount.value < WKWebViewController.maxRetryQueryCount {
                        delay(1.5) {
                            StrongSelf.viewModel.alipayOutTradeNumber.onNext(env.outTradeNumber)
                            StrongSelf.viewModel.retryQueryCount.accept(StrongSelf.viewModel.retryQueryCount.value + 1)
                        }
                    } else {
                        HUD.shared.dismiss()
                        let str = "由于支付平台网络延迟，此单号 \(env.outTradeNumber) 正在处理中，请勿重复提交订单。稍后在右上角充值明细处查看订单是否成功。点击确定将保存截图，若有疑问请联系客服处理。"
                        HUD.alert(title: "充值确认中", message: str)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}

extension WKWebViewController: URLSessionTaskDelegate, URLSessionDataDelegate {

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!) )
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let request = self.request {
            self.webview.load(request)
        }
    }
}

extension WKWebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let url = navigationAction.request.url?.absoluteString else {
            decisionHandler(.cancel)
            return
        }

        // 本地界面跳转
        if url.contains("yqnd://") {
            if let handle = routerHandle {
                handle()
            }
            RouterService.route(to: url)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webview.evaluateJavaScript("document.title") { [weak self] (title, error) in
            self?.titleLb.text = title as? String
        }
    }
}

extension WKWebViewController: AlipayApiManagerDelegate {

    func didCancelRecharge() {}

    func didReceiveOutTradeNumber(num: String) {
        HUD.shared.persist(text: "支付中")
        self.viewModel.alipayOutTradeNumber.onNext(num)
    }
}
