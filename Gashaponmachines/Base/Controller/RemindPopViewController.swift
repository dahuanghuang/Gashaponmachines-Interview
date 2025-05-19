import UIKit

/// 特殊提醒弹窗
class RemindPopViewController: BaseViewController {
    
    /// 确认回调
    var comfirmButtonClickHandle: (() -> Void)?

    weak var timer: Timer?

    /// 倒计时
    var countdown: Int = 3
    
    /// 顶部图片
    let logoIv = UIImageView(image: UIImage(named: "profile_destroyAccount"))
    
    /// 标题
    let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)
    
    /// 中间顶部提示文字
    let topContentLabel = UILabel.with(textColor: .new_gray, fontSize: 24)
    
    /// 中间底部提示文字
    let bottomContentLabel = UILabel.with(textColor: .new_gray, fontSize: 24)

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

    /// - Parameters:
    ///   - imageStr: 图片
    ///   - title: 标题
    ///   - n1Text: 中间上面提示文字
    ///   - n2Text: 中间下面提示文字
    init(imageStr: String? = nil, title: String? = nil, n1Text: String? = nil, n2Text: String? = nil) {
        if let imgstr = imageStr {
            self.logoIv.image = UIImage(named: imgstr)
        }
        self.titleLabel.text = title
        self.topContentLabel.text = n1Text
        self.bottomContentLabel.text = n2Text
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        }
        
        blackView.addSubview(logoIv)
        logoIv.snp.makeConstraints { make in
            make.left.right.equalTo(contentView)
            make.bottom.equalTo(contentView.snp.top)
            make.height.equalTo(147)
        }

        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(18)
        }

        topContentLabel.numberOfLines = 0
        topContentLabel.textAlignment = .center
        contentView.addSubview(topContentLabel)
        topContentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.centerX.equalToSuperview()
        }

        bottomContentLabel.numberOfLines = 0
        bottomContentLabel.textAlignment = .center
        contentView.addSubview(bottomContentLabel)
        bottomContentLabel.snp.makeConstraints { make in
            make.top.equalTo(topContentLabel.snp.bottom)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.centerX.equalToSuperview()
        }

        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(bottomContentLabel.snp.bottom).offset(20)
            make.height.equalTo(44)
            make.left.equalTo(12)
            make.bottom.equalTo(-12)
        }

        contentView.addSubview(quitButton)
        quitButton.snp.makeConstraints { make in
            make.top.size.equalTo(confirmButton)
            make.left.equalTo(confirmButton.snp.right).offset(12)
            make.right.equalTo(-12)
        }

        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .common)
    }

    @objc func countDown() {
        if countdown <= 0 { return }

        countdown -= 1

        if countdown == 0 {
            self.confirmButton.setTitle("确定", for: .normal)
            self.confirmButton.isEnabled = true
            self.stopTimer()
        } else {
            self.confirmButton.setTitle("确定(\(countdown)s)", for: .normal)
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
