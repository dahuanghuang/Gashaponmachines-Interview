class CompositionDetailProgressView: UIView {

    lazy var progressLabel = UILabel.with(textColor: .qu_black, fontSize: 26)

//    lazy var lockLogo = UIImageView.with(imageName: "compo_detail_orange_lock")

    lazy var progressArrow = UIImageView.with(imageName: "compo_progress_arrow")

//    private lazy var yellowProgress: UIProgressView = {
//        let v =  UIProgressView(progressViewStyle: .default)
//        v.trackTintColor = .clear
//        v.progressTintColor = UIColor.UIColorFromRGB(0xffef5f)
////        v.progressTintColor = UIColor(hex: "ff7645")
//        v.backgroundColor = .clear
//        v.layer.sublayers?[1].masksToBounds = true
//        v.layer.sublayers?[1].cornerRadius = 10
//        v.layer.cornerRadius = 10
//        v.layer.masksToBounds = true
//        return v
//    }()

    private lazy var blueProgress: UIProgressView = {
        let v =  UIProgressView(progressViewStyle: .default)
        v.trackTintColor = UIColor.white
//        v.progressTintColor = UIColor.UIColorFromRGB(0x26bae5)
        v.progressTintColor = UIColor(hex: "ff7645")
        v.layer.sublayers?[1].masksToBounds = true
        v.layer.sublayers?[1].cornerRadius = 10
        v.layer.cornerRadius = 10
        v.layer.masksToBounds = true
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

//    	let bg = UIView.withBackgounrdColor(UIColor.compos_borderColor)
        let bg = UIView.withBackgounrdColor(UIColor(hex: "fff5de")!)
        bg.layer.cornerRadius = 44 / 2
        bg.layer.masksToBounds = true
        addSubview(bg)
        bg.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(20 + 24)
            make.width.equalTo(Constants.kScreenWidth - 40)
            make.bottom.equalToSuperview().offset(-24)
        }

        bg.addSubview(blueProgress)
        blueProgress.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.left.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.right.equalToSuperview().offset(-12)
        }

        bg.addSubview(progressLabel)
        progressLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(20)
        }

//        blueProgress.addSubview(yellowProgress)
//        yellowProgress.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }

//        yellowProgress.addSubview(lockLogo)
//        lockLogo.isHidden = true
//        lockLogo.snp.makeConstraints { make in
//            make.size.equalTo(16)
//            make.centerY.right.equalToSuperview()
//        }

        addSubview(progressArrow)
        progressArrow.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.size.equalTo(16)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        roundCorners(.allCorners, radius: 10)
    }

    var blueValue: Float = 0.0 {
        didSet {
            blueProgress.progress = blueValue

            self.progressArrow.snp.updateConstraints { make in
                make.left.equalToSuperview().offset(Float(Constants.kScreenWidth - 64) * blueValue + 5)
            }
        }
    }

//    var yellowValue: Float = 0.0 {
//        didSet {
//            yellowProgress.progress = yellowValue

//            lockLogo.snp.updateConstraints { make in
//                make.right.equalToSuperview().offset(Float(self.yellowProgress.width) * (yellowValue-1) - 4)
//            }

            // 如果是双数，到达中间为避免与进度文字重合，将小锁图标隐藏
//            if yellowValue.truncatingRemainder(dividingBy: 2) == 0 && (yellowValue == 0.0 || yellowValue == 0.5) {
//                lockLogo.isHidden = true
//            } else {
//                lockLogo.isHidden = false
//            }
//        }
//    }

    var progressValue: String? {
        didSet {
            progressLabel.text = progressValue
        }
    }
}
