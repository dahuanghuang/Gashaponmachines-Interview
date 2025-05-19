import UIKit

class YFSLiveLookUserView: UIView {

    private let MaxCount = 5

    /// 头像数组 （最新进来的在最左边）， [4, 3, 2, 1, 0]
    fileprivate var avatarViewArray: [UIImageView] = []
    /// 头像框数组 （最新进来的在最左边）， [4, 3, 2, 1, 0]
    fileprivate var avatarFrameArray: [UIImageView] = []

    lazy var clientCountMaskView: UIView = {
        let maskView = UIView()
        maskView.isHidden = true
        maskView.backgroundColor = .qu_popBackgroundColor
        return maskView
    }()

    lazy var countLabel: UILabel = {
        let label = UILabel.with(textColor: .white, boldFontSize: 24)
        label.textAlignment = .center
        return label
    }()

    var playersCount: Int = 0 {
        didSet {
            self.clientCountMaskView.isHidden = playersCount < 6
            self.countLabel.isHidden = playersCount < 6
            self.countLabel.text = "\(playersCount)"
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        for i in 0...MaxCount-1 {

            let view = UIImageView()
            view.backgroundColor = .clear
            view.layer.cornerRadius = 18
            view.layer.masksToBounds = true
            view.layer.borderColor = UIColor.clear.cgColor
            view.layer.borderWidth = 2
            addSubview(view)

            view.snp.makeConstraints { make in
                make.right.equalTo(self).offset(-44 * i - 4)
                make.centerY.equalTo(self)
                make.size.equalTo(36)
            }

            if i == MaxCount - 1 {
                view.snp.makeConstraints { make in
                    make.left.equalTo(self).offset(4)
                }
            }

            if i == 0 {
                view.addSubview(clientCountMaskView)
                clientCountMaskView.snp.makeConstraints { make in
                    make.edges.equalTo(view)
                }

                clientCountMaskView.addSubview(countLabel)
                countLabel.snp.makeConstraints { make in
                    make.edges.equalTo(clientCountMaskView)
                }
            }

            let avatarFrame = UIImageView()
            addSubview(avatarFrame)
            avatarFrame.snp.makeConstraints { make in
                make.edges.equalTo(view)
            }

            avatarViewArray.append(view)
            avatarFrameArray.append(avatarFrame)
        }
    }

    func updatePlayersStatus(players: [User]?, count: Int?) {
        guard let users = players, let count = count else { return }
        self.playersCount = count
        if count < MaxCount {
            for i in count...MaxCount-1 {
                self.avatarViewArray[i].image = nil
                self.avatarViewArray[i].layer.borderColor = UIColor.clear.cgColor
            }
        }

        for i in 0..<avatarFrameArray.count {
            self.avatarFrameArray[i].image = nil
        }

        zip(users, self.avatarViewArray).forEach { pair in
            pair.1.layer.borderColor = UIColor.white.cgColor

            if let avatar = pair.0.avatar {
                pair.1.qu_setImageWithURL(URL(string: avatar)!)
            }
        }

        zip(users, self.avatarFrameArray).forEach { pair in
            if let avatarFrame = pair.0.avatarFrame, let url = URL(string: avatarFrame) {
                pair.1.qu_setImageWithURL(url)
            }
        }
    }

    deinit {
        self.avatarViewArray.forEach { iv in
            iv.cancelNetworkImageDownloadTask()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
