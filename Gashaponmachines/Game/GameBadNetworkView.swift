import UIKit

class GameNetworkStateView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {

        self.backgroundColor = .black.alpha(0.3)
        self.layer.cornerRadius = 8

        let stateIv = UIImageView(image: UIImage(named: "game_network_state"))
        self.addSubview(stateIv)
        stateIv.snp.makeConstraints { make in
            make.left.equalTo(7)
            make.centerY.equalToSuperview()
            make.size.equalTo(17)
        }

        let stateLabel = UILabel.with(textColor: .white, fontSize: 24, defaultText: "网络状态差, 通信可能会延迟")
        stateLabel.textAlignment = .left
        self.addSubview(stateLabel)
        stateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(stateIv.snp.right).offset(4)
            make.centerY.height.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
        }
    }
}
