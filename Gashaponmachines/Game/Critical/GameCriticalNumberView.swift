import Lottie

class GameNewCriticalNumberView: UIView {

    lazy var animView: AnimationView = {
        let v = AnimationView(name: "data", bundle: LottieConfig.CritCritingBundle)
        v.loopMode = .loop
        return v
    }()

    lazy var leftNum: UIImageView = UIImageView()

    lazy var midNum: UIImageView = UIImageView()

    lazy var rightNum: UIImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(animView)
        animView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.size.equalTo(150/2)
        }

        let multiple = UIImageView.with(imageName: "crit_num_x")
        addSubview(multiple)
        multiple.snp.makeConstraints { make in
            make.width.equalTo(14)
            make.height.equalTo(18)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalTo(animView.snp.right).offset(-24)
        }

        addSubview(leftNum)
        leftNum.snp.makeConstraints { make in
            make.left.equalTo(multiple.snp.right)
            make.height.equalTo(18)
            make.width.equalTo(16)
            make.bottom.equalTo(multiple)
        }

        addSubview(midNum)
        midNum.snp.makeConstraints { make in
            make.left.equalTo(leftNum.snp.right)
            make.height.equalTo(18)
            make.width.equalTo(16)
            make.bottom.equalTo(multiple)
        }

        addSubview(rightNum)
        rightNum.snp.makeConstraints { make in
            make.left.equalTo(midNum.snp.right)
            make.height.equalTo(18)
            make.width.equalTo(16)
            make.bottom.equalTo(multiple)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var critCount: Int = 0 {
        didSet {
            let numStr = String(critCount)
            let array = Array(numStr)

            if numStr.count == 1 {
                leftNum.image = UIImage(named: "crit_num_\(numStr)")
                rightNum.image = nil
                midNum.image = nil
            } else if numStr.count == 2 {
                leftNum.image = UIImage(named: "crit_num_\(array[0])")
                rightNum.image = nil
                midNum.image = UIImage(named: "crit_num_\(array[1])")
            } else if numStr.count == 3 {
                leftNum.image = UIImage(named: "crit_num_\(array[0])")
                rightNum.image = UIImage(named: "crit_num_\(array[2])")
                midNum.image = UIImage(named: "crit_num_\(array[1])")
            } else {
                leftNum.image = UIImage(named: "crit_num_9")
                rightNum.image = UIImage(named: "crit_num_9")
                midNum.image = UIImage(named: "crit_num_9")
            }
        }
    }

    func play() {
        animView.play()
    }

    func stop() {
        animView.stop()
    }
}
