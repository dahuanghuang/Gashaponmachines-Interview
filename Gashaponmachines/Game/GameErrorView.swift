class GameErrorView: DimBackgroundView {

    fileprivate lazy var imageview = UIImageView(image: UIImage(named: "game_error"))

    fileprivate lazy var titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: "扭蛋机可能发生了些问题")

    fileprivate lazy var desLabel: UILabel = {
        let label = UILabel.with(textColor: .qu_black, fontSize: 24)
        label.setLineSpacing(lineHeightMultiple: 1.5)
        label.preferredMaxLayoutWidth = 280 - 56
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    lazy var closeButton: UIButton = {
        let button = UIButton.with(title: "好的", titleColor: .black, boldFontSize: 28)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.backgroundColor = .new_yellow
        return button
    }()

    fileprivate lazy var contentView = RoundedCornerView(corners: .allCorners, radius: 12, backgroundColor: .white)

    convenience init(title: String?, msg: String?) {
        self.init(frame: .zero)
        if let t = title {
            titleLabel.text = t
        }
        desLabel.text = msg
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.center.equalToSuperview()
        }

        contentView.addSubview(titleLabel)
        titleLabel.textAlignment = .center
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(50)
        }

        contentView.addSubview(imageview)
        imageview.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(152)
        }

        contentView.addSubview(desLabel)
        desLabel.snp.makeConstraints { make in
            make.top.equalTo(imageview.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        contentView.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(hide), for: .touchUpInside)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(desLabel.snp.bottom).offset(20)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(44)
            make.bottom.equalTo(contentView).offset(-12)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func hide() {
        removeFromSuperview()
    }
}
