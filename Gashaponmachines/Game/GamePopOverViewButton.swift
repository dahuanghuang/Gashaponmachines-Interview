class GamePopOverViewButton: UIButton {

    var type: GameStatusButtonType = .cancel

    var title: String = ""

    let titleLbl = UILabel.with(textColor: .qu_black, boldFontSize: 28)

    init(type: GameStatusButtonType, title: String) {
        super.init(frame: .zero)
        self.title = title
        self.type = type
        
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        if type == .cancel {
            self.backgroundColor = .white
            self.layer.borderWidth = 2
            self.layer.borderColor = UIColor(hex: "FFCC3E")!.cgColor
            titleLbl.textColor = .new_gray
        }else {
            self.backgroundColor = UIColor(hex: "FFCC3E")
            titleLbl.textColor = .black
        }
        
        titleLbl.text = title
        titleLbl.textAlignment = .center
        addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
