import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {

    var profiles = [Profile]()

    var services = [UserService]()

    var buttons = [ProfileItemButton]()

    let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)

    var buttonTapHandle: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: .zero)

        self.backgroundColor = .white

        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true

        let titleView = UIView.withBackgounrdColor(.clear)
        contentView.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(40)
        }

        titleView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(12)
        }
    }

    func configureWith(profiles: [Profile], row: Int) {
        clean()

        self.profiles = profiles

        switch row {
        case 0:
            titleLabel.text = "我的订单"
        case 1:
            titleLabel.text = "我的记录"
        default:
            titleLabel.text = ""
        }

        setupProfileButtons()
    }

    func configureWith(services: [UserService]) {
        clean()

        self.services = services

        titleLabel.text = "其他服务"

        setupServiceButtons()
    }

    private func clean() {
        buttons.forEach { (button) in
            button.removeFromSuperview()
        }
        buttons.removeAll()
        profiles.removeAll()
        services.removeAll()
    }

    /// 第一行和第二行按钮
    private func setupProfileButtons() {

        let count = profiles.count
        // 每列个数
        let colCount = count == 3 ? 3 : 4

        let height: CGFloat = 90
        let width = count == 3 ? (Constants.kScreenWidth - 24)/3 : (Constants.kScreenWidth - 24)/4

        for index in 0...count-1 {
            // 列
            let col = CGFloat(index % colCount)
            // 行
            let row = CGFloat(index / colCount)

            let x = col * width
            let y = row * height + 40

            let button = ProfileItemButton(profile: profiles[index], service: nil)
            button.addTarget(self, action: #selector(profileButtonClick(button:)), for: .touchUpInside)
            button.tag = index
            button.frame = CGRect(x: x, y: y, width: width, height: height)
            contentView.addSubview(button)

            buttons.append(button)
        }
    }

    /// 第三行按钮
    private func setupServiceButtons() {

        let count = services.count

        let height: CGFloat = 80
        let width = (Constants.kScreenWidth - 24)/4

        for index in 0...count-1 {
//            let topMargin: CGFloat = (index <= 3 ? 40 : 48)
            // 列
            let col = CGFloat(index % 4)
            // 行
            let row = CGFloat(index / 4)

            let x = col * width
            let y = row * height + 40

            let button = ProfileItemButton(profile: nil, service: services[index])
            button.addTarget(self, action: #selector(serviceButtonClick), for: .touchUpInside)
            button.tag = index
            button.frame = CGRect(x: x, y: y, width: width, height: height)
            contentView.addSubview(button)

            buttons.append(button)
        }
    }

    @objc func profileButtonClick(button: ProfileItemButton) {
        if let handle = buttonTapHandle {
            handle(button.tag)
        }
    }

    @objc func serviceButtonClick(button: ProfileItemButton) {
        RouterService.route(to: services[button.tag].action)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ProfileItemButton: UIButton {
    let icon = UIImageView()

    var textLabel: UILabel = {
        let label = UILabel.with(textColor: .qu_black, fontSize: 28)
        label.preferredMaxLayoutWidth = Constants.kScreenWidth - 12
        label.numberOfLines = 1
        return label
    }()

    /// 红点
    var badgeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .red
        label.clipsToBounds = true
        return label
    }()

    init(profile: Profile?, service: UserService?) {
        super.init(frame: .zero)

        self.backgroundColor = .clear

        self.addSubview(icon)
        icon.snp.makeConstraints { (make) in
            make.top.equalTo(12)
            make.centerX.equalToSuperview()
            if profile == nil {
                make.size.equalTo(36)
            }
        }

        self.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.top.equalTo(icon.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        badgeLabel.isHidden = true
        self.addSubview(badgeLabel)

        if let profile = profile {
            icon.image = UIImage(named: profile.iconImageName)
            textLabel.text = profile.rawValue
        }

        if let service = service {
            icon.gas_setImageWithURL(service.icon)
            textLabel.text = service.title
            if let mark = service.mark {
                badgeLabel.text = service.mark
                badgeLabel.layer.cornerRadius = 7
                badgeLabel.isHidden = false
                let textWidth = mark.widthOfString(usingFont: UIFont.boldSystemFont(ofSize: 10)) + 8
                let width = textWidth < 14 ? 14 : textWidth
                badgeLabel.snp.makeConstraints { (make) in
                    make.left.equalTo(icon.snp.right).offset(-8)
                    make.bottom.equalTo(icon)
                    make.height.equalTo(14)
                    make.width.equalTo(width)
                }
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
