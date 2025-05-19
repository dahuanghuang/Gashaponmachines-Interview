import GradientProgressBar

class GameNewCriticalInfoView: UIView {
    /// 机台图片
    private let machineIcon = UIImageView()
    /// 机台描述
    private lazy var machineDescLb: UILabel = {
        let lb = UILabel.with(textColor: .black, fontSize: 20, defaultText: "本机台")
        lb.backgroundColor = .new_yellow
        lb.textAlignment = .center
        lb.layer.cornerRadius = 6
        lb.layer.masksToBounds = true
        return lb
    }()
    /// 暴击次数
    private lazy var critCountLabel: UILabel = {
        let lb = UILabel.numberFont(size: 28)
        lb.textColor = UIColor(hex: "FF602E")
        return lb
    }()
    /// 等级速度
    private lazy var levelSpeedLabel: UILabel = {
        let lb = UILabel.with(textColor: UIColor(hex: "FF902B")!, fontSize: 12)
        lb.textAlignment = .center
        lb.layer.borderWidth = 1
        lb.layer.borderColor = lb.textColor.cgColor
        lb.layer.cornerRadius = 4
        return lb
    }()
    /// 黑金速度
    private lazy var vipSpeedLabel: UILabel = {
        let lb = UILabel.with(textColor: .new_lightGray, fontSize: 12)
        lb.textAlignment = .center
        lb.layer.borderWidth = 1
        lb.layer.borderColor = UIColor.new_backgroundColor.cgColor
        lb.layer.cornerRadius = 4
        return lb
    }()
    /// 能量值
    lazy var canObtainPowerLabel: UILabel = {
        let lb = UILabel.numberFont(size: 16)
        lb.textColor = .black
        return lb
    }()
    /// 暴击进度值
    private lazy var critProgressLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32)
    /// 暴击进度指示条
    private lazy var progressView: GameCritProgressView = {
        let v = GameCritProgressView(progressViewStyle: .bar)
        v.backgroundColor = UIColor.viewBackgroundColor
        v.gradientColorList = [UIColor.UIColorFromRGB(0xffd712), UIColor.UIColorFromRGB(0xff372d)]
        v.layer.cornerRadius = 4
        v.layer.masksToBounds = true
        return v
    }()
    /// 进度小圆点图片
    let progressIv = UIImageView(image: UIImage(named: "crit_progress"))
    /// 总能量值进度
    lazy var totalPowerLabel = UILabel.with(textColor: .qu_black, fontSize: 20)
    /// 问号按钮
    let questionButton = UIButton()

    override var isHidden: Bool {
        didSet {
            if isHidden {
                BugTrackService<UserTrackEvent>.writeEventToFile(event: .HiddenInfo)
            } else {
                BugTrackService<UserTrackEvent>.writeEventToFile(event: .ShowInfo)
            }
        }
    }

// MARK: - 初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let bgIv = UIImageView(image: UIImage(named: "crit_info_bg"))
        self.addSubview(bgIv)
        bgIv.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.left.equalTo(8)
        }
        
        let leftArrow: UIImageView = UIImageView.with(imageName: "crit_info_left_arrow")
        self.addSubview(leftArrow)
        leftArrow.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.bottom.equalTo(-24)
            make.width.equalTo(10)
            make.height.equalTo(24)
        }
        
        // 顶部部分
        let topBg = RoundedCornerView(corners: [.topLeft, .topRight], radius: 8, backgroundColor: .white)
        self.addSubview(topBg)
        topBg.snp.makeConstraints { make in
            make.top.equalTo(2)
            make.left.equalTo(16)
            make.right.equalTo(-8)
            make.height.equalTo(50)
        }
        
        let topBgIv = UIImageView(image: UIImage(named: "crit_info_top_bg"))
        topBg.addSubview(topBgIv)
        topBgIv.snp.makeConstraints { make in
            make.top.left.equalTo(2)
            make.bottom.equalTo(-2)
        }
        
        topBgIv.addSubview(machineIcon)
        machineIcon.snp.makeConstraints { make in
            make.top.equalTo(6)
            make.left.equalTo(10)
            make.size.equalTo(28)
        }
        
        topBgIv.addSubview(machineDescLb)
        machineDescLb.snp.makeConstraints { make in
            make.top.equalTo(machineIcon.snp.bottom).offset(-6)
            make.centerX.equalTo(machineIcon)
            make.width.equalTo(34)
            make.height.equalTo(14)
        }
        
        topBgIv.addSubview(critCountLabel)
        critCountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-6)
        }
        
        let critCountDecLabel = UILabel.with(textColor: .qu_black, boldFontSize: 24, defaultText: "当前可暴击次数")
        topBgIv.addSubview(critCountDecLabel)
        critCountDecLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(critCountLabel.snp.left).offset(-5)
        }
        
        // 中间左边部分
        let midLeftBg = RoundedCornerView(corners: .allCorners, radius: 8, backgroundColor: .white)
        self.addSubview(midLeftBg)
        midLeftBg.snp.makeConstraints { make in
            make.top.equalTo(topBg.snp.bottom).offset(13)
            make.left.equalTo(topBg)
            make.width.equalToSuperview().multipliedBy(0.58)
            make.height.equalTo(100)
        }
        
        let critDecLabel = UILabel.with(textColor: UIColor(hex: "A67514")!, fontSize: 20, defaultText: "距离下一次暴击")
        midLeftBg.addSubview(critDecLabel)
        critDecLabel.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.centerX.equalToSuperview()
        }
        
        midLeftBg.addSubview(critProgressLabel)
        critProgressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(critDecLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        midLeftBg.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.bottom.equalTo(-19)
            make.height.equalTo(8)
        }

        midLeftBg.addSubview(progressIv)
        
        
        // 中间右边部分
        let midRightBg = RoundedCornerView(corners: .allCorners, radius: 8, backgroundColor: .white)
        self.addSubview(midRightBg)
        midRightBg.snp.makeConstraints { make in
            make.top.bottom.equalTo(midLeftBg)
            make.left.equalTo(midLeftBg.snp.right).offset(6)
            make.right.equalTo(-8)
        }
        
        let powerValueDecLabel = UILabel.with(textColor: UIColor(hex: "A67514")!, fontSize: 20, defaultText: "可获得能量")
        midRightBg.addSubview(powerValueDecLabel)
        powerValueDecLabel.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.centerX.equalToSuperview()
        }
        
        midRightBg.addSubview(canObtainPowerLabel)
        canObtainPowerLabel.snp.makeConstraints { (make) in
            make.top.equalTo(powerValueDecLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        midRightBg.addSubview(vipSpeedLabel)
        vipSpeedLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-8)
            make.width.equalTo(56)
            make.height.equalTo(14)
        }
        
        midRightBg.addSubview(levelSpeedLabel)
        levelSpeedLabel.snp.makeConstraints { (make) in
            make.centerX.size.equalTo(vipSpeedLabel)
            make.bottom.equalTo(vipSpeedLabel.snp.top).offset(-2)
        }
        
        
        // 底部部分
        let bottomBg = RoundedCornerView(corners: .allCorners, radius: 8, backgroundColor: .white.alpha(0.6))
        self.addSubview(bottomBg)
        bottomBg.snp.makeConstraints { make in
            make.top.equalTo(midLeftBg.snp.bottom).offset(6)
            make.left.equalTo(midLeftBg)
            make.right.equalTo(midRightBg)
            make.bottom.equalTo(-8)
        }
        
        let bottomLeftIv = UIImageView(image: UIImage(named: "crit_info_bottom_left"))
        bottomBg.addSubview(bottomLeftIv)
        bottomLeftIv.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
        }
        
        let bottomRightIv = UIImageView(image: UIImage(named: "crit_info_bottom_right"))
        bottomBg.addSubview(bottomRightIv)
        bottomRightIv.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
        }

        bottomBg.addSubview(totalPowerLabel)
        totalPowerLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }

        let questionIv = UIImageView(image: UIImage(named: "crit_question"))
        bottomBg.addSubview(questionIv)
        questionIv.snp.makeConstraints { make in
            make.size.equalTo(12)
            make.centerY.equalToSuperview()
            make.right.equalTo(totalPowerLabel.snp.left).offset(-2)
        }

        bottomBg.addSubview(questionButton)
        questionButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    var powerInfo: PowerInfo? { 
        didSet {

            guard let powerInfo = powerInfo else { return }

            critCountLabel.text = "\(powerInfo.canCritCount ?? 0)"
            canObtainPowerLabel.text = powerInfo.canObtainPower

            levelSpeedLabel.text = powerInfo.multiples?.expMultiple
            vipSpeedLabel.text = powerInfo.multiples?.bgdMultiple

            if let p = powerInfo.powerReminder, let n = powerInfo.critNeeds {
                let attrM = NSMutableAttributedString(string: "\(p) ", attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: "ff372d")!])
                attrM.append(NSAttributedString(string: "/ \(n)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.qu_black]))
                critProgressLabel.attributedText = attrM

                let progressValue = Float(p) / Float(n)
                progressView.setProgress(progressValue, animated: true)

                if progressValue <= 0 {
                    progressIv.isHidden = true
                } else {
                    progressIv.isHidden = false
                }
                progressIv.snp.remakeConstraints { (make) in
                    make.size.equalTo(8)
                    make.centerY.equalTo(progressView)
                    make.centerX.equalTo(progressView.snp.left).offset(Float(self.progressView.width) * progressValue)
                }
            }

            if let c = powerInfo.currentPower, let p = powerInfo.powerThreshold {
                let attrM = NSMutableAttributedString(string: "总能量值: ", attributes: [.font: UIFont.systemFont(ofSize: 10)])
                attrM.append(NSAttributedString(string: "\(c)", attributes: [.font: UIFont.numberFont(16)]))
                attrM.append(NSAttributedString(string: "/\(p)", attributes: [.font: UIFont.numberFont(14), .foregroundColor: UIColor.black.alpha(0.6)]))
                totalPowerLabel.attributedText = attrM
            }
        }
    }

    var machine: GameMachine? {
        didSet {
            if let icon = machine?.icon {
                machineIcon.gas_setImageWithURL(icon)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CustomLabel: UILabel {

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 0, left: 4, bottom: 0, right: 4)
        super.drawText(in: rect.inset(by: insets))
    }
}
