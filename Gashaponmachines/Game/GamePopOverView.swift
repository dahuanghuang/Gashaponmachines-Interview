// 游戏结束弹窗
import Lottie

private let TotalTimeInSec: TimeInterval = 10

protocol GamePopOverViewDelegate: class {

    /// 再来一次
    func viewDidPressedContinueButton()

    /// 不玩了
    func viewDidPressedCancelButton()

    /// 超时
    func viewDidTimeout()

    /// 霸机充值
    func viewDidPressedRechargeButton()
}

extension GamePopOverView: GameComponentAction {

    func on(state: Game.State) {
        switch state {
        case .err, .reset: isHidden = true
        case .win:
            startCountdown()
            isHidden = false
        default: return
        }
    }
}

class GamePopOverView: UIView {

    fileprivate var successInfo: GameSuccessInfo?

    weak var delegate: GamePopOverViewDelegate?

    /// 爆奖动画bundle
    var ballBundle: Bundle? {
        return self.successInfo?.type?.ballBundle
    }
    
    /// 爆奖动画背景bundle
    var bgBundle: Bundle? {
        return self.successInfo?.type?.bgBundle
    }

    let KOIBundle: Bundle = LottieConfig.KoiBundle

    /// 整体透明背景
    let clearBgView = UIView.withBackgounrdColor(.qu_popBackgroundColor)
    /// 暴击黄色背景(暴击才显示)
    lazy var critBgView: UIView = {
        let view = UIView.withBackgounrdColor(.new_yellow)
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()
    /// 暴击标题浅色背景
    lazy var critTitleBgView: RoundedCornerView = {
        let view = RoundedCornerView(corners: .allCorners, radius: 8, backgroundColor: .white.alpha(0.6))
        view.isHidden = true
        return view
    }()
    /// 暴击标题
    lazy var critTitleLb: UILabel = {
        let lb = UILabel.with(textColor: UIColor(hex: "9A4312")!, fontSize: 24)
        lb.isHidden = true
        return lb
    }()
    /// 暴击图片
    lazy var critIv: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "crit_success"))
        iv.isHidden = true
        return iv
    }()
    /// 白色背景
    lazy var whiteBgView: UIView = {
        let view = UIView.withBackgounrdColor(.white)
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    /// 奖品描述
    lazy var gameRewardLabel: UILabel = {
        let label = UILabel.with(textColor: .black, boldFontSize: 28)
        label.numberOfLines = 2
//        label.preferredMaxLayoutWidth = 280-32
        label.textAlignment = .center
        return label
    }()
    /// 爆奖动画视图
    var animationView = AnimationView()
    /// 爆奖背景动画视图
    var animationBgView = AnimationView()
    /// 游戏奖品视图
    lazy var gameRewardIv: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 8
        iv.layer.masksToBounds = true
        iv.isHidden = true
        return iv
    }()
    /// 扭蛋类型图片
    lazy var ballColorIv = UIImageView()

    weak var timer: Timer?

    var timeIntervalToCount = TotalTimeInSec

    /// 是否为一键返回机台
    var isBackGame: Bool = false

    init(delegate: GamePopOverViewDelegate) {
        super.init(frame: .zero)
        setupView()
        self.delegate = delegate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupView() {

        self.backgroundColor = .clear

        self.addSubview(clearBgView)
        clearBgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        animationBgView.isHidden = true
        clearBgView.addSubview(animationBgView)
        animationBgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        clearBgView.addSubview(critBgView)
        critBgView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(279)
            make.height.equalTo(326)
        }

        critBgView.addSubview(critTitleBgView)
        critTitleBgView.snp.makeConstraints { (make) in
            make.top.left.equalTo(4)
            make.right.equalTo(-4)
            make.height.equalTo(38)
        }

        critBgView.addSubview(critIv)
        critIv.snp.makeConstraints { (make) in
            make.left.equalTo(4)
            make.top.equalToSuperview().offset(-6)
            make.width.equalTo(63)
            make.height.equalTo(52)
        }

        critTitleLb.textAlignment = .center
        critBgView.addSubview(critTitleLb)
        critTitleLb.snp.makeConstraints { (make) in
            make.centerY.equalTo(critTitleBgView)
            make.left.equalTo(critIv.snp.right).offset(12)
        }

        // 非暴击时的黄色背景
        let yellowBgView = RoundedCornerView(corners: .allCorners, radius: 12, backgroundColor: .new_yellow)
        clearBgView.addSubview(yellowBgView)
        yellowBgView.snp.makeConstraints { make in
            make.left.bottom.right.equalTo(critBgView)
            make.top.equalTo(critTitleBgView.snp.bottom).offset(4)
        }
        
        yellowBgView.addSubview(whiteBgView)
        whiteBgView.snp.makeConstraints { make in
            make.top.left.equalTo(4)
            make.right.bottom.equalTo(-4)
        }
        
        let resultIv = UIImageView(image: UIImage(named: "game_n_result_bg"))
        whiteBgView.addSubview(resultIv)
        resultIv.snp.makeConstraints { make in
            make.top.left.equalTo(4)
            make.right.equalTo(-4)
            make.height.equalTo(85)
        }
        
        whiteBgView.addSubview(gameRewardIv)
        gameRewardIv.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.centerX.equalTo(whiteBgView)
            make.size.equalTo(135)
        }

        whiteBgView.addSubview(gameRewardLabel)
        gameRewardLabel.snp.makeConstraints { make in
            make.centerX.equalTo(whiteBgView)
            make.top.equalTo(gameRewardIv.snp.bottom).offset(20)
            make.left.equalTo(12)
            make.right.equalTo(-12)
        }

        animationView.isHidden = true
        whiteBgView.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.top.left.equalTo(4)
            make.right.equalTo(-4)
            make.bottom.equalTo(-60)
        }

        whiteBgView.addSubview(ballColorIv)
        ballColorIv.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.centerX.equalTo(whiteBgView)
            make.size.equalTo(135)
        }
    }

    private var _buttons: [GamePopOverViewButton] = []

    func updateEnvelope(env: GameStatusUpdatedEnvelope) {

        if let ttl = env.ttl, let doubleTtl = Double(ttl) {
            self.timeIntervalToCount = doubleTtl / 1000
        } else {
            self.timeIntervalToCount = TotalTimeInSec
        }

        self.successInfo = env.successInfo
        guard let successInfo = self.successInfo else { return }
        
        self.animationBgView.removeFromSuperview()
        self.animationView.removeFromSuperview()
        // FIXME https://github.com/airbnb/lottie-ios/issues/609
        LRUAnimationCache().clearCache()

        // 设置背景动画
        if let bundle = bgBundle {
            animationBgView = AnimationView(name: "data", bundle: bundle)
            animationBgView.isHidden = false
            clearBgView.insertSubview(animationBgView, belowSubview: critBgView)
            animationBgView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        // 设置爆奖动画
        if let isKOI = successInfo.isKOI, isKOI {
            self.animationView = AnimationView(name: "lucky_anim", bundle: KOIBundle)
        } else if let bundle = ballBundle {
            self.animationView = AnimationView(name: "lucky_anim", bundle: bundle)
        }
        animationView.isHidden = false
        whiteBgView.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.top.left.equalTo(4)
            make.right.equalTo(-4)
            make.bottom.equalTo(-60)
        }

        gameRewardIv.gas_setImageWithURL(successInfo.image)

        // 修改暴击样式
        if let critMultiple = successInfo.critMultiple {
            let isCrit = critMultiple > 0
            if isCrit {
                let attrM = NSMutableAttributedString(string: "暴击成功 扭蛋额外获得 ")
                attrM.append(NSAttributedString(string: "\(critMultiple)", attributes: [.foregroundColor: UIColor(hex: "FF602E")!, .font: UIFont.numberFont(24)]))
                attrM.append(NSAttributedString(string: " 个"))
                critTitleLb.attributedText = attrM
            }
            critBgView.isHidden = !isCrit
            critTitleBgView.isHidden = !isCrit
            critTitleLb.isHidden = !isCrit
            critIv.isHidden = !isCrit
        }

        /// 以下为 Button
        // clear
        _buttons.forEach { btn in
            btn.removeFromSuperview()
        }
        _buttons.removeAll()

        // setup
        guard let buttons = successInfo.buttons else { return }
        let firstTwo = buttons.prefix(2)

        for (i, buttonInfo) in firstTwo.enumerated() {
            let button = GamePopOverViewButton(type: GameStatusButtonType(rawValue: buttonInfo.type) ?? .cancel, title: buttonInfo.title)
            whiteBgView.addSubview(button)

            switch button.type {
            case .cancel: button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
            case .recharge: button.addTarget(self, action: #selector(bajiRecharge), for: .touchUpInside)
            case .restart: button.addTarget(self, action: #selector(continuePlaying), for: .touchUpInside)
            }

            if firstTwo.count == 1 {
                button.snp.makeConstraints { make in
                    make.height.equalTo(44)
                    make.left.equalTo(whiteBgView).offset(12)
                    make.right.bottom.equalTo(whiteBgView).offset(-12)
                }
            } else {
                button.snp.makeConstraints { make in
                    make.bottom.equalToSuperview().offset(-12)
                    make.height.equalTo(44)
                    make.width.equalTo((whiteBgView.width-24)/2)
                    if i == 0 {
                        make.left.equalTo(whiteBgView).offset(8)
                    } else if i == 1 {
                        make.right.equalTo(whiteBgView).offset(-8)
                    }
                }
            }

            _buttons.append(button)
        }
    }

    /// 游戏结果展示倒计时
    func startCountdown() {
        gameRewardLabel.text = ""

        createNewTimer()

        self.gameRewardIv.isHidden = true

        // 一键返回机台时, ijk会卡界面, 导致动画无法播放, 直接放扭蛋图片展示2s
        if isBackGame {
            self.isBackGame = false
            if let imgName = self.successInfo?.type?.ballBundlePath {
                self.ballColorIv.image = UIImage(named: imgName)
            }

            delay(2.0) { [weak  self] in
                self?.ballColorIv.isHidden = true
                self?.showRewardState()
            }

        } else {
            animationBgView.play { [weak self] finished in
                guard let strongself = self else { return }
                if finished {
                    strongself.animationBgView.isHidden = true
                }
            }
            
            animationView.play { [weak self] finished in
                guard let strongself = self else { return }
                if finished {
                    strongself.showRewardState()
                }
            }
        }
    }

    /// 展示奖品状态
    func showRewardState() {
        self.animationView.isHidden = true
        
        self.gameRewardIv.isHidden = false
        UIView.animate(withDuration: 0.01, animations: {
            self.gameRewardIv.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }, completion: { finished in
            UIView.animate(withDuration: 0.2, animations: {
                self.gameRewardIv.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        })
        
        self.gameRewardLabel.text = self.successInfo?.title
        
        // 如果这时候已经隐藏掉了，就不再播放音乐
        if !self.isHidden {
            AudioService.shared.play(audioType: .winning)
            AudioService.shared.play(audioType: .vibrate)
        }
    }

    func createNewTimer() {

        if timer != nil {
            stopTimer()
        }

        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(count), userInfo: nil, repeats: true)
    }

    @objc func count() {
        timeIntervalToCount -= 1

        _buttons.forEach { btn in
            if btn.type == .restart || btn.type == .recharge {
                btn.titleLbl.text = "\(btn.title) (\(Int(timeIntervalToCount)))"
            }
        }

        if timeIntervalToCount <= 0 {
            stopTimer()
            self.isHidden = true
            self.delegate?.viewDidTimeout()
        }
    }

    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }

    @objc func bajiRecharge() {
        stopTimer()
        self.delegate?.viewDidPressedRechargeButton()
    }

    @objc func continuePlaying() {
        stopTimer()
        BugTrackService<UserTrackEvent>.writeEventToFile(event: .PlayAgain)
        self.delegate?.viewDidPressedContinueButton()
    }

    @objc func cancel() {
        stopTimer()
        BugTrackService<UserTrackEvent>.writeEventToFile(event: .NotPlay)
        self.delegate?.viewDidPressedCancelButton()
    }

    deinit {
        self.stopTimer()
    }
}
