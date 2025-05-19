extension GameNewIdleButton: GameComponentAction {

    func on(state: Game.State) {
        switch state {
        case .ready, .reset:
            isEnabled = false
        case .err:
            isEnabled = true
        default: return
        }
    }
}

/// 开始扭蛋按钮
class GameNewIdleButton: UIButton {

    let gameStartImage = UIImage(named: "game_n_start")

    let gameDisableImage = UIImage(named: "game_n_start_disable")

    let gameStartedImage = UIImage(named: "game_n_started")

    var price: String? {
        didSet {
            self.priceLabel.text = price
            self.valueIv.isHidden = false
            if price == "0" {
                self.priceLabel.text = "免元气不放入蛋槽"
                iv.image = isEnabled ? gameStartImage : gameDisableImage
                self.valueIv.isHidden = true
            }
        }
    }

    override var isEnabled: Bool {
        didSet {
            iv.image = isEnabled ? gameStartImage : gameDisableImage
            priceLabel.textColor = isEnabled ? UIColor.UIColorFromRGB(0xFF4B6B) : .new_middleGray
            priceLabel.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(isEnabled ? -20 : -15)
            }
            valueIv.image = isEnabled ? UIImage(named: "game_n_value_enable") : UIImage(named: "game_n_value_disable")
        }
    }

    lazy var iv = UIImageView(image: gameStartImage)

    lazy var priceLabel = UILabel.with(textColor: UIColor.UIColorFromRGB(0xFF4B6B), boldFontSize: 20)
    
    let valueIv = UIImageView(image: UIImage(named: "game_n_value_enable"))

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(iv)
        iv.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        priceLabel.textAlignment = .center
        iv.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-7)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(16)
        }
        
        iv.addSubview(valueIv)
        valueIv.snp.makeConstraints { make in
            make.centerY.equalTo(priceLabel)
            make.left.equalTo(priceLabel.snp.right).offset(2)
            make.size.equalTo(12)
        }

        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchCancel), for: [.touchUpInside, .touchCancel, .touchDragExit])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func enable() {
        isEnabled = true
    }

    func disable() {
        isEnabled = false
    }

    @objc func touchDown() {
        self.iv.image = gameStartedImage
        priceLabel.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(-15)
        }
    }

    @objc func touchCancel() {
        self.iv.image = gameStartImage
        priceLabel.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
        }
    }
}
