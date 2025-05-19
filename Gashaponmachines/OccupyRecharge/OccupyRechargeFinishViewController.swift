import Foundation

class OccupyRechargeFinishViewController: BaseViewController {

    weak var delegate: Rechargable?

    var traceTime: Int = 0

    let titleLb = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: "霸机剩余时间")

    init(traceTime: Int) {
        super.init(nibName: nil, bundle: nil)
        self.traceTime = traceTime
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
        addTimer()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var timer: Timer?

    fileprivate func setupView() {
        self.view.backgroundColor = .clear
        
        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        let contentView = RoundedCornerView(corners: .allCorners, radius: 12, backgroundColor: .white)
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.center.equalTo(blackView)
            make.width.equalTo(280)
            make.height.equalTo(148)
        }

        titleLb.text = "霸机剩余时间(\(self.traceTime))"
        contentView.addSubview(titleLb)
        titleLb.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(12)
        }

        let tipLb = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: "请根据实际情况正确选择")
        contentView.addSubview(tipLb)
        tipLb.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLb.snp.bottom).offset(8)
        }
        
        let successButton = UIButton.with(title: "支付完成", titleColor: .black, boldFontSize: 28)
        successButton.addTarget(self, action: #selector(rechargeSuccess), for: .touchUpInside)
        successButton.layer.cornerRadius = 8
        successButton.layer.masksToBounds = true
        successButton.backgroundColor = UIColor(hex: "FFCC3E")
        contentView.addSubview(successButton)
        successButton.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.bottom.equalTo(-24)
            make.height.equalTo(44)
        }
        
        let failButton = UIButton.with(title: "支付遇到问题", titleColor: .black, boldFontSize: 28)
        failButton.addTarget(self, action: #selector(rechargeFail), for: .touchUpInside)
        failButton.layer.cornerRadius = 8
        failButton.layer.masksToBounds = true
        failButton.backgroundColor = .new_backgroundColor
        contentView.addSubview(failButton)
        failButton.snp.makeConstraints { (make) in
            make.left.equalTo(successButton.snp.right).offset(8)
            make.right.equalTo(-12)
            make.bottom.size.equalTo(successButton)
        }
        

//        let left = UIView.withBackgounrdColor(.white)
//        left.layer.borderColor = UIColor.viewBackgroundColor.cgColor
//        left.layer.borderWidth = 0.5
//        left.layer.cornerRadius = 8
//        left.layer.masksToBounds = true
//        contentView.addSubview(left)
//        left.snp.makeConstraints { make in
//            make.top.equalTo(tipLb.snp.bottom).offset(24)
//            make.left.equalTo(contentView).offset(16)
//            make.height.equalTo(72)
//            make.width.equalTo(116)
//        }
//
//        let leftInner = UIView.withBackgounrdColor(.white)
//        leftInner.layer.borderColor = UIColor.qu_yellow.cgColor
//        leftInner.layer.borderWidth = 1
//        leftInner.layer.cornerRadius = 4
//        leftInner.layer.masksToBounds = true
//        left.addSubview(leftInner)
//        leftInner.snp.makeConstraints { make in
//            make.top.left.equalTo(left).offset(4)
//            make.bottom.right.equalTo(left).offset(-4)
//        }
//
//        let leftIcon = UIImageView.with(imageName: "occupy_finish_true")
//        left.addSubview(leftIcon)
//        leftIcon.snp.makeConstraints { make in
//            make.center.equalTo(left)
//            make.size.equalTo(CGSize(width: 69, height: 48))
//        }
//
//        let leftLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "支付完成")
//        contentView.addSubview(leftLabel)
//        leftLabel.snp.makeConstraints { make in
//            make.top.equalTo(left.snp.bottom).offset(12)
//            make.centerX.equalTo(left)
//            make.bottom.equalTo(contentView).offset(-20)
//        }
//
//        let right = UIView.withBackgounrdColor(.white)
//        right.layer.borderColor = UIColor.viewBackgroundColor.cgColor
//        right.layer.borderWidth = 0.5
//        right.layer.cornerRadius = 8
//        right.layer.masksToBounds = true
//        contentView.addSubview(right)
//        right.snp.makeConstraints { make in
//            make.top.equalTo(left)
//            make.right.equalTo(contentView).offset(-16)
//            make.height.equalTo(72)
//            make.width.equalTo((280-16*3)/2)
//        }
//
//        let rightInner = UIView.withBackgounrdColor(.white)
//        rightInner.layer.borderColor = UIColor.qu_yellow.cgColor
//        rightInner.layer.borderWidth = 1
//        rightInner.layer.cornerRadius = 4
//        rightInner.layer.masksToBounds = true
//        right.addSubview(rightInner)
//        rightInner.snp.makeConstraints { make in
//            make.top.left.equalTo(right).offset(4)
//            make.bottom.right.equalTo(right).offset(-4)
//        }
//
//        let rightIcon = UIImageView.with(imageName: "occupy_finish_false")
//        right.addSubview(rightIcon)
//        rightIcon.snp.makeConstraints { make in
//            make.center.equalTo(right)
//            make.size.equalTo(CGSize(width: 69, height: 48))
//        }
//
//        let rightLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "支付遇到问题")
//        contentView.addSubview(rightLabel)
//        rightLabel.snp.makeConstraints { make in
//            make.top.equalTo(leftLabel)
//            make.centerX.equalTo(right)
//            make.bottom.equalTo(contentView).offset(-20)
//        }
//
//        let leftGes = UITapGestureRecognizer(target: self, action: #selector(rechargeSuccess))
//        let rightGes = UITapGestureRecognizer(target: self, action: #selector(rechargeFail))
//
//        leftIcon.isUserInteractionEnabled = true
//        rightIcon.isUserInteractionEnabled = true
//        leftIcon.addGestureRecognizer(leftGes)
//        rightIcon.addGestureRecognizer(rightGes)
    }

    @objc func rechargeSuccess() {
        removeTimer()
        BugTrackService<UserTrackEvent>.writeEventToFile(event: .RechargeSucees)
        self.dismiss(animated: true, completion: { [weak self] in
            self?.delegate?.rechargeSuccess()
        })
    }

    @objc func rechargeFail() {
        removeTimer()
        BugTrackService<UserTrackEvent>.writeEventToFile(event: .RechargeError)
        self.dismiss(animated: true, completion: { [weak self] in
            self?.delegate?.rechargeFail()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func addTimer() {

        removeTimer()

        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        self.timer = timer
    }

    private func removeTimer() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }

    @objc func countDown() {
        if self.traceTime <= 1 {
            removeTimer()
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.traceTime -= 1
        self.titleLb.text = "霸机剩余时间(\(self.traceTime))"
    }
}
