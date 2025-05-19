class YiFanShangLivestreamStatusView: UIView {

    /// 左侧圆形view
    lazy var icon: UIView = {
        let icon = UIView()
        icon.layer.cornerRadius = 8
        icon.layer.masksToBounds = true
        return icon
    }()

    /// 状态label
    lazy var statusLabel = UILabel.with(textColor: .white, boldFontSize: 24, defaultText: "")

    /// 倒计时label
//    lazy var ttlLabel = UILabel.with(textColor: .white, boldFontSize: 24)

    weak var timer: Timer?

    var timeIntervalToCount: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)

        // 白色背景
        self.layer.cornerRadius = 18
        self.layer.masksToBounds = true
        self.backgroundColor = .white

        // 黑色透明背景
        let blackView = UIView.withBackgounrdColor(UIColor.UIColorFromRGB(0x0, alpha: 0.6))
        blackView.layer.cornerRadius = 16
        blackView.layer.masksToBounds = true
        self.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(2)
            make.right.bottom.equalToSuperview().offset(-2)
        }

        // 绿色icon
        self.icon.backgroundColor = UIColor.UIColorFromRGB(0x00ff00)
        self.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalTo(self).offset(10)
            make.centerY.equalTo(self)
            make.size.equalTo(16)
        }

        // 状态label
        statusLabel.textAlignment = .left
        self.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(8)
            make.centerY.equalTo(self)
            make.right.equalTo(self).offset(-8)
        }

        // 倒计时label
//        addSubview(ttlLabel)
//        ttlLabel.snp.makeConstraints { make in
//            make.left.equalTo(self).offset(12)
//            make.centerY.equalTo(self)
//            make.right.equalTo(self).offset(-12)
//        }
    }

    func configureWith(statusInfo: YiFanShangLivestreamInfo.StatusInfo?) {
//        if let ttl = statusInfo?.ttl, let ttlCount = Int(ttl) { // 倒计时
//
//            statusLabel.isHidden = true
//            icon.isHidden = true
//            ttlLabel.isHidden = false
//
//            updateTTLLable(second: ttlCount)
//            timeIntervalToCount = ttlCount
//            createNewTimer()
//
//        }else { // 其他状态
//            statusLabel.isHidden = false
//            icon.isHidden = false
//            ttlLabel.isHidden = true
//
//            statusLabel.text = statusInfo?.notice
//            icon.backgroundColor = statusInfo?.status?.iconColor
//        }

        statusLabel.isHidden = false
        icon.isHidden = false
        statusLabel.text = statusInfo?.notice
        icon.backgroundColor = statusInfo?.status?.iconColor

        if let ttl = statusInfo?.ttl, let ttlCount = Int(ttl) { // 倒计时
            timeIntervalToCount = ttlCount
            createNewTimer()
        }
    }

    func createNewTimer() {
        if timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(count), userInfo: nil, repeats: true)
        }
        self.timer?.fire()
    }

    @objc func count() {
        timeIntervalToCount -= 1

//        updateTTLLable(second: timeIntervalToCount)

        if timeIntervalToCount <= 0 {
            stopTimer()
        }
    }

    // 准备开始游戏回调
    var readyPlayCallback: (() -> Void)?

//    func updateTTLLable(second: Int) {
//        let minutes = second / 60 % 60
//        let seconds = second % 60
//        let str = String(format: "%02i:%02i", minutes, seconds)
//        ttlLabel.text = "倒计时 \(str)"
//    }

    func stopTimer() {

        if let callback = self.readyPlayCallback {
            callback()
        }

        self.timer?.invalidate()
        self.timer = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
