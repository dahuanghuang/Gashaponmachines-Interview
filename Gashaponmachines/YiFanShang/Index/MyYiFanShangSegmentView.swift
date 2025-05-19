enum MyYiFanShangSegmentType: String, CaseIterable {
    // 全部
    case all

    // 进行中
    case processing

    // 已结束
    case finish

    var title: String {
        switch self {
        case .all: return "全部"
        case .processing: return "进行中"
        case .finish: return "已结束"
        }
    }

    static var allButtons: [UIButton] {
        return MyYiFanShangSegmentType.allCases.map { UIButton.with(title: $0.title, titleColor: .qu_black, boldFontSize: 28) }
    }
}

class MyYiFanShangSegmentView: UIView {

    private var allButtons: [UIButton] = MyYiFanShangSegmentType.allButtons

    var selectedIdnexCallback: ((MyYiFanShangSegmentType) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .white

        for (index, btn) in allButtons.enumerated() {

            btn.setTitleColor(.qu_black, for: .normal)
            btn.setTitleColor(.qu_red, for: .selected)
            btn.tag = index
            btn.addTarget(self, action: #selector(buttonSelected(selectButton:)), for: .touchUpInside)
            addSubview(btn)
            btn.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(Constants.kScreenWidth/3)
                make.left.equalToSuperview().offset(CGFloat(index) * (Constants.kScreenWidth/3))
            }
            
            if index == 0 {
                btn.isSelected = true
            }
        }
    }

    @objc func buttonSelected(selectButton: UIButton) {
        let selectIndex = selectButton.tag
        
        allButtons.forEach { btn in
            btn.isSelected = (btn.tag == selectButton.tag)
        }

        if let callback = selectedIdnexCallback {
            var type: MyYiFanShangSegmentType?
            if selectIndex == 0 {
                type = .all
            }else if (selectIndex == 1) {
                type = .processing
            }else if (selectIndex == 2) {
                type = .finish
            }
            
            if let t = type {
                callback(t)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
