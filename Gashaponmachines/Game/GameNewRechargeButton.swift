import UIKit

//extension GameNewRechargeButton: GameComponentAction {
//
//    func on(state: Game.State) {
//        switch state {
//        case .ready: return
//            // 隐藏加号
//        default: return
//        }
//    }
//}

// 充值按钮
class GameNewRechargeButton: UIButton {

    fileprivate lazy var balanceLabel = UILabel.with(textColor: .black, boldFontSize: 24)
    fileprivate lazy var desLabel = UILabel.with(textColor: .new_middleGray, fontSize: 24, defaultText: "元气值:")

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true

        self.addSubview(desLabel)
        desLabel.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.centerY.equalToSuperview()
        }
        
        self.addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { make in
            make.left.equalTo(desLabel.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }

        let addIcon = UIImageView(image: UIImage(named: "game_recharge"))
        self.addSubview(addIcon)
        addIcon.snp.makeConstraints { make in
            make.right.equalTo(-8)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }
    }

    /// User join room event
    ///
    func configureWith(info: RoomInfoEnvelope?) {
        self.balanceLabel.text = info?.balance
    }

    var balance: String? {
        didSet {
            self.balanceLabel.text = balance
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
