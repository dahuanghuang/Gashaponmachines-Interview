import UIKit

//  网络重连弹窗
class YFSLiveNetReconnectionView: UIView {

    /// 重连回调
    var reconnectCallback : (() -> Void)?

    let reconnectButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "重连", fontSize: 28)

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setupUI()
    }

    func setupUI() {

        self.isHidden = true

        self.backgroundColor = UIColor.black.alpha(0.6)

        // 白色视图
        let contentView = UIView.withBackgounrdColor(.white)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.height.equalTo((176+96+24)/2)
            make.center.equalToSuperview()
        }

        // 提示
        let titleLabel = UILabel()
        titleLabel.textColor = .qu_black
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textAlignment = .center
        titleLabel.text = "网络无法连接，需要重连"
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(176/2)
            make.top.left.right.equalToSuperview()
        }

        // 取消
        let cancelButton = UIButton.blackTextWhiteBackgroundYellowRoundedButton(title: "取消", fontSize: 28)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.height.equalTo(48)
            make.width.equalTo(122)
            make.top.equalTo(titleLabel.snp.bottom)
        }

        // 重连
        reconnectButton.addTarget(self, action: #selector(reconnect), for: .touchUpInside)
        contentView.addSubview(reconnectButton)
        reconnectButton.snp.makeConstraints { make in
            make.size.top.equalTo(cancelButton)
            make.left.equalTo(cancelButton.snp.right).offset(12)
        }
    }

    @objc func cancel() {
//        self.removeFromSuperview()
        self.isHidden = true
    }

    @objc func reconnect() {
        if let callback = self.reconnectCallback {
            callback()
        }
//        self.removeFromSuperview()
        self.isHidden = true
    }

    func show() {
        self.isHidden = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
