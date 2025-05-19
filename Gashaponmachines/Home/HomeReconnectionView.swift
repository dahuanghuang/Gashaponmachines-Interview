import UIKit

class HomeReconnectionView: UIView {

    var reconnectHandle: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        let contentView = UIView.withBackgounrdColor(.white)
        self.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        let reconnectLabel = UILabel.with(textColor: .qu_lightGray, fontSize: 28, defaultText: "网络状态待提升, 点击重试")
        contentView.addSubview(reconnectLabel)
        reconnectLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }

        let reconnectIv = UIImageView(image: UIImage(named: "home_reconnect"))
        contentView.addSubview(reconnectIv)
        reconnectIv.snp.makeConstraints { (make) in
            make.bottom.equalTo(reconnectLabel.snp.top).offset(-12)
            make.centerX.equalToSuperview()
            make.size.equalTo(150)
        }

        let reconnectBtn = UIButton.with(title: "重新连接", titleColor: .black, fontSize: 28)
        reconnectBtn.addTarget(self, action: #selector(reconnect), for: .touchUpInside)
        reconnectBtn.backgroundColor = .qu_yellow
        reconnectBtn.layer.cornerRadius = 4
        contentView.addSubview(reconnectBtn)
        reconnectBtn.snp.makeConstraints { (make) in
            make.top.equalTo(reconnectLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(36)
        }
    }

    @objc func reconnect() {
        if let handle = reconnectHandle {
            handle()
        }
    }
}
