import Lottie

/// 暴击按钮
class GameNewCriticalButton: UIControl {

    var criticalState: CriticalState = .normal {
        didSet {
            self.configButtonState()

            switch criticalState {
            case let .userStartGame(remainSec):
                if remainSec == 0 {
                    if let canCrit = powerInfo?.canCrit {
                        critIv.image = canCrit ? UIImage(named: "crit_logo_normal") : UIImage(named: "crit_logo_disable")
                    }
                }
            case .fired:
                if let canCrit = powerInfo?.canCrit {
                    critIv.image = canCrit ? UIImage(named: "crit_logo_normal") : UIImage(named: "crit_logo_disable")
                }
            default:
                return
            }
        }
    }

    var powerInfo: PowerInfo? {
        didSet {
            // 第一次进来保存当前能量值
            if previousPower == nil {
                self.previousPower = powerInfo?.currentPower
            }
            self.configButtonState()
        }
    }

    /// 上一次的能量值
    var previousPower: Float?

    /// 向下箭头Iv
    lazy var criticalArrowIv = UIImageView.with(imageName: "crit_arrow_down")
    /// 暴击值
    lazy var powerLabel: UILabel = {
        let lb = UILabel.with(textColor: .qu_black, fontSize: 20)
        lb.textAlignment = .center
        lb.backgroundColor = .white.alpha(0.8)
        lb.layer.cornerRadius = 8
        lb.layer.masksToBounds = true
        return lb
    }()
    /// 进度条背景
    lazy var circularProgressContainer = UIView.withBackgroundColor(color: .clear)
    /// 中间暴击图片
    let critIv = UIImageView()
    /// 暴击倍数
    lazy var critCountLabel: UILabel = {
        let lb = UILabel.numberFont(size: 12)
        lb.textColor = .black
        lb.layer.borderColor = UIColor.white.cgColor
        lb.layer.borderWidth = 2
        lb.textAlignment = .center
        lb.layer.cornerRadius = 6
        lb.layer.masksToBounds = true
        lb.backgroundColor = .new_yellow
        return lb
    }()

    lazy var lottieAnimationView: AnimationView = {
        let v = AnimationView()
        v.loopMode = .playOnce
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(powerLabel)
        
        addSubview(criticalArrowIv)
        criticalArrowIv.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(37)
            make.height.equalTo(5)
        }

        addSubview(critIv)
        critIv.snp.makeConstraints { make in
            make.top.equalTo(criticalArrowIv.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.size.equalTo(68)
        }

        addSubview(circularProgressContainer)
        circularProgressContainer.snp.makeConstraints { make in
            make.edges.equalTo(critIv)
        }

        addSubview(lottieAnimationView)
        lottieAnimationView.snp.makeConstraints { make in
            make.edges.equalTo(critIv)
        }

        addSubview(critCountLabel)

        critIv.isUserInteractionEnabled = false
        circularProgressContainer.isUserInteractionEnabled = false
        lottieAnimationView.isUserInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 修改按钮状态
    func configButtonState() {
        guard let powerInfo = self.powerInfo else { return }

        let power = "\(Int(powerInfo.currentPower ?? 0))"
        powerLabel.text = power
        let powerWidth = power.sizeOfString(usingFont: UIFont.systemFont(ofSize: 10)).width + 24
        powerLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(powerWidth)
            make.height.equalTo(16)
        }

        if let critCount = powerInfo.canCritCount, critCount != 0 {
            critCountLabel.isHidden = false
            let critCountText = "x\(critCount)"
            let textWidth = critCountText.widthWithString(fontSize: 12, height: 18) + 12
            critCountLabel.text = critCountText
            critCountLabel.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-5)
                make.size.equalTo(CGSize(width: textWidth, height: 18))
            }
        } else {
            critCountLabel.isHidden = true
        }

        guard criticalState == .normal || criticalState == .gameDidFinished else { return }

        addProgressLayer()

        critIv.image = (powerInfo.canCrit ?? false) ? UIImage(named: "crit_logo_normal") : UIImage(named: "crit_logo_disable")

        if let current = powerInfo.currentPower, let total = powerInfo.critNeeds {
            let progress = Float(current) / Float(total)

            let pro = progress > 1.0 ? progress.truncatingRemainder(dividingBy: 1.0) : progress

            animatePowerTo(progress: pro, animated: criticalState == .gameDidFinished)

            if criticalState == .normal || criticalState == .gameDidFinished {
                critCountLabel.isHidden = (powerInfo.canCrit ?? true) ? false : true
            }
        }
    }

    lazy var shapeLayer = CAShapeLayer()

    func addProgressLayer() {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: circularProgressContainer.bounds.size.width / 2, y: circularProgressContainer.bounds.size.height / 2),
                                        radius: 32,
                                        startAngle: CGFloat.pi / 2,
                                        endAngle: 5 / 2 * CGFloat.pi,
                                        clockwise: true)
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.new_yellow.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 0
        circularProgressContainer.layer.addSublayer(shapeLayer)
    }

    /// 能量增加动画
    ///
    /// - Parameters:
    ///   - progress: 进度
    ///   - animated: 是否显示动画
    func animatePowerTo(progress: Float, animated: Bool) {

        guard let currentPower = powerInfo?.currentPower else { return }

        CATransaction.begin()
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.fromValue = 0
        basicAnimation.toValue = progress

        var duration = 0.001
        if animated && currentPower != previousPower {
            duration = 0.858
        }
        basicAnimation.duration = duration

        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
        CATransaction.commit()

        guard animated else { return }

        // 能量值有改变才展示更新动画
        if currentPower != previousPower {
            critLessThan1Animtion()
            previousPower = currentPower
        }
    }

    // <1 动画
    func critLessThan1Animtion() {
        lottieAnimationView.isHidden = false
        let img = critIv.image
        critIv.image = nil
        lottieAnimationView.imageProvider = BundleImageProvider(bundle: LottieConfig.CritLessThan1Bundle, searchPath: nil)
        lottieAnimationView.animation = Lottie.Animation.named("data", bundle: LottieConfig.CritLessThan1Bundle)
        lottieAnimationView.play { [weak self] finish in
            self?.critIv.image = img
            self?.lottieAnimationView.isHidden = true
        }
    }

    // 点击选择按钮动画
    func selectedAnimation() {
        lottieAnimationView.isHidden = false
        critIv.image = nil
        lottieAnimationView.imageProvider = BundleImageProvider(bundle: LottieConfig.CritTransitionBundle, searchPath: nil)
        lottieAnimationView.animation = Lottie.Animation.named("data", bundle: LottieConfig.CritTransitionBundle)
        lottieAnimationView.play { [weak self] finish in
            guard let self = self else { return }
            self.critIv.image = UIImage(named: "crit_logo_selected")
            self.lottieAnimationView.isHidden = true
        }
    }
}
