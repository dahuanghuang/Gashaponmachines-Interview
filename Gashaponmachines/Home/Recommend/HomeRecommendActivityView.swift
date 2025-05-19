import UIKit

class HomeRecommendActivityView: UIView {

    var icons = [HomeIcon]() {
        didSet {
            self.setupIcons(icons: self.icons)
        }
    }

    private var iconIvs = [UIImageView]()

    private var nameLabels = [UILabel]()

    private let buttonCount = 5

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    private func setupUI() {

        self.backgroundColor = .new_backgroundColor

//        let titles = ["黑金周榜", "最新攻略", "邀请送", "充值送", "合成系统"]
        let buttonW = self.width / 5
        let iconW: CGFloat = 36
        let buttonMargin = (self.width - iconW * CGFloat(buttonCount)) / CGFloat(buttonCount)

        for index in 0..<buttonCount {
            let buttonX = buttonMargin/2 + (iconW + buttonMargin) * CGFloat(index)
            let iconIv = UIImageView()
            self.addSubview(iconIv)
            iconIvs.append(iconIv)
            iconIv.snp.makeConstraints { (make) in
                make.size.equalTo(iconW)
                make.top.equalTo(24)
                make.left.equalTo(buttonX)
            }

            let nameLabel = UILabel.with(textColor: .qu_black, fontSize: 24)
            nameLabel.textAlignment = .center
            self.addSubview(nameLabel)
            nameLabels.append(nameLabel)
            nameLabel.snp.makeConstraints { (make) in
                make.top.equalTo(iconIv.snp.bottom).offset(8)
                make.centerX.equalTo(iconIv)
            }

            let actionButton = UIButton()
            actionButton.addTarget(self, action: #selector(actionButtonClick(button:)), for: .touchUpInside)
            actionButton.tag = index
            self.addSubview(actionButton)
            actionButton.snp.makeConstraints { (make) in
                make.centerX.equalTo(iconIv)
                make.centerY.equalToSuperview()
                make.size.equalTo(buttonW)
            }

        }
    }

    func setupIcons(icons: [HomeIcon]) {
        if icons.count > 5 {
            var newIcons = [HomeIcon]()
            for index in 0...4 {
                newIcons.append(icons[index])
            }
            self.icons.removeAll()
            self.icons = newIcons
        }

        if icons.count == 5 {
            for index in 0..<icons.count {
                let icon = icons[index]
                let iconIv = iconIvs[index]
                let nameLabel = nameLabels[index]
                iconIv.gas_setImageWithURL(icon.image)
                nameLabel.text = icon.title
            }
        }
    }

    @objc func actionButtonClick(button: UIButton) {
        if !icons.isEmpty {
            RouterService.route(to: icons[button.tag].action)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
