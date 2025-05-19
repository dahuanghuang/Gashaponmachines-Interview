class GameNewCriticalHUD: UIView {

    /// 视图整体宽度
    var hudWidth: CGFloat {
        get {
            if let text = self.critLabel.text {
                return  120 + text.widthOfString(usingFont: UIFont.boldSystemFont(ofSize: 16))
            } else {
                return 120 + "暴击 × 1".widthOfString(usingFont: UIFont.boldSystemFont(ofSize: 16))
            }
        }
    }

    required convenience init(critCount: Int) {

        self.init(frame: .zero)
        critLabel.text = "暴击 × \(critCount)"
    }

    lazy var critLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32)

    override init(frame: CGRect) {
        super.init(frame: frame)

        let view1 = RoundedCornerView(corners: .allCorners, radius: 16, backgroundColor: UIColor.UIColorFromRGB(0xffffff).alpha(0.4))
        addSubview(view1)
        view1.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let view2 = RoundedCornerView(corners: .allCorners, radius: 12, backgroundColor: UIColor.UIColorFromRGB(0xffffff).alpha(0.6))
        view1.addSubview(view2)
        view2.snp.makeConstraints { make in
            make.top.left.equalTo(8)
            make.bottom.right.equalTo(-8)
        }

        let view3 = RoundedCornerView(corners: .allCorners, radius: 8, backgroundColor: UIColor.white)
        view2.addSubview(view3)
        view3.snp.makeConstraints { make in
            make.top.left.equalTo(8)
            make.bottom.right.equalTo(-8)
        }

        let content = RoundedCornerView(corners: .allCorners, radius: 8, backgroundColor: .qu_yellow)
        view3.addSubview(content)
        content.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(2)
            make.bottom.right.equalToSuperview().offset(-2)
        }

        let logo = UIImageView.with(imageName: "crit_logo_big")
        content.addSubview(logo)
        logo.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(48)
        }

        content.addSubview(critLabel)
        critLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.left.equalTo(logo.snp.right).offset(6)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
