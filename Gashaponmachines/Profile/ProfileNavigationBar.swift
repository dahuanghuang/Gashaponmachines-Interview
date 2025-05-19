import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: ProfileNavigationBar {

    var settingButtonTap: ControlEvent<Void> {
        return self.base.settingButton.rx.tap
    }

    var messageButtonTap: ControlEvent<Void> {
        return self.base.messageButton.rx.tap
    }
}

class ProfileNavigationBar: UIView {
    
    var nameText: String = "" {
        didSet {
            self.nameLabel.text = nameText
        }
    }

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

    let settingIv = UIImageView(image: UIImage(named: "profile_setting_black"))

    let messageIv = UIImageView(image: UIImage(named: "profile_message_black"))

    let settingButton = UIButton()

    let messageButton = UIButton()
    
    let nameLabel = UILabel.with(textColor: .black, boldFontSize: 32)

    init() {
        super.init(frame: .zero)

        self.backgroundColor = .clear
        
        addSubview(settingIv)
        settingIv.snp.makeConstraints { (make) in
            make.top.equalTo(Constants.kStatusBarHeight + 8)
            make.right.equalTo(-12)
            make.size.equalTo(28)
        }

        addSubview(settingButton)
        settingButton.snp.makeConstraints { (make) in
            make.center.equalTo(settingIv)
            make.size.equalTo(40)
        }
        
        addSubview(messageIv)
        messageIv.snp.makeConstraints { (make) in
            make.top.equalTo(settingIv)
            make.right.equalTo(settingIv.snp.left).offset(-12)
            make.size.equalTo(28)
        }

        addSubview(messageButton)
        messageButton.snp.makeConstraints { (make) in
            make.center.equalTo(messageIv)
            make.size.equalTo(40)
        }
        
        nameLabel.isHidden = true
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalTo(messageIv)
        }

        badgeLabel.isHidden = true
        addSubview(badgeLabel)
    }

    public func setNavBlackGoldState() {
        settingIv.image = UIImage(named: "profile_setting_white")
        messageIv.image = UIImage(named: "profile_message_white")
    }

    /// 显示消息未读数
    public func showUnreadMessage(_ count: Int) {
        self.badgeLabel.isHidden = count == 0

        let textWidth = String(count).widthOfString(usingFont: UIFont.boldSystemFont(ofSize: 10))
        let width = count < 10 ? 14 : textWidth + 8
        badgeLabel.text = String(count)
        badgeLabel.frame = CGRect(x: messageIv.centerX, y: messageIv.top-7, width: width, height: 14)
        badgeLabel.layer.cornerRadius = 7
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
