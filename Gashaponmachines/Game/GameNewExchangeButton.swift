extension GameNewExchangeButton: GameComponentAction {

    func on(state: Game.State) {
        switch state {
        case .ready:
            isHidden = true
        case .err, .reset:
            isHidden = false
        default: return
        }
    }
}

// 最高奖赏视图
class GameNewExchangeButton: UIButton {

    lazy var icon: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 8
        iv.layer.masksToBounds = true
        return iv
    }()

    fileprivate lazy var titleLbl: UILabel = {
        let lb = UILabel.numberFont(size: 16)
        lb.textColor = .black
        return lb
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor(hex: "FFCC3E")
        self.layer.cornerRadius = 14
        
        let contentView = UIView.withBackgounrdColor(.white)
        contentView.layer.cornerRadius = 12
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.left.equalTo(2)
            make.right.bottom.equalTo(-2)
        }

        // 奖品图
        contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.left.equalTo(4)
            make.bottom.equalTo(-4)
            make.width.equalTo(icon.snp.height)
        }
    
        // 蛋壳图
        let valueIv = UIImageView(image: UIImage(named: "game_value"))
        contentView.addSubview(valueIv)
        valueIv.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }

        // 蛋壳值
        contentView.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.right.equalTo(valueIv.snp.left).offset(-4)
            make.centerY.equalTo(valueIv).offset(1)
        }
        
        // 最高赏图
        let rewardIv = UIImageView(image: UIImage(named: "game_first_reward"))
        self.addSubview(rewardIv)
        rewardIv.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.top.equalTo(-4)
            make.width.equalTo(70)
            make.height.equalTo(25)
        }
    }

    func configureWith(info: RoomInfoEnvelope?) {
        icon.gas_setImageWithURL(info?.luckyEggImage)
        self.titleLbl.text = info?.luckyEggWorth
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
