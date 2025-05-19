import UIKit.UIControl

class GameNewCriticalActionView: UIView {

    /// 暴击个数
    var critCount: Int = 1

    var powerInfo: PowerInfo? {
        didSet {
            if let canCritCount = powerInfo?.canCritCount {
                self.critCount = canCritCount
                self.layoutContentViews(canCritCount: canCritCount)
            }
        }
    }

    override var isHidden: Bool {
        didSet {
            if isHidden {
                BugTrackService<UserTrackEvent>.writeEventToFile(event: .HiddenAction)
            } else {
                BugTrackService<UserTrackEvent>.writeEventToFile(event: .ShowAction)
            }
        }
    }
    
    
    /// 背景视图
    let bgIv = UIImageView(image: UIImage(named: "crit_action_bg_one"))
    /// 取消按钮
    lazy var cancelButton: UIButton = {
        let btn = UIButton.with(title: "取消", titleColor: UIColor(hex: "D29F26")!, fontSize: 24)
        btn.backgroundColor = UIColor(hex: "FFF7C6")
        btn.layer.cornerRadius = 8
        btn.layer.masksToBounds = true
        return btn
    }()
    /// 确认按钮
    lazy var confirmButton: UIButton = {
        let btn = UIButton.with(title: "立刻暴击", titleColor: UIColor(hex: "9A4312")!, boldFontSize: 24)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 8
        btn.layer.masksToBounds = true
        return btn
    }()
    /// 剩余时间
    lazy var timerLabel: UILabel = {
        let t = UILabel.with(textColor: .qu_black, fontSize: 20)
        t.textAlignment = .center
        return t
    }()

    /// 暴击个数泡泡
    lazy var bubbleBg = UIView.withBackgounrdColor(.clear)
    /// 暴击图片
    lazy var logo = UIImageView.with(imageName: "crit_logo_big")
    lazy var markLabel: UILabel = {
        let lb = UILabel.numberFont(size: 13)
        lb.text = "X"
        lb.textColor = .new_middleGray
        lb.textAlignment = .center
        return lb
    }()
    lazy var critCountOneLabel: UILabel = {
        let lb = UILabel.numberFont(size: 28)
        lb.text = "1"
        lb.textColor = .black
        lb.isHidden = true
        lb.textAlignment = .center
        return lb
    }()
    /// 暴击个数输入框
    lazy var inputTextField: UITextField = {
        let tf = UITextField()
        tf.isHidden = true
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 4
        tf.layer.masksToBounds = true
        tf.textColor = .qu_black
        tf.textAlignment = .center
        tf.keyboardType = .numberPad
        tf.font = UIFont.numberFont(28)
        tf.layer.borderColor = UIColor.qu_separatorLine.cgColor
        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return tf
    }()
    /// 滑动条背景
    let sliderBg = RoundedCornerView(corners: .allCorners, radius: 8, backgroundColor: .new_backgroundColor)
    /// 底部滑动条
    lazy var slider: CustomSlider = {
        let s = CustomSlider()
        s.minimumTrackTintColor = .new_yellow
        s.addTarget(self, action: #selector(sliderValueChange), for: .valueChanged)
        s.setThumbImage(UIImage(named: "crit_thumb"), for: .normal)
        s.maximumTrackTintColor = .new_backgroundColor
        return s
    }()
    /// 最大值
    lazy var maxValueLabel: UILabel = {
        let lb = UILabel.numberFont(size: 14)
        lb.textColor = .black
        lb.textAlignment = .left
        return lb
    }()
    /// 顶部白色背景
    let topBg = RoundedCornerView(corners: [.topLeft, .topRight], radius: 8, backgroundColor: .white)

    @objc func sliderValueChange(sender: UISlider) {
        self.inputTextField.text = "\(Int(sender.value))"
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.addSubview(bgIv)
        bgIv.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.left.equalTo(8)
        }
        
        let leftArrow = UIImageView.with(imageName: "crit_info_left_arrow")
        self.addSubview(leftArrow)
        leftArrow.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.bottom.equalTo(-24)
            make.width.equalTo(10)
            make.height.equalTo(24)
        }
        
        self.addSubview(timerLabel)
        timerLabel.snp.makeConstraints { make in
            make.bottom.equalTo(-8)
            make.centerX.equalToSuperview()
            make.height.equalTo(12)
        }
        
        self.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.left.equalTo(22)
            make.bottom.equalTo(-24)
            make.height.equalTo(44)
        }
        
        self.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.bottom.height.width.equalTo(cancelButton)
            make.left.equalTo(cancelButton.snp.right).offset(6)
            make.right.equalTo(-16)
        }
        
        let desLabel = UILabel.with(textColor: UIColor(hex: "9A4312")!, fontSize: 20, defaultText: "选择此次暴击可额外获得的扭蛋个数")
        self.addSubview(desLabel)
        desLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(cancelButton.snp.top).offset(-9)
            make.height.equalTo(14)
        }
        
        let leftIv = UIImageView.with(imageName: "crit_action_left")
        self.addSubview(leftIv)
        leftIv.snp.makeConstraints { make in
            make.centerY.equalTo(desLabel)
            make.right.equalTo(desLabel.snp.left).offset(-3)
        }
        
        let rightIv = UIImageView.with(imageName: "crit_action_right")
        self.addSubview(rightIv)
        rightIv.snp.makeConstraints { make in
            make.centerY.equalTo(desLabel)
            make.left.equalTo(desLabel.snp.right).offset(3)
        }
        
        self.addSubview(topBg)
        topBg.snp.makeConstraints { make in
            make.bottom.equalTo(-112)
            make.left.equalTo(18)
            make.right.equalTo(-10)
            make.height.equalTo(142)
        }
        
        // 暴击个数部分
        topBg.addSubview(bubbleBg)

        bubbleBg.addSubview(logo)
        logo.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.equalTo(50)
        }

        bubbleBg.addSubview(markLabel)
        markLabel.snp.makeConstraints { make in
            make.centerY.equalTo(logo)
            make.left.equalTo(logo.snp.right).offset(4)
            make.width.equalTo(17)
        }

        bubbleBg.addSubview(critCountOneLabel)
        critCountOneLabel.snp.makeConstraints { (make) in
            make.left.equalTo(markLabel.snp.right).offset(30)
            make.centerY.equalTo(markLabel)
        }

        bubbleBg.addSubview(inputTextField)
        inputTextField.snp.makeConstraints { make in
            make.left.equalTo(markLabel.snp.right).offset(12)
            make.size.equalTo(CGSize(width: 71, height: 34))
            make.centerY.equalTo(logo)
        }

        // 滑动条部分
        topBg.addSubview(sliderBg)
        sliderBg.snp.makeConstraints { (make) in
            make.left.equalTo(6)
            make.bottom.equalTo(-30)
            make.right.equalTo(-40)
            make.height.equalTo(16)
        }
        
        topBg.addSubview(slider)
        slider.snp.makeConstraints { (make) in
            make.left.equalTo(sliderBg).offset(4)
            make.right.equalTo(sliderBg).offset(-2)
            make.centerY.equalTo(sliderBg)
            make.height.equalTo(12)
        }
        
        maxValueLabel.textAlignment = .left
        topBg.addSubview(maxValueLabel)
        maxValueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(slider)
            make.left.equalTo(slider.snp.right).offset(8) 
        }
    }

    func layoutContentViews(canCritCount: Int) {

            slider.minimumValue = 1.0
            slider.maximumValue = Float(canCritCount)
            inputTextField.text = "1"

            if canCritCount == 1 {
                bgIv.image = UIImage(named: "crit_action_bg_one")
                maxValueLabel.isHidden = true
                inputTextField.isHidden = true
                critCountOneLabel.isHidden = false
                slider.isHidden = true
                sliderBg.isHidden = true

                bubbleBg.snp.remakeConstraints { make in
                    make.center.equalToSuperview()
                    make.size.equalTo(CGSize(width: 143, height: 50))
                }
                
                topBg.snp.updateConstraints { make in
                    make.height.equalTo(102)
                }
            } else {
                bgIv.image = UIImage(named: "crit_action_bg_more")
                maxValueLabel.text = "\(canCritCount)"
                maxValueLabel.isHidden = false
                inputTextField.isHidden = false
                critCountOneLabel.isHidden = true
                slider.isHidden = false
                sliderBg.isHidden = false

                bubbleBg.snp.remakeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.size.equalTo(CGSize(width: 143, height: 50))
                    make.top.equalTo(16)
                }
                
                topBg.snp.updateConstraints { make in
                    make.height.equalTo(142)
                }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var criticalState: CriticalState = .normal {
        didSet {
            switch criticalState {
            case let .userStartGame(remainSec):
                let attrM = NSMutableAttributedString(string: "剩余时间", attributes: [.foregroundColor: UIColor.qu_black, .font: UIFont.systemFont(ofSize: 10)])
                attrM.append(NSAttributedString(string: "\(Int(remainSec))s", attributes: [.foregroundColor: UIColor(hex: "ff4606")!, .font: UIFont.systemFont(ofSize: 10)]))
                timerLabel.attributedText = attrM
            case .fired:
                inputTextField.endEditing(true)
            default: return
            }
        }
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if let count = Int(textField.text ?? "1") {
            if count > critCount {
                self.inputTextField.text = String.init(format: "%d", critCount)
            }
            if count == 0 {
                self.inputTextField.text = "1"
            }
            let inputCount = Int(self.inputTextField.text!)!
            self.slider.value = Float(inputCount)
        }
    }

    /// 重置状态
    func resetState() {
        self.slider.value = 1.0
        self.inputTextField.endEditing(true)
    }
}

class CustomSlider: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let newBounds = super.trackRect(forBounds: bounds)
        return CGRect(x: 0, y: 0, width: newBounds.size.width, height: 12)
    }
}

// class GameNewCriticalSlider: UISlider {
//
//    private let values: [Float]
//    private var lastIndex: Int? = nil
//    let callback: (Float) -> Void
//
//    init(frame: CGRect, values: [Float], callback: @escaping (_ newValue: Float) -> Void) {
//        self.values = values
//        self.callback = callback
//        super.init(frame: frame)
//        self.addTarget(self, action: #selector(handleValueChange(sender:)), for: .valueChanged)
//
//        let steps = values.count - 1
//        self.minimumValue = 0
//        self.maximumValue = Float(steps)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    @objc func handleValueChange(sender: UISlider) {
//        let newIndex = Int(sender.value + 0.5) // round up to next index
//        self.setValue(Float(newIndex), animated: false) // snap to increments
//        let didChange = lastIndex == nil || newIndex != lastIndex!
//        if didChange {
//            let actualValue = self.values[newIndex]
//            self.callback(actualValue)
//        }
//    }
//
//    override func trackRect(forBounds bounds: CGRect) -> CGRect {
//
//        //keeps original origin and width, changes height, you get the idea
//        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 13.0))
//        super.trackRect(forBounds: customBounds)
//        return customBounds
//    }
//
//    //while we are here, why not change the image here as well? (bonus material)
//    override func awakeFromNib() {
//        isContinuous = false
//        setThumbImage(UIImage(named: "crit_thumb"), for: .normal)
//        super.awakeFromNib()
//    }
// }
