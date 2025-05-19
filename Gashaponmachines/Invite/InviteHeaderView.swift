import RxCocoa
import RxSwift

class InviteHeaderView: UIView {
    let iv = UIImageView()

    let nameLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32)

    let inviteStatusLabel = UILabel.with(textColor: .qu_black, fontSize: 28)

    var inviteButton: UIButton = {
        let inviteButton = UIButton()
        let totalStr = "+ 邀请好友得\(AppEnvironment.reviewKeyWord)"
        let string = NSMutableAttributedString(string: totalStr, attributes: [
            NSAttributedString.Key.font: UIFont.withBoldPixel(32),
            NSAttributedString.Key.foregroundColor: UIColor.white
            ])
        let range = totalStr.range(of: "+")!
        let nsRange = NSRange(range, in: totalStr)
        string.addAttributes([NSAttributedString.Key.font: UIFont.withBoldPixel(40)], range: nsRange)
        inviteButton.setAttributedTitle(string, for: .normal)
        inviteButton.setBackgroundColor(color: .qu_cyanGreen, forUIControlState: .normal)
        return inviteButton
    }()

    let numberView = InviteNumberView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let container = RoundedCornerView(corners: [.topLeft, .topRight], radius: 4)
        addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalTo(self).offset(71/2 + 16)
            make.width.equalTo(Constants.kScreenWidth - 16)
            make.left.equalTo(self).offset(8)
            make.right.equalTo(self).offset(-8)
            make.bottom.equalTo(self)
        }

        let roundBg = UIView.withBackgounrdColor(.white)
        roundBg.layer.cornerRadius = 71/2
        roundBg.layer.masksToBounds = true
        self.addSubview(roundBg)
        roundBg.snp.makeConstraints { make in
            make.top.equalTo(self).offset(16)
            make.centerX.equalTo(self)
            make.size.equalTo(71)
        }

        self.addSubview(iv)
        iv.layer.cornerRadius = (71-6)/2
        iv.layer.masksToBounds = true
        iv.snp.makeConstraints { make in
            make.center.equalTo(roundBg)
            make.size.equalTo(71-6)
        }

        container.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(iv.snp.bottom).offset(8)
            make.centerX.equalTo(container)
        }

        container.addSubview(inviteStatusLabel)
        inviteStatusLabel.snp.makeConstraints { make in
            make.centerX.equalTo(container)
            make.top.equalTo(nameLabel.snp.bottom).offset(16)
        }

        let label = UILabel.with(textColor: .qu_lightGray, fontSize: 24, defaultText: "我的邀请码")
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(inviteStatusLabel.snp.bottom).offset(60)
            make.centerX.equalTo(container)
        }

        let leftFlagView = UIImageView(image: UIImage(named: "invite_flag"))
        let rightFlagView = UIImageView(image: UIImage(named: "invite_flag"))
        container.addSubview(leftFlagView)
        leftFlagView.snp.makeConstraints { make in
            make.centerY.equalTo(label)
            make.right.equalTo(label.snp.left).offset(-24)
        }

        container.addSubview(rightFlagView)
        rightFlagView.snp.makeConstraints { make in
            make.centerY.equalTo(label)
            make.left.equalTo(label.snp.right).offset(24)
        }

        container.addSubview(numberView)
        numberView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(20)
            make.centerX.equalTo(container)
            make.height.equalTo(45)
            make.width.equalTo(InviteCodeCount * InviteCodeImageViewWidth + (InviteCodeCount-1) * InviteCodeImageViewPadding)
        }

        let desLabel = UILabel.with(textColor: .qu_lightGray, fontSize: 24, defaultText: "^ 邀请成功后双方均可获得\(AppEnvironment.reviewKeyWord)奖励 ^")
        container.addSubview(desLabel)
        desLabel.snp.makeConstraints { make in
            make.top.equalTo(numberView.snp.bottom).offset(20)
            make.centerX.equalTo(container)
        }

        container.addSubview(inviteButton)
        inviteButton.snp.makeConstraints { make in
            make.height.equalTo(49)
            make.left.equalTo(container).offset(20)
            make.right.equalTo(container).offset(-20)
            make.top.equalTo(desLabel.snp.bottom).offset(60)
            make.bottom.equalTo(container).offset(-36)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWithInfo(info: InvitationInfoEnvelope) {
        self.nameLabel.text = info.nickname
        self.numberView.inviteCodes = info.invitationCode

        let allStr = "已邀请 \(info.inviteCount) 人，获得 \(info.balanceCount) \(AppEnvironment.reviewKeyWord)"
        let string = NSMutableAttributedString(string: allStr)
        string.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.qu_orange], range: (allStr as NSString).range(of: "\(info.inviteCount)"))
        string.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.qu_orange], range: (allStr as NSString).range(of: "\(info.balanceCount)"))
        self.inviteStatusLabel.attributedText = string

        self.iv.gas_setImageWithURL(info.avatar)
    }

}

let InviteCodeImageViewWidth = 30

let InviteCodeImageViewPadding = 10

let InviteCodeCount = 7

class InviteNumberView: UIView {

    var inviteCodes: String? {
        didSet {
            if let codes = inviteCodes {
                zip(codeImageViews, Array(codes)).forEach { (iv, str) in
                    let string = String(str)
                    guard string.isInt else { return }
                    if let num = Int(string) {
                        let imageName = "invite_num_\(num)"
                        iv.image = UIImage(named: imageName)
                    }
                }
            }
        }
    }

    private var codeImageViews: [UIImageView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)

        for i in 0...InviteCodeCount - 1 {
            let iv = UIImageView()
            self.addSubview(iv)
            iv.snp.makeConstraints { make in
                make.width.equalTo(InviteCodeImageViewWidth)
                make.top.bottom.equalTo(self)
                make.centerY.equalTo(self)
            	make.left.equalTo(self).offset(i * (InviteCodeImageViewWidth + InviteCodeImageViewPadding))
                if i == InviteCodeCount - 1 {
                    make.right.equalTo(self)
                }
            }
            codeImageViews.append(iv)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
