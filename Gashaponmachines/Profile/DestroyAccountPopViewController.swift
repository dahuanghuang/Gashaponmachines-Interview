import Foundation

/// 注销账号提示框
class DestroyAccountPopViewController: BaseViewController {

    var comfirmButtonClickHandle: (() -> Void)?

    weak var timer: Timer?

    var count: Int = 3

    lazy var confirmButton: UIButton = {
        let button = UIButton.with(title: "确定(3s)", titleColor: .new_middleGray, fontSize: 28)
        button.addTarget(self, action: #selector(comfirmButtonClick), for: .touchUpInside)
        button.isEnabled = false
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.new_yellow.cgColor
        return button
    }()

    lazy var quitButton: UIButton = {
        let button = UIButton.with(title: "我再想想", titleColor: .black, boldFontSize: 28)
        button.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.backgroundColor = .new_yellow
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear
        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        let contentView = RoundedCornerView(corners: [.bottomLeft, .bottomRight], radius: 12, backgroundColor: .white)
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(279)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(146)
        }

        let logoIv = UIImageView(image: UIImage(named: "profile_destroyAccount"))
        blackView.addSubview(logoIv)
        logoIv.snp.makeConstraints { make in
            make.left.right.equalTo(contentView)
            make.bottom.equalTo(contentView.snp.top)
            make.height.equalTo(147)
        }

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "确定要注销账号吗")
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(18)
        }

        let topContentLabel = UILabel.with(textColor: .new_gray, fontSize: 24, defaultText: "确认要注销账号后")
        topContentLabel.textAlignment = .center
        contentView.addSubview(topContentLabel)
        topContentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        let bottomContentLabel = UILabel.with(textColor: .new_gray, fontSize: 24, defaultText: "资产等级和其他信息将无法恢复")
        bottomContentLabel.textAlignment = .center
        contentView.addSubview(bottomContentLabel)
        bottomContentLabel.snp.makeConstraints { make in
            make.top.equalTo(topContentLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }

        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.left.equalTo(12)
            make.bottom.equalTo(-12)
        }

        contentView.addSubview(quitButton)
        quitButton.snp.makeConstraints { make in
            make.bottom.size.equalTo(confirmButton)
            make.left.equalTo(confirmButton.snp.right).offset(12)
            make.right.equalTo(-12)
        }

        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .common)
    }

    @objc func countDown() {
        if count <= 0 { return }

        count -= 1

        if count == 0 {
            self.confirmButton.setTitle("确认注销", for: .normal)
            self.confirmButton.isEnabled = true
            self.stopTimer()
        } else {
            self.confirmButton.setTitle("确定(\(count)s)", for: .normal)
            self.confirmButton.isEnabled = false
        }
    }

    @objc func comfirmButtonClick() {
        self.dismiss {
            if let handle = self.comfirmButtonClickHandle {
                handle()
            }
        }
    }

    func stopTimer() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }

    @objc func dismissVC() {
        self.dismiss()
    }

    func dismiss(completion: (() -> Void)? = nil) {
        self.stopTimer()
        self.dismiss(animated: true, completion: completion)
    }

    deinit {
        self.stopTimer()
    }
}
