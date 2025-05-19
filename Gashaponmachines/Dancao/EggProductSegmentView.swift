import UIKit

public protocol EggProductSegmentViewDelegate: NSObjectProtocol {
    func segmentView(_ segmentView: EggProductSegmentView, didSelectAt index: Int)
}

public class EggProductSegmentView: UIView {

    /// 选中按钮的索引
    var selectIndex: Int = 0 {
        didSet {
            self.selectButton?.isSelect = false
            self.selectButton = self.segmentButtons[selectIndex]
            self.selectButton?.isSelect = true
            self.selectType = selectButton?.type ?? .general
            self.delegate?.segmentView(self, didSelectAt: selectIndex)
        }
    }

    var selectType: EggProductType = .general

    /// 选择按钮数组
    private var segmentButtons = [EggProductSegmentButton]()

    /// 上一个被选中的按钮
    private var selectButton: EggProductSegmentButton?

    weak var delegate: EggProductSegmentViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {

        self.backgroundColor = .clear

        let generalButton = setuSegmentButton(type: .general)
        generalButton.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
            make.width.equalTo((Constants.kScreenWidth - 40)/3)
            make.height.equalTo(32)
        }

        let pieceEggButton = setuSegmentButton(type: .pieceEgg)
        pieceEggButton.snp.makeConstraints { (make) in
            make.left.equalTo(generalButton.snp.right).offset(8)
            make.centerY.height.width.equalTo(generalButton)
        }

        let onepriceButton = setuSegmentButton(type: .oneprice)
        onepriceButton.snp.makeConstraints { (make) in
            make.left.equalTo(pieceEggButton.snp.right).offset(8)
            make.centerY.height.width.equalTo(generalButton)
        }
    }

    /// 添加选择按钮
    func setuSegmentButton(type: EggProductType) -> EggProductSegmentButton {
        let button = EggProductSegmentButton(type: type)
        self.addSubview(button)
        button.buttonClickHandle = { [weak self] index in
            self?.selectIndex = index
        }
        segmentButtons.append(button)
        return button
    }

    // 改变选中标题个数
    func changeProductTitleCount(titles: [String]) {

        if titles.count != segmentButtons.count { return }

        for index in 0..<segmentButtons.count {
            let button = segmentButtons[index]
            button.countLb.text = "(\(titles[index]))"
        }
    }
}

class EggProductSegmentButton: UIButton {

    var buttonClickHandle: ((Int) -> Void)?
    
    let titleLb = UILabel.with(textColor: UIColor(hex: "9A4312")!, boldFontSize: 32)
    
    let countLb = UILabel.with(textColor: UIColor(hex: "9A4312")!, fontSize: 20)

    var type: EggProductType = .general

    init(type: EggProductType) {
        super.init(frame: .zero)
        self.type = type
        setupUI()
    }

    var isSelect: Bool = false {
        didSet {
            if isSelect {
                self.titleLb.textColor = .qu_black
                self.backgroundColor = .new_yellow
            } else {
                self.titleLb.textColor = UIColor(hex: "9A4312")
                self.backgroundColor = UIColor(hex: "FFAC46")
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        
        self.backgroundColor = UIColor(hex: "FFAC46")
        self.layer.cornerRadius = 16
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(hex: "FF902B")?.cgColor

        titleLb.text = type.title
        self.addSubview(titleLb)
        titleLb.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        
        self.addSubview(countLb)
        countLb.snp.makeConstraints { (make) in
            make.left.equalTo(titleLb.snp.right).offset(2)
            make.bottom.equalTo(titleLb).offset(-2)
        }

        let button = UIButton()
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        addSubview(button)
        button.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    @objc func buttonClick() {
        if let handle = self.buttonClickHandle {
            handle(type.indexValue)
        }
    }
}
