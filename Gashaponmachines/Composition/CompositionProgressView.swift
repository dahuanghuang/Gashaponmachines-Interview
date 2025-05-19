class CompositionProgressView: UIView {

//    private lazy var yellowProgress: UIProgressView = {
//        let v =  UIProgressView(progressViewStyle: .default)
//        v.trackTintColor = .clear
//        v.progressTintColor = UIColor.UIColorFromRGB(0xffef5f)
//        v.backgroundColor = .clear
//        v.layer.sublayers?[1].masksToBounds = true
//        v.layer.sublayers?[1].cornerRadius = 4
//        return v
//    }()

    private lazy var blueProgress: UIProgressView = {
        let v =  UIProgressView(progressViewStyle: .default)
        v.trackTintColor = UIColor.viewBackgroundColor
//        v.progressTintColor = UIColor.UIColorFromRGB(0x26bae5)
        v.progressTintColor = UIColor(hex: "ff7645")
        v.layer.sublayers?[1].masksToBounds = true
        v.layer.sublayers?[1].cornerRadius = 4
        return v
    }()

    private lazy var progressLabel = UILabel.with(textColor: .qu_black, fontSize: 16)

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(blueProgress)
//        addSubview(yellowProgress)
        addSubview(progressLabel)

        blueProgress.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

//        yellowProgress.snp.makeConstraints { make in
//            make.edges.equalTo(self)
//        }

        progressLabel.snp.makeConstraints { make in
            make.height.equalTo(self)
            make.center.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        roundCorners(.allCorners, radius: 4)
    }

    var blueValue: Float = 0.0 {
        didSet {
            self.blueProgress.progress = blueValue
        }
    }

    var progressStr: String? {
        didSet {
            self.progressLabel.text = progressStr
        }
    }

//    var yellowValue: Float = 0.0 {
//        didSet {
//            self.yellowProgress.progress = yellowValue
//        }
//    }
}
