import UIKit
import RxCocoa
import RxSwift
import SnapKit

let ProfileHeadViewId = "ProfileHeadViewId"
let ProfileSectionViewId = "ProfileSectionViewId"

extension Reactive where Base: ProfileHeaderView {

    var rechargeButtonTap: ControlEvent<Void> {
        return self.base.rechargeButton.rx.tap
    }

    var exchangeButtonTap: ControlEvent<Void> {
        return self.base.exchangeButton.rx.tap
    }

    var upgradeTap: ControlEvent<Void> {
        return self.base.vipButton.rx.tap
    }
}

class ProfileHeaderView: UICollectionReusableView {
    // header高度
//    static let headerViewH = Constants.kStatusBarHeight + 300
    static let headerViewH = Constants.kStatusBarHeight + 188 + (Constants.kScreenWidth-24)*0.35

    // MARK: - Property
    /// 普通用户
    let normalBgIv = UIImageView(image: UIImage(named: "profile_background_normal"))
    /// 黑金卡用户
    let blackBgIv = UIImageView(image: UIImage(named: "profile_background_black"))

    /// 消息未读数
    lazy var badgeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .red
        label.clipsToBounds = true
        return label
    }()

    /// 头像
    lazy var avatarView: UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarClick)))
        iv.layer.cornerRadius = 35
        iv.layer.masksToBounds = true
        return iv
    }()
    /// 头像框
    let avatarFrameView = UIImageView()
    
    let nicknameLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32)
    
    let userIdLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)
    
    let vipIv = UIImageView(image: UIImage(named: "profile_vip_yellow"))
    
    let vipButton = UIButton()

    lazy var levelLabel: UILabel = {
        let label = UILabel.with(textColor: .qu_black, boldFontSize: 24)
        label.textAlignment = .center
        return label
    }()

    lazy var experienceLabel: UILabel = {
        let label = UILabel.with(textColor: .qu_black, fontSize: 16)
        label.textAlignment = .left
        return label
    }()

    lazy var experienceView: UIView = {
        let view = UIView.withBackgounrdColor(.white)
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var experienceProgressLayer: CAGradientLayer = {
        let ly = CAGradientLayer()
        ly.cornerRadius = 3
        ly.colors = [UIColor(hex: "FF602E")!.cgColor, UIColor(hex: "FFAB2E")!.cgColor]
        ly.startPoint = CGPoint(x: 0, y: 0.5)
        ly.endPoint = CGPoint(x: 1, y: 0.5)
        return ly
    }()

    /// img1
    lazy var mouthCardIv1: UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bannerTap)))
        return iv
    }()
    /// img
    let mouthCardIv: UIImageView = {
            let iv = UIImageView()
            iv.isUserInteractionEnabled = false
            return iv
    }()
    /// icon
    let mouthCardIcon: UIImageView = {
            let iv = UIImageView()
            iv.isUserInteractionEnabled = false
            return iv
    }()
    /// 月卡描述1
    let mouthCardDescLb: UILabel = UILabel.with(textColor: .new_bgYellow, boldFontSize: 24)

    lazy var rechargeButton = ProfileImageTitleButton(type: .recharge)

    lazy var exchangeButton = ProfileImageTitleButton(type: .exchange)

    var banner: UserBanner?

    var info: UserInfo?

    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: .zero)

        self.backgroundColor = .viewBackgroundColor

        addSubview(normalBgIv)
        normalBgIv.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + 183)
        }
        
        blackBgIv.isHidden = true
        addSubview(blackBgIv)
        blackBgIv.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + 212)
        }

        badgeLabel.isHidden = true
        addSubview(badgeLabel)

        addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalToSuperview().offset(16 + Constants.kStatusBarHeight)
            make.size.equalTo(70)
        }

        addSubview(avatarFrameView)
        avatarFrameView.snp.makeConstraints { make in
            make.edges.equalTo(avatarView)
        }
        
        addSubview(nicknameLabel)
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.top).offset(14)
            make.left.equalTo(avatarView.snp.right).offset(8)
        }
        
        addSubview(vipIv)
        vipIv.snp.makeConstraints { make in
            make.left.equalTo(nicknameLabel.snp.right).offset(6)
            make.centerY.equalTo(nicknameLabel)
            make.width.equalTo(25)
            make.height.equalTo(12)
        }
        
        addSubview(vipButton)
        vipButton.snp.makeConstraints { make in
            make.left.equalTo(nicknameLabel.snp.right)
            make.centerY.equalTo(nicknameLabel)
            make.right.equalTo(vipIv)
            make.height.equalTo(24)
        }

        addSubview(userIdLabel)
        userIdLabel.snp.makeConstraints { make in
            make.left.equalTo(nicknameLabel)
            make.bottom.equalTo(avatarView).offset(-14)
        }

        addSubview(levelLabel)
        levelLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.bottom).offset(4)
            make.left.right.equalTo(avatarView)
            make.height.equalTo(16)
        }

        addSubview(experienceView)
        experienceView.snp.makeConstraints { make in
            make.left.equalTo(nicknameLabel)
            make.centerY.equalTo(levelLabel)
            make.height.equalTo(6)
            make.width.equalTo(127)
        }

        experienceView.layer.addSublayer(experienceProgressLayer)
        
        addSubview(experienceLabel)
        experienceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(levelLabel)
            make.left.equalTo(experienceView.snp.right).offset(4)
        }
        
        addSubview(mouthCardIv1)
        mouthCardIv1.snp.makeConstraints { (make) in
            make.top.equalTo(Constants.kStatusBarHeight + 114)
            make.left.equalTo(12)
            make.right.equalTo(-12)
//            make.height.equalTo(114)
            make.height.equalTo(mouthCardIv1.snp.width).multipliedBy(0.35)
        }
        
        addSubview(mouthCardIv)
        mouthCardIv.snp.makeConstraints { (make) in
            make.edges.equalTo(mouthCardIv1)
        }

        addSubview(mouthCardIcon)
        mouthCardIcon.snp.makeConstraints { (make) in
            make.edges.equalTo(mouthCardIv1)
        }

        addSubview(mouthCardDescLb)
        mouthCardDescLb.snp.makeConstraints { (make) in
            make.left.equalTo(mouthCardIv1).offset(12)
            make.bottom.equalTo(mouthCardIv1).offset(-42)
        }
        
        let cornerView = RoundedCornerView(corners: .allCorners, radius: 12)
        addSubview(cornerView)
        cornerView.snp.makeConstraints { make in
            make.top.equalTo(mouthCardIv1.snp.bottom).offset(-26)
            make.left.right.equalTo(mouthCardIv1)
            make.height.equalTo(88)
        }
        
        let line = UIView.withBackgounrdColor(.new_lightGray.alpha(0.4))
        cornerView.addSubview(line)
        line.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(28)
        }

        cornerView.addSubview(rechargeButton)
        rechargeButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
        }

        cornerView.addSubview(exchangeButton)
        exchangeButton.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.left.equalTo(rechargeButton.snp.right).offset(8)
            make.width.equalTo(rechargeButton)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    public func configureWith(userInfo: UserInfo?, banner: UserBanner?) {
        self.info = userInfo
        self.banner = banner
        if let info = userInfo {
            avatarView.gas_setImageWithURL(info.avatar)
            avatarFrameView.gas_setImageWithURL(info.avatarFrame)
            nicknameLabel.text = info.nickname
            userIdLabel.text = "ID: \(info.uid)"

            if let isVIP = info.isNDVip {
                if info.isBlackGold == "1" {
                    vipIv.image = UIImage(named: "profile_vip_black")
                    self.setBlackGoldState()
                } else {
                    vipIv.image = UIImage(named: "profile_vip_yellow")
                }
                if isVIP == "1" { // 是VIP
                    vipIv.image = UIImage(named: "profile_vip")
                }
            }

            levelLabel.text = "Lv:\(info.expLevel)"
            experienceLabel.text = info.expText

            if let experienceProgress = Double(info.expProgress) {
                experienceProgressLayer.frame = CGRect(x: 0, y: 0, width: 127*experienceProgress, height: 6)
            }

            mouthCardIv1.gas_setImageWithURL(banner?.img1)
            mouthCardIv.gas_setImageWithURL(banner?.img)
            mouthCardIcon.gas_setImageWithURL(banner?.icon)
            mouthCardDescLb.text = banner?.notice1

            rechargeButton.value = info.balance
            exchangeButton.value = info.eggPoint
        }
    }

    func setBlackGoldState() {
        normalBgIv.isHidden = true
        blackBgIv.isHidden = false
        nicknameLabel.textColor = .white
        userIdLabel.textColor = .white
        levelLabel.textColor = .white
        experienceLabel.textColor = .white
    }

    // MARK: - Target Action
    @objc func bannerTap() {
        RouterService.route(to: self.banner?.action)
    }

    @objc func avatarClick() {
        RouterService.route(to: self.info?.userLevelLink)
    }
}

class ProfileSectionView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: .zero)

        self.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
