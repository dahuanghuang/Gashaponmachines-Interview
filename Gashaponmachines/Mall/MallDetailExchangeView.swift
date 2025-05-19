import UIKit

class MallDetailExchangeView: UIView {
    
    private(set) var currentCount = 1

    /// +
    lazy var addButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(add), for: .touchUpInside)
        button.setImage(UIImage(named: "add_black"), for: .normal)
        button.setImage(UIImage(named: "add_gray"), for: .disabled)
        return button
    }()

    /// 数量
    lazy var amountLabel: UILabel = {
        let label = UILabel.with(textColor: .black, boldFontSize: 28, defaultText: "1")
        label.textAlignment = .center
        return label
    }()

    /// -
    lazy var subtractButton: UIButton = {
        let button = UIButton()
        button.isEnabled = false
        button.addTarget(self, action: #selector(subtract), for: .touchUpInside)
        button.setImage(UIImage(named: "subtract_black"), for: .normal)
        button.setImage(UIImage(named: "subtract_gray"), for: .disabled)
        return button
    }()

    var env: MallProductDetailEnvelope?
    
    // 白色背景
    let bottomBgView = UIView.withBackgounrdColor(.white)

    init(env: MallProductDetailEnvelope) {
        super.init(frame: .zero)

        self.env = env

        /// 黑色遮罩
        self.backgroundColor = UIColor.black.alpha(0.6)
        let tap = UITapGestureRecognizer(target: self, action: #selector(hide))
        tap.delegate = self
        self.addGestureRecognizer(tap)

        /// 遮挡立即兑换视图的圆角
        let line = UIView.withBackgounrdColor(.white)
        self.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(12)
        }
        
        self.addSubview(bottomBgView)
        bottomBgView.snp.makeConstraints { make in
            make.bottom.equalTo(line.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }

        // 兑换个数
        let titleLabel = UILabel.with(textColor: .black, fontSize: 24, defaultText: "兑换数量")
        bottomBgView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
        }

        // +按钮
        bottomBgView.addSubview(addButton)
        addButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.size.equalTo(18)
        }

        // 数量
        bottomBgView.addSubview(amountLabel)
        amountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(addButton.snp.left)
            make.centerY.equalToSuperview()
            make.width.equalTo(44)
        }

        // -按钮
        bottomBgView.addSubview(subtractButton)
        subtractButton.snp.makeConstraints { (make) in
            make.right.equalTo(amountLabel.snp.left)
            make.centerY.equalToSuperview()
            make.size.equalTo(addButton)
        }
    }

    /// +
    @objc func add() {
        currentCount += 1
        self.subtractButton.isEnabled = true

        if let limit = self.env?.canExchangeLimited, let limitCount = Int(limit) {
            if currentCount > limitCount {
                currentCount = limitCount
                HUD.showError(second: 1.0, text: self.env?.reasonForLimitation ?? "库存不足", completion: nil)
            }
        }
        self.amountLabel.text = "\(currentCount)"
    }

    /// -
    @objc func subtract() {
        currentCount -= 1
        if currentCount <= 1 {
            self.currentCount = 1
            self.subtractButton.isEnabled = false
        }
        self.amountLabel.text = "\(currentCount)"
    }

    @objc func hide() {
        self.removeFromSuperview()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        bottomBgView.roundCorners([.topLeft, .topRight], radius: 12)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MallDetailExchangeView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchview = touch.view {
            for subview in self.subviews {
                if touchview.isDescendant(of: subview) {
                    return false
                }
            }
        }
        return true
    }
}
