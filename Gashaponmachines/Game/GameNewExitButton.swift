// 退出按钮
class GameNewExitButton: UIButton {

    lazy var icon = UIImageView.with(imageName: "game_n_exit")

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .qu_cyanGreen

        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 28, height: 24))
            make.center.equalToSuperview()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.roundCorners([.topRight, .bottomRight], radius: 8)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
