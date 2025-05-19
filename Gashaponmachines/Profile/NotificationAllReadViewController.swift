import Foundation

class NotificationAllReadViewController: BaseViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }

    private let desLabel: UILabel = UILabel.with(textColor: .black, fontSize: 28, defaultText: "是否全部标为已读")

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let confirmButton = UIButton.yellowBackgroundButton(title: "是的", boldFontSize: 24)
    let cancelButton = UIButton.whiteBackgroundYellowRoundedButton(title: "取消", boldFontSize: 24)

    fileprivate func setupView() {
        self.view.backgroundColor = .clear
        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        blackView.tag = 440
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        let contentView = UIView()
        let contentHeight = 152
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.tag = 441
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.center.equalTo(blackView)
            make.height.equalTo(contentHeight)
        }

        contentView.addSubview(desLabel)
        desLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(contentView)
            make.height.equalTo(88)
        }

        let buttonWidth = (280 - 12 * 3) / 2
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(desLabel.snp.bottom)
            make.size.equalTo(CGSize(width: buttonWidth, height: 48))
            make.bottom.equalTo(contentView).offset(-16)
            make.left.equalTo(contentView).offset(12)
        }

        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(confirmButton)
            make.size.equalTo(CGSize(width: buttonWidth, height: 48))
            make.bottom.equalTo(contentView).offset(-16)
            make.right.equalTo(contentView).offset(-12)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
