import UIKit

// 左上角状态视图
class GameNewStatusView: UIView {

    var realTimeInfo: UserRoomUpdatedEnvelope.RealTimeInfo? {
        didSet {
            if let realTimeInfo = realTimeInfo, let usedInfo = realTimeInfo.usedInfo {
                if usedInfo.nickname == nil && usedInfo.avatar == nil {
                    self.playable = true
                } else {
                    self.nicknameLabel.text = usedInfo.nickname
                    self.actionLabel.text = realTimeInfo.notice
                    self.avatar.qu_setImageWithURL(URL(string: usedInfo.avatar ?? "")!)
                    if let avatarFrame = usedInfo.avatarFrame, let url = URL(string: avatarFrame) {
                        self.avatarFrame.qu_setImageWithURL(url)
                    }
                    self.playable = false
                }
            } else {
                self.playable = true
            }
        }
    }

    var playable: Bool = false {
        didSet {
            self.container.isHidden = playable
            self.avatar.isHidden = playable
            self.avatarFrame.isHidden = playable
            self.icon.isHidden = !playable
            self.statusLabel.isHidden = !playable
        }
    }

    lazy var icon: UIView = {
        let icon = UIView()
        icon.layer.cornerRadius = 8
        icon.layer.masksToBounds = true
        return icon
    }()

    lazy var avatar: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 18
        iv.layer.masksToBounds = true
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 2
        return iv
    }()

    lazy var avatarFrame = UIImageView()

    lazy var actionLabel = UILabel.with(textColor: UIColor.white, fontSize: 16)
    lazy var nicknameLabel = UILabel.with(textColor: UIColor.white, boldFontSize: 24)
    lazy var statusLabel = UILabel.with(textColor: UIColor.white, boldFontSize: 24, defaultText: "空闲中")
    lazy var container = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.layer.cornerRadius = 18
        self.layer.masksToBounds = true
        self.icon.backgroundColor = UIColor.UIColorFromRGB(0x00ff00)
        self.statusLabel.text = "空闲中"
        self.backgroundColor = .white

        let blackView = UIView.withBackgounrdColor(UIColor.UIColorFromRGB(0x0, alpha: 0.6))
        blackView.layer.cornerRadius = 16
        blackView.layer.masksToBounds = true
        self.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(2)
            make.right.bottom.equalToSuperview().offset(-2)
        }

        self.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalTo(self).offset(10)
            make.centerY.equalTo(self)
            make.size.equalTo(16)
        }

        statusLabel.textAlignment = .left
        self.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(8)
            make.centerY.equalTo(self)
            make.right.equalTo(self).offset(-10)
        }

        addSubview(avatar)
        avatar.snp.makeConstraints { make in
            make.left.equalTo(self)
            make.size.equalTo(36)
            make.centerY.equalTo(self)
        }

        addSubview(avatarFrame)
        avatarFrame.snp.makeConstraints { make in
            make.edges.equalTo(avatar)
        }

        addSubview(container)
        container.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(8)
            make.centerY.equalTo(self)
            make.right.equalTo(self).offset(-10)
        }

        container.addSubview(nicknameLabel)
        nicknameLabel.snp.makeConstraints { make in
            make.left.top.right.equalTo(container)
        }

        container.addSubview(actionLabel)
        actionLabel.snp.makeConstraints { make in
            make.bottom.equalTo(container)
            make.top.equalTo(nicknameLabel.snp.bottom).offset(4)
            make.centerX.equalTo(nicknameLabel)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
