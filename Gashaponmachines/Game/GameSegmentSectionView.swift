import UIKit

enum GameSegmentType {
    case detail // 奖赏详情
    case rule // 规则介绍
    case record // 黑蛋记录

    var indexValue: Int {
        switch self {
        case .detail: return 0
        case .rule: return 1
        case .record: return 2
        }
    }

    var title: String {
        switch self {
        case .detail: return "奖赏详情"
        case .rule: return "规则介绍"
        case .record: return "黑蛋记录"
        }
    }
}

final class GameSegmentSectionView: UIView {
    
    /// 选中改变回调
    public var indexChangeHandle: ((Int) -> Void)?
    
    /// 选中按钮的索引
    public var selectIndex: Int? {
        didSet {
            guard let sIndex = selectIndex else { return }
            
            // 防止重复选中(selectButton == nil, 说明是第一次选中, 不做判断)
            if let sButton = selectButton, sIndex == sButton.type.indexValue { return }
            
            // 设置选中状态
            self.selectButton?.isSelect = false
            self.selectButton = self.segmentButtons[sIndex]
            self.selectButton?.isSelect = true
            
            self.selectLine.isHidden = false
            self.selectLine.snp.remakeConstraints { make in
                make.bottom.equalToSuperview()
                make.width.equalTo(73)
                make.height.equalTo(5)
                if let btn = self.selectButton {
                    make.centerX.equalTo(btn)
                }
            }
            
            if let handle = self.indexChangeHandle {
                handle(sIndex)
            }
        }
    }

    /// 选择按钮数组
    private var segmentButtons = [GameSegmentButton]()

    /// 上一个被选中的按钮
    private var selectButton: GameSegmentButton?
    
    /// 底部选中条
    let selectLine = RoundedCornerView(corners: [.topLeft, .topRight], radius: 12, backgroundColor: .new_yellow)

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        let bgIv = UIImageView(image: UIImage(named: "game_n_segment_bg"))
        self.addSubview(bgIv)
        bgIv.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let detailButton = setuSegmentButton(type: .detail)
        detailButton.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
        }

        let ruleButton = setuSegmentButton(type: .rule)
        ruleButton.snp.makeConstraints { (make) in
            make.left.equalTo(detailButton.snp.right)
            make.top.bottom.width.equalTo(detailButton)
        }

        let recordButton = setuSegmentButton(type: .record)
        recordButton.snp.makeConstraints { (make) in
            make.left.equalTo(ruleButton.snp.right)
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(ruleButton)
        }
        
        let bottomLine = UIView.withBackgounrdColor(.new_yellow.alpha(0.4))
        self.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        selectLine.isHidden = true
        self.addSubview(selectLine)
        
    }
    
    /// 添加选择按钮
    func setuSegmentButton(type: GameSegmentType) -> GameSegmentButton {
        let button = GameSegmentButton(type: type)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
        self.addSubview(button)
        segmentButtons.append(button)
        return button
    }
    
    @objc func buttonClick(button: GameSegmentButton) {
        self.selectIndex = button.type.indexValue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class GameSegmentButton: UIButton {
    
    let selectIv = UIImageView(image: UIImage(named: "game_n_segment_select"))
    
    let titleLb = UILabel.with(textColor: .new_gray, fontSize: 28)

    var type: GameSegmentType!

    init(type: GameSegmentType) {
        super.init(frame: .zero)
        
        self.type = type
        
        selectIv.isHidden = true
        self.addSubview(selectIv)
        selectIv.snp.makeConstraints { make in
            make.top.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalTo(-5)
        }

        titleLb.text = type.title
        self.addSubview(titleLb)
        titleLb.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }

    var isSelect: Bool = false {
        didSet {
            if isSelect {
                self.selectIv.isHidden = false
                self.titleLb.textColor = UIColor(hex: "9A4312")
                self.titleLb.font = UIFont.boldSystemFont(ofSize: 16)
            } else {
                self.selectIv.isHidden = true
                self.titleLb.textColor = .new_gray
                self.titleLb.font = UIFont.systemFont(ofSize: 14)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

