import Foundation

protocol OccupyConfirmQuitViewControllerDelegate: class {

    func quitButtonDidTapped()
}

class OccupyConfirmQuitViewController: BaseViewController {

    weak var delegate: OccupyConfirmQuitViewControllerDelegate?

    weak var timer: Timer?

    var remainSecond: Int

    private let timerLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: "提示（）")

    init(remainSecond: Int) {
        self.remainSecond = remainSecond
        super.init(nibName: nil, bundle: nil)

        if timer != nil {
            stopTimer()
        }
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)

        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
    }

    private let desLabel: UILabel = {
        let label = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: "选择放弃霸机后将释放机台\n其他人可立即进入游戏")
        label.setLineSpacing(lineHeightMultiple: 1.5)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupView() {
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
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.center.equalTo(blackView)
            make.width.equalTo(280)
            make.height.equalTo(240)
        }

        let iv = UIImageView.with(imageName: "occupy_confirm_quit")
        contentView.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(-36)
            make.centerX.equalTo(contentView)
            make.size.equalTo(88)
        }

        contentView.addSubview(timerLabel)
        timerLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(iv.snp.bottom).offset(12)
        }

        contentView.addSubview(desLabel)
        desLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(timerLabel.snp.bottom).offset(20)
        }
        
        let continueRechargeButton = UIButton.with(title: "返回充值", titleColor: .qu_black, boldFontSize: 28)
        continueRechargeButton.layer.cornerRadius = 8
        continueRechargeButton.layer.masksToBounds = true
        continueRechargeButton.backgroundColor = UIColor(hex: "FFCC3E")
        continueRechargeButton.addTarget(self, action: #selector(continueRecharge), for: .touchUpInside)
        contentView.addSubview(continueRechargeButton)
        continueRechargeButton.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.bottom.equalTo(-12)
            make.height.equalTo(44)
        }
        
        let quitButton = UIButton.with(title: "放弃霸机", titleColor: .new_gray, fontSize: 28)
        quitButton.layer.cornerRadius = 8
        quitButton.layer.masksToBounds = true
        quitButton.layer.borderWidth = 2
        quitButton.layer.borderColor = UIColor(hex: "FFCC3E")!.cgColor
        quitButton.backgroundColor = .white
        quitButton.addTarget(self, action: #selector(quit), for: .touchUpInside)
        contentView.addSubview(quitButton)
        quitButton.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.left.equalTo(continueRechargeButton.snp.right).offset(8)
            make.bottom.size.equalTo(continueRechargeButton)
        }
    }

    @objc func updateTimerLabel() {
        remainSecond -= 1
        timerLabel.text = "提示(\(remainSecond)s)"

        if remainSecond <= 0 {
            // 自动放弃霸机(无需发送取消霸机消息)
            continueRecharge()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    // 手动放弃霸机(需要发送取消霸机消息)
    @objc func quit() {
        stopTimer()
        BugTrackService<UserTrackEvent>.writeEventToFile(event: .ComfirmCancelOccupy)
        dismiss(animated: true, completion: { [weak self] in
            self?.delegate?.quitButtonDidTapped()
        })
    }

    // 返回充值
    @objc func continueRecharge() {
        stopTimer()
        BugTrackService<UserTrackEvent>.writeEventToFile(event: .BackOccupyRecharge)
        dismiss(animated: true, completion: nil)
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
