import Lottie

class GameNewCriticalView: UIView {

    weak var delegate: GameNewCriticalViewDelegate?

    /// 黑色背景
    let blackBgView = UIView.withBackgounrdColor(UIColor.black.alpha(0.6))
    /// 暴击按钮
    lazy var criticalButton: GameNewCriticalButton = {
        let btn = GameNewCriticalButton()
        btn.addTarget(self, action: #selector(tapCriticalButton), for: .touchUpInside)
        return btn
    }()
    /// 暴击信息视图
    lazy var criticalInfoView: GameNewCriticalInfoView = {
        let view = GameNewCriticalInfoView()
        view.questionButton.addTarget(self, action: #selector(questionAction), for: .touchUpInside)
        view.isHidden = true
        return view
    }()
    /// 暴击确认视图
    lazy var criticalActionView: GameNewCriticalActionView = {
        let view = GameNewCriticalActionView()
        view.isHidden = true
        view.confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        view.cancelButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        return view
    }()
    /// 左下角暴击动画视图
    lazy var critingAnimationView: GameNewCriticalNumberView = {
        let view = GameNewCriticalNumberView()
        view.isHidden = true
        return view
    }()
    /// 中间暴击HUD
    var criticalHUD: GameNewCriticalHUD?

    // MARK: - 初始化方法
    override init(frame: CGRect) {
        super.init(frame: .zero)

        blackBgView.isHidden = true
        addSubview(blackBgView)
        blackBgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        addSubview(criticalButton)
        criticalButton.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.bottom.equalTo(-54)
            make.width.equalTo(68)
            make.height.equalTo(105)
        }

        addSubview(criticalInfoView)
        criticalInfoView.snp.makeConstraints { make in
            make.left.equalTo(criticalButton.snp.right).offset(6)
            make.bottom.equalTo(-65)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(215)
        }

        addSubview(criticalActionView)
        criticalActionView.snp.makeConstraints { make in
            make.left.equalTo(criticalButton.snp.right).offset(6)
            make.bottom.equalTo(-65)
            make.right.equalToSuperview().offset(-16)
            make.height.greaterThanOrEqualTo(245)
        }

        addSubview(critingAnimationView)
        critingAnimationView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-57)
            make.size.equalTo(CGSize(width: 113, height: 75))
        }

        let tapView = UIView.withBackgounrdColor(.clear)
        tapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGesture)))
//        addSubview(tapView)
        insertSubview(tapView, belowSubview: criticalActionView)
        tapView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(criticalButton.snp.top).offset(-10)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func questionAction() {
        self.delegate?.didQuestionClick()
    }

    @objc func dismiss() {
        self.criticalActionView.resetState()
        self.delegate?.didCanceledCrit()
        selected = false
    }

    @objc func confirmAction() {
        if let txt = criticalActionView.inputTextField.text, let intv = Int(txt), let canCritCount = powerInfo?.canCritCount {
            if intv > 0 && intv <= canCritCount {
                selected = false
                self.delegate?.didConfirmedCrit(critCount: intv)
                self.criticalActionView.resetState()
            } else {
                HUD.showError(second: 1.0, text: "输入个数有误", completion: nil)
            }
        }
    }

    @objc func tapGesture() {
        guard criticalState == .normal || criticalState == .gameDidFinished else { return }
        if !self.criticalInfoView.isHidden {
            self.selected = false
        }
    }

    var powerInfo: PowerInfo? {
        didSet {
            if let pInfo = powerInfo {
                self.criticalActionView.powerInfo = pInfo
                self.criticalButton.powerInfo = pInfo
                self.criticalInfoView.powerInfo = pInfo
            }
        }
    }

    var machine: GameMachine? {
        didSet {
            criticalInfoView.machine = machine
        }
    }

    var criticalState: CriticalState = .normal {
        didSet {
            criticalActionView.criticalState = criticalState
            criticalButton.criticalState = criticalState
            changeCritViewState()
            showBlackBgView()
        }
    }

    private func changeCritViewState() {
        switch criticalState {
            case .normal, .gameDidFinished:
                criticalButton.isEnabled = true
            case let .userStartGame(remainSec):
                var canCrit: Bool = false
                if let powerInfo = powerInfo, let can = powerInfo.canCrit {
                    canCrit = can
                }
                if canCrit && !self.criticalInfoView.isHidden {
                    self.criticalInfoView.isHidden = true
                    self.criticalActionView.isHidden = false
                    selected = true
                }

                if remainSec == 0 {
                    criticalActionView.resetState()
                    criticalActionView.isHidden = true

                    if criticalButton.isEnabled {
                        criticalButton.isEnabled = false
                    }
                }
            case let .fired(usedCrit):
                criticalButton.isEnabled = true
                criticalActionView.isHidden = true

                if usedCrit {
                    critingAnimationView.play()
                    critingAnimationView.isHidden = false
                    criticalButton.isHidden = true
                }
            case .gameGetResult:
                critingAnimationView.stop()
                critingAnimationView.isHidden = true
                criticalButton.isHidden = false
                criticalButton.isEnabled = true
        }
    }

    @objc func tapCriticalButton() {
        selected = !selected
    }

    /// 暴击按钮被点击
    var selected: Bool = false {
        didSet {
            BugTrackService<UserTrackEvent>.writeEventToFile(event: .ClickCritButton)
            switch criticalState {
            case .normal, .gameDidFinished, .fired:
                criticalInfoView.isHidden = !selected
            case .userStartGame:
                var canCrit: Bool = false
                if let powerInfo = powerInfo, let can = powerInfo.canCrit {
                    canCrit = can
                }

                if canCrit {
                    criticalActionView.isHidden = !selected
                    criticalInfoView.isHidden = true

                    if selected {
                        criticalButton.selectedAnimation()
                    } else {
                        criticalButton.critIv.image = UIImage(named: "crit_logo_normal")
                    }
                } else {
                    criticalActionView.isHidden = true
                    criticalInfoView.isHidden = !selected
                }
            default:
                return
            }
            showBlackBgView()
        }
    }

    func showBlackBgView() {
        if criticalInfoView.isHidden && criticalActionView.isHidden {
            self.blackBgView.isHidden = true
        } else {
            self.blackBgView.isHidden = false
        }
    }

    /// 左下角暴击动画
    func playCritingAnimtion(critCount: Int) {

        critingAnimationView.critCount = critCount

        self.criticalHUD = GameNewCriticalHUD(critCount: critCount)
        addSubview(criticalHUD!)
        criticalHUD!.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: criticalHUD!.hudWidth, height: 96))
        }
        delay(1.5) {
            self.criticalHUD?.removeFromSuperview()
            self.criticalHUD = nil
        }
    }
}

protocol GameNewCriticalViewDelegate: class {

    func didQuestionClick()

    func didCanceledCrit()

    func didConfirmedCrit(critCount: Int)
}
