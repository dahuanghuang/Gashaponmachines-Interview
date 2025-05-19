// 客服按钮
class GameNewReportButton: UIButton {

    lazy var icon = UIImageView.with(imageName: "game_n_report")

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 28, height: 24))
            make.center.equalToSuperview()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.roundCorners([.topLeft, .bottomLeft], radius: 8)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
