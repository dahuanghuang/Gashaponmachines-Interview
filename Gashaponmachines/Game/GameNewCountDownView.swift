import Lottie

extension GameNewCountdownView: GameComponentAction {

    func on(state: Game.State) {
        switch state {
        case .ready:
            startCountdown()
            isHidden = false
        case .win:
            return
        case .err, .reset:
            isHidden = true
        default:
            return
        }
    }
}

// 倒计时视图
class GameNewCountdownView: UIView {

    private var animateImages: [CGImage] {
        var images: [CGImage] = []
        for i in 1...8 {
            if i <= 3 {
                images.append(UIImage(named: "countdown_\(i)")!.cgImage!)
            } else {
                images.append(UIImage(named: "transparent")!.cgImage!)
            }
        }
        return images.reversed()
    }

    private lazy var animation: CAKeyframeAnimation = {
        let animation = CAKeyframeAnimation()
        animation.calculationMode = CAAnimationCalculationMode.discrete
        animation.duration = 8
        animation.values = animateImages
        animation.repeatCount = 1
        return animation
    }()

    private lazy var countdownView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: .zero)

        addSubview(countdownView)
        countdownView.snp.makeConstraints { make in
            make.center.equalTo(self)
            make.width.equalTo(366/2)
            make.height.equalTo(128/2)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func finishCountdown() {
        // 停止动画
        self.countdownView.layer.removeAllAnimations()
        // 显示 Go
        self.countdownView.image = UIImage(named: "countdown_go")
        // 短暂延迟后隐藏中间
        delay(1.2) {
            self.countdownView.isHidden = true
        }
    }

    func startCountdown() {
        // 显示
        isHidden = false
        countdownView.isHidden = false
        countdownView.image = nil
        // 开始倒数动画
        CATransaction.begin()
        CATransaction.setCompletionBlock { self.finishCountdown() }
        self.countdownView.layer.add(animation, forKey: "contents")
        CATransaction.commit()
    }
}
