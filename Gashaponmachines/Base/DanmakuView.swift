class DanmakuView: UIView {

    lazy var titleLabel = UILabel.with(textColor: .white, fontSize: 32)

    lazy var imageView = UIImageView()

    lazy var container = UIView.withBackgounrdColor(UIColor.UIColorFromRGB(0x000000, alpha: 0.6))

    lazy var avatar = UIImageView()

    lazy var avatarFrame = UIImageView()

    init(danmaku: UserDanmakuEnvelope, frame: CGRect) {

        let font = UIFont.withPixel(32)
        let titleLabelWidth = (danmaku.msg as NSString).size(withAttributes: [NSAttributedString.Key.font: font]).width

        super.init(frame: frame)
        addSubview(imageView)
        imageView.gas_setImageWithURL(danmaku.picture)
        imageView.frame = CGRect(x: 0, y: self.height / 2 - 40 / 2, width: 45, height: 40)

        addSubview(container)
        container.layer.cornerRadius = 32 / 2
        container.layer.masksToBounds = true
        container.frame = CGRect(x: imageView.right + 2, y: self.height / 2 - 32 / 2, width: titleLabelWidth + 57, height: 32)

        titleLabel.text = danmaku.msg
        container.addSubview(titleLabel)
        titleLabel.frame = CGRect(x: 16, y: container.height / 2 - 32 / 2, width: titleLabelWidth, height: 32)

        avatar.layer.cornerRadius = 25 / 2
        avatar.layer.masksToBounds = true
        avatar.gas_setImageWithURL(danmaku.avatar)
        container.addSubview(avatar)
        avatar.frame = CGRect(x: titleLabel.right + 12, y: container.height / 2 - 25 / 2, width: 25, height: 25)

        container.addSubview(avatarFrame)
        avatarFrame.frame = avatar.frame
        avatarFrame.gas_setImageWithURL(danmaku.avatarFrame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func start() {
        imageView.startAnimating()
    }

    func stop() {
        imageView.stopAnimating()
    }
}
