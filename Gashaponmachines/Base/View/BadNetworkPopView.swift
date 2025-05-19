import UIKit

enum BadNetworkPopViewType {
    // 网络异常
    case badNetwork
    // 机台故障
    case machineError
}

/// 网络断开连接弹窗
class BadNetworkPopView: UIWindow {

    var type: BadNetworkPopViewType = .badNetwork {
        didSet {
            if type == .badNetwork {
                self.titleLb.text = "网络不佳"
                self.descLb.text = "机台连接中断，若要继续游戏请快速回到机台中"
            } else {
                self.titleLb.text = "无法进入房间"
                self.descLb.text = "网络异常，请稍后重试"
            }
        }
    }

    var confirmTapHandle: (() -> Void)?

    let titleLb = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: "网络不佳")
    let descLb = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: "机台连接中断，若要继续游戏请快速回到机台中")
    let confirmBtn = UIButton.with(title: "好的", titleColor: .qu_black, boldFontSize: 28)

    init() {
        super.init(frame: .zero)

        self.windowLevel = .normal
        self.makeKeyAndVisible()

        self.isHidden = true

        setupUI()
    }

    func setupUI() {
        self.backgroundColor = .qu_popBackgroundColor

        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(280)
        }

        let iconIv = UIImageView(image: UIImage(named: "game_n_bad_network"))
        iconIv.centerX = contentView.width/2
        contentView.addSubview(iconIv)
        iconIv.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(-44)
            make.left.right.equalToSuperview()
            make.height.equalTo(114)
        }

        contentView.addSubview(titleLb)
        titleLb.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(iconIv.snp.bottom).offset(4)
        }

        descLb.numberOfLines = 0
        descLb.setLineSpacing(lineHeightMultiple: 1.5)
        descLb.textAlignment = .center
        contentView.addSubview(descLb)
        descLb.snp.makeConstraints { (make) in
            make.top.equalTo(titleLb.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
            make.left.equalTo(24)
            make.right.equalTo(-24)
        }

        confirmBtn.addTarget(self, action: #selector(confirmClick), for: .touchUpInside)
        confirmBtn.setBackgroundColor(color: UIColor(hex: "FFCC3E")!, forUIControlState: .normal)
        confirmBtn.layer.cornerRadius = 8
        confirmBtn.layer.masksToBounds = true
        contentView.addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { (make) in
            make.top.equalTo(descLb.snp.bottom).offset(28)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    @objc func confirmClick() {
        self.isHidden = true
        if let handle = confirmTapHandle {
            handle()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
