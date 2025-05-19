import SnapKit
import RxCocoa
import Kingfisher

class LaunchViewController: BaseViewController {

    let imageView = UIImageView()

    let bottom = UIImageView(image: UIImage(named: "launch_bottom"))

    var totalTime = 3

    weak var timer: Timer?

    let badNetworkImageView = UIImageView(image: UIImage(named: "launch_bad_network"))

    var button = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "重新加载")

    let label = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: "网络状态很差，点击重试")

    let openScreenPicture = StaticAssetService.getOpenScreenPicture()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 网络状态不好时显示
        let container = UIView()
        self.view.addSubview(container)
        container.snp.makeConstraints { make in
            make.center.equalTo(self.view)
            make.width.equalTo(self.view)
        }

        badNetworkImageView.isHidden = true
        container.addSubview(badNetworkImageView)
        badNetworkImageView.snp.makeConstraints { make in
            make.top.centerX.equalTo(container)
            make.size.equalTo(296/2)
        }

        label.isHidden = true
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(badNetworkImageView.snp.bottom).offset(20)
            make.centerX.equalTo(container)
        }

        button.isHidden = true
        container.addSubview(button)
        button.addTarget(self, action: #selector(requetMaunally), for: .touchUpInside)

        button.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(16)
            make.centerX.equalTo(container)
            make.width.equalTo(120)
            make.height.equalTo(36)
            make.bottom.equalTo(container)
        }

        //
        setNeedsStatusBarAppearanceUpdate()
        self.view.backgroundColor = .white
        self.bottom.contentMode = .scaleAspectFit
        self.view.addSubview(bottom)
        bottom.snp.makeConstraints { make in
            make.height.equalTo(100)
            make.bottom.equalTo(self.view.safeArea.bottom)
            make.left.equalTo(self.view.safeArea.left)
            make.right.equalTo(self.view.safeArea.right)
        }

        imageView.contentMode = .scaleAspectFill
        self.view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(bottom.snp.top)
        }

        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(launchScreenCountdown), userInfo: nil, repeats: true)
        timer?.fire()

        if let openScreenImage = openScreenPicture {
            imageView.contentMode = .scaleAspectFill
            imageView.image = openScreenImage
        } else {
            imageView.contentMode = .scaleAspectFit
            let path = Bundle.main.path(forResource: "default_lanch", ofType: "gif")
            imageView.kf.setImage(with: URL(fileURLWithPath: path!))
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc func launchScreenCountdown() {
        totalTime -= 1
        if totalTime <= 0 {
            self.timer?.invalidate()

            // 处理 iOS 10 首次进来网络权限的问题
            NetworkReachibility.shared.setup(application: UIApplication.shared, launchOptions: [:], completion: { [weak self] (state, success) in

                dispatch_async_safely_main_queue {
                    // 权限不等于 restricted && requestAppInitAPI 成功
                    if state != .restricted && success {
                        NetworkReachibility.shared.requestAppInitAPI { _ in
                            self?.switchViewController()
                        }
                    } else {
                        self?.showBadNetworkUI()
                    }
                }
            })

        }
    }

    func showBadNetworkUI() {
        self.button.isHidden = false
        self.badNetworkImageView.isHidden = false
        self.label.isHidden = false
        self.bottom.isHidden = true
        self.imageView.isHidden = true
    }

    @objc func requetMaunally() {

        NetworkReachibility.shared.requestAppInitAPI(completion: { [weak self] success in
            if success {
                self?.switchViewController()
            } else {
                self?.showBadNetworkUI()
            }
        })
    }

    func switchViewController() {
        UIApplication.shared.keyWindow?.rootViewController = MainViewController()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer?.invalidate()
        self.timer = nil
    }
}

private func isFirstTimeLaunch() -> Bool {
    let bundleShortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let bundleKey = "kCurrentVersionNotLaunch_\(bundleShortVersion)"
    let exist = AppEnvironment.userDefault.bool(forKey: bundleKey)
    if !exist {
        AppEnvironment.userDefault.set(true, forKey: bundleKey)
        return true
    }
    return false
}
