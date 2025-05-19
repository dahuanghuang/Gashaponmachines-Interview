class IndexReconnectingView: UIView {

    let timeout: TimeInterval = 2

    let imageView = UIImageView(image: UIImage(named: "index_conneting"))

    var titleLabel = UILabel.with(textColor: .white, fontSize: 24, defaultText: "正在连接机台，请稍候...")

    init() {

        super.init(frame: .zero)
        self.backgroundColor = UIColor.UIColorFromRGB(0x3a3a3a, alpha: 0.9)

        let container = UIView()

        self.isHidden = true
        self.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.bottom.centerX.equalTo(self)
        }

        container.addSubview(imageView)
        container.addSubview(titleLabel)

        imageView.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(35)
            make.centerY.equalTo(container)
            make.left.equalTo(container)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(12)
            make.centerY.equalTo(container)
            make.right.equalTo(container)
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        roundCorners(.allCorners, radius: 4)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        self.isHidden = false
    }

    func hide() {
        self.isHidden = true
    }
}
