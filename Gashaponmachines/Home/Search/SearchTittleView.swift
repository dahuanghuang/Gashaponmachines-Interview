import UIKit

class SearchTittleView: UIView {

    var machineTitle = "扭蛋机(0)" {
        didSet {
            self.machineButton.setTitle(self.machineTitle, for: .normal)
        }
    }

    var mallTitle = "兑换商城(0)" {
        didSet {
            self.mallButton.setTitle(self.mallTitle, for: .normal)
        }
    }

    /// 选中按钮回调
    var selectButtonHandle: ((Int) -> Void)?

    private lazy var machineButton = UIButton.with(title: "扭蛋机(0)", titleColor: .qu_black, boldFontSize: 32)

    private lazy var mallButton = UIButton.with(title: "兑换商城(0)", titleColor: .qu_lightGray, boldFontSize: 32)

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .white

        setupUI()
    }

    var currentIndex: Int = 0 {
        didSet {
            if currentIndex == 0 {
                self.machineButton.setTitleColor(.qu_black, for: .normal)
                self.mallButton.setTitleColor(.qu_lightGray, for: .normal)
            } else {
                self.machineButton.setTitleColor(.qu_lightGray, for: .normal)
                self.mallButton.setTitleColor(.qu_black, for: .normal)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {

        machineButton.titleLabel?.textAlignment = .right
        machineButton.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        machineButton.tag = 0
        addSubview(machineButton)
        machineButton.snp.makeConstraints { make in
            make.right.equalTo(self.snp.centerX).offset(-12)
            make.centerY.height.equalToSuperview()
        }

        mallButton.titleLabel?.textAlignment = .left
        mallButton.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        mallButton.tag = 1
        addSubview(mallButton)
        mallButton.snp.makeConstraints { make in
            make.left.equalTo(self.snp.centerX).offset(12)
            make.centerY.height.equalToSuperview()
        }
    }

    @objc func buttonTap(button: UIButton) {
        currentIndex = button.tag
        if let handle = selectButtonHandle {
            handle(button.tag)
        }
    }
}
