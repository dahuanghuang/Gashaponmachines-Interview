/// 合成材料兑换提示框
class PieceEggPopViewController: BaseViewController {

    var comfirmButtonClickHandle: (() -> Void)?

    weak var timer: Timer?

    var count: Int = 6

    lazy var confirmButton: UIButton = {
        let button = UIButton.with(title: "已了解(6s)", titleColor: .qu_black.alpha(0.7), boldFontSize: 28)
        button.addTarget(self, action: #selector(comfirmButtonClick), for: .touchUpInside)
        button.isEnabled = false
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.backgroundColor = .new_yellow
        return button
    }()

    lazy var quitButton: UIButton = {
        let button = UIButton.with(title: "不换了", titleColor: .new_gray, boldFontSize: 28)
        button.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.new_yellow.cgColor
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

        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.center.equalTo(blackView)
            make.height.equalTo(226)
        }

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "注意 此为合成材料")
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        let centerView = UIView.withBackgounrdColor(.clear)
        contentView.addSubview(centerView)
        centerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(120)
        }

        let string = NSMutableAttributedString(string: "合成材料", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.new_gray])
        string.append(NSAttributedString(string: "一旦兑换蛋壳即无法恢复", attributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor(hex: "FF602E")!]))
        let topContentLabel = UILabel.with(textColor: .new_gray, fontSize: 28)
        topContentLabel.attributedText = string
        topContentLabel.textAlignment = .center
        centerView.addSubview(topContentLabel)
        topContentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(centerView.snp.centerY).offset(-2)
        }

        let bottomContentLabel = UILabel.with(textColor: .new_gray, fontSize: 28, defaultText: "建议在活动结束后再兑换哦")
        bottomContentLabel.textAlignment = .center
        centerView.addSubview(bottomContentLabel)
        bottomContentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(centerView.snp.centerY).offset(2)
        }

        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(centerView.snp.bottom)
            make.height.equalTo(44)
            make.left.equalTo(12)
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
        if count <= 0 { return }

        count -= 1

        if count == 0 {
            self.confirmButton.setTitle("已了解", for: .normal)
            self.confirmButton.setTitleColor(.qu_black, for: .normal)
            self.confirmButton.isEnabled = true
            self.stopTimer()
        } else {
            self.confirmButton.setTitle("已了解(\(count)s)", for: .normal)
            self.confirmButton.setTitleColor(.qu_black.alpha(0.7), for: .normal)
            self.confirmButton.isEnabled = false
        }
    }

    @objc func comfirmButtonClick() {
        if let handle = self.comfirmButtonClickHandle {
            handle()
        }
        self.dismissVC()
    }

    func stopTimer() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }

    @objc func dismissVC() {
        self.stopTimer()
        self.dismiss(animated: true, completion: nil)
    }

    deinit {
        self.stopTimer()
    }
}
