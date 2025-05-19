public enum YiFanShangSegmentType: String, CaseIterable {
    // 推荐
    case recommend

    // 进度
    case progress

    // 价格
    case price

    var index: Int {
        switch self {
        case .recommend: return 0
        case .progress: return 1
        case .price: return 2
        }
    }

    var title: String {
        switch self {
        case .recommend:
            return "推荐"
        case .progress:
            return "进度"
        case .price:
            return "价格"
        }
    }

    static var allButtons: [UIButton] {
        return YiFanShangSegmentType.allCases.map { ToggableButton(type: $0) }
    }
}

public enum YiFanShangSegmentTypeOrder: String {
    case asc // 正序
    case desc // 倒序
}

class YiFanShangSegmentView: UIView {

    var isProgressAsc: Bool = true

    // 进度/价格的次序
    static var order: String = "asc"
    
    private var allButtons = YiFanShangSegmentType.allButtons

//    private var selectedIndex: Int = 0 {
//        didSet {
//            guard selectedIndex < allButtons.count else { return }
//
//            // 设置按钮选中
//            allButtons.forEach { btn in
//                btn.isSelected = btn.tag == selectedIndex
//            }
//
//            // 选中回调
//            if let callback = selectedIdnexCallback {
//                var type: YiFanShangSegmentType!
//                if selectedIndex == 0 {
//                    type = .recommend
//                }else if selectedIndex == 1 {
//                    type = .progress
//                }else if selectedIndex == 2 {
//                    type = .price
//                }
//                callback(type)
//            }
//        }
//    }

    var selectedIdnexCallback: ((YiFanShangSegmentType) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .white

        for (index, btn) in allButtons.enumerated() {

            addSubview(btn)
            btn.tag = index
            btn.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(CGFloat(index) * (Constants.kScreenWidth/3))
                make.width.equalTo(Constants.kScreenWidth/3)
                make.top.bottom.equalToSuperview()
            }
            btn.addTarget(self, action: #selector(buttonSelected(selectButton:)), for: .touchUpInside)
            if index == 1 || index == 2 {
                let view = UIImageView.with(imageName: "yfs_seg_plain")
                addSubview(view)
                view.snp.makeConstraints { make in
                    make.centerY.equalTo(btn)
                    make.left.equalTo(btn.snp.right).offset(4)
                    make.size.equalTo(CGSize(width: 8, height: 16))
                }
            } else {
                btn.isSelected = true
            }
        }
    }

    @objc func buttonSelected(selectButton: ToggableButton) {

        // 设置按钮的排序样式
        if let isDescendingOrder = selectButton.isDescendingOrder {
            selectButton.isDescendingOrder = !isDescendingOrder
        } else {
            selectButton.isDescendingOrder = false
        }

        // 设置数据展示顺序
        if let isDesc = selectButton.isDescendingOrder {
            if selectButton.tag == 0 {
                YiFanShangSegmentView.order = "asc"
            } else {
                YiFanShangSegmentView.order = isDesc ? "desc" : "asc"
            }
        }

        // 设置选中
//        selectedIndex = selectButton.tag
        allButtons.forEach { btn in
            btn.isSelected = (btn.tag == selectButton.tag)
        }
        
        // 选中回调
        if let callback = selectedIdnexCallback {
            callback(selectButton.type)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.roundCorners([.topLeft, .topRight], radius: 12)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// 切换按钮
class ToggableButton: UIButton {

    // 标题
    lazy var titleLbl = UILabel.with(textColor: .qu_black, boldFontSize: 28)

    // 排序图片
    lazy var indicator = UIImageView.with(imageName: "yfs_seg_plain")
    
    var type: YiFanShangSegmentType!

    init(type: YiFanShangSegmentType) {
        super.init(frame: .zero)
        
        self.type = type

        self.backgroundColor = .white

        let view = UIView.withBackgounrdColor(.white)
        addSubview(view)
        view.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        titleLbl.text = type.title
//        titleLbl.backgroundColor = UIColor.black
        view.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
//            make.left.centerY.equalToSuperview()
            make.center.equalToSuperview()
        }

        if type != .recommend {
            view.addSubview(indicator)
            indicator.snp.makeConstraints { make in
                make.right.equalToSuperview()
                make.centerY.equalToSuperview()
                make.left.equalTo(titleLbl.snp.right).offset(4)
            }
        }
    }

    override var isSelected: Bool {

        didSet {
            titleLbl.textColor = isSelected ? .qu_red : .qu_black

            // 取消选中时, 清空排序
            if !isSelected {
                isDescendingOrder = nil
            }
        }
    }

    // 是否为倒叙
    var isDescendingOrder: Bool? {
        didSet {
            if let order = isDescendingOrder {
                indicator.image = order ? UIImage(named: "yfs_seg_down") : UIImage(named: "yfs_seg_up")
            } else {
                indicator.image = UIImage(named: "yfs_seg_plain")
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
