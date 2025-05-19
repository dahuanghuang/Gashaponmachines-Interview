//
import UIKit

class CustomNavigationBar: UIView {
    
    public var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }

    public var styleColor = UIColor.black {
        didSet {
            self.titleLabel.textColor = styleColor
            self.leftButton?.setTitleColor(styleColor, for: .normal)
            self.rightButton?.setTitleColor(styleColor, for: .normal)
        }
    }

    private var leftButton: UIButton?
    private var rightButton: UIButton?

    lazy var titleLabel: UILabel = {
        let tl = UILabel.with(textColor: styleColor, boldFontSize: 32)
        tl.textAlignment = .center
        return tl
    }()

    private let navigationBar = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white

        self.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(Constants.kNavHeight)
        }

        titleLabel.text = title
        navigationBar.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        let btn = UIButton.with(imageName: "nav_back_black", target: self, selector: #selector(backButtonClick))
        navigationBar.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.size.equalTo(44)
        }
        self.leftButton = btn
    }
    
    /// 返回
    @objc func backButtonClick() {
        self.getViewController()?.navigationController?.popViewController(animated: true)
    }

    func setupLeftButton(text: String, target: Any?, selector: Selector) {
        cleanLeftButton()
        leftButton = UIButton.with(title: text, titleColor: styleColor, fontSize: 28)
        setupButton(isLeft: true, target: target, selector: selector)
    }

    func setupLeftButton(imageName: String, target: Any?, selector: Selector) {
        cleanLeftButton()
        leftButton = UIButton.with(imageName: imageName, target: target, selector: selector)
        setupButton(isLeft: true, target: target, selector: selector)
    }

    func setupRightButton(text: String, target: Any?, selector: Selector) {
        cleanRightButton()
        rightButton = UIButton.with(title: text, titleColor: styleColor, fontSize: 28)
        setupButton(isLeft: false, target: target, selector: selector)
    }

    func setupRightButton(imageName: String, target: Any?, selector: Selector) {
        cleanRightButton()
        rightButton = UIButton.with(imageName: imageName, target: target, selector: selector)
        setupButton(isLeft: false, target: target, selector: selector)
    }
    
    private func cleanLeftButton() {
        self.leftButton?.removeFromSuperview()
        self.leftButton = nil
    }
    
    private func cleanRightButton() {
        self.rightButton?.removeFromSuperview()
        self.rightButton = nil
    }

    private func setupButton(isLeft: Bool, target: Any?, selector: Selector) {
        let button = isLeft ? leftButton : rightButton
        guard let btn = button else {
            return
        }
        btn.addTarget(target, action: selector, for: .touchUpInside)
        navigationBar.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            if isLeft {
                make.left.equalTo(12)
            } else {
                make.right.equalTo(-12)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
