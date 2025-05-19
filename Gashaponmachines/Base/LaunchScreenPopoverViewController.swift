class LaunchScreenPopoverViewController: BaseViewController {

    lazy var quitButton: UIButton = UIButton.with(imageName: "base_close")

    var launchScreen: PopMenuAdInfo

    init(launchScreen: PopMenuAdInfo) {
        self.launchScreen = launchScreen
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupView(launchScreen: PopMenuAdInfo) {
        self.view.backgroundColor = .clear
        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        blackView.tag = 440
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performAction)))
        iv.gas_setImageWithURL(launchScreen.mainImage)
        blackView.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.height.equalTo(350)
            make.center.equalToSuperview()
        }

        quitButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        blackView.addSubview(quitButton)
        quitButton.snp.makeConstraints { make in
            make.top.equalTo(iv.snp.bottom).offset(30)
            make.size.equalTo(CGSize(width: 40, height: 40))
            make.centerX.equalTo(iv)
        }
    }

    @objc func performAction() {
        self.dismiss(animated: true) {
            RouterService.route(to: self.launchScreen.mainAction)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(launchScreen: self.launchScreen)
    }

    @objc func dismissVC() {
        self.dismiss(animated: true) {
            if self.launchScreen.showPage == .Main {
                NotificationCenter.default.post(name: .AdPopupMenuClose, object: nil)
            }
        }
    }
}
