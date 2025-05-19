//enum YiFanShangTableHeaderViewButtonType {
//    // 元气赏
//    case yiFanShang(type: YiFanShangSegmentType)
//
//    // 我的元气赏
//    case myYiFanShang(type: YiFanShangMySegmentType)
//
//    // 规则说明
//    case rule
//
//    var indexValue: Int {
//        switch self {
//        case .yiFanShang:
//            return 0
//        case .myYiFanShang:
//            return 1
//        case .rule:
//            return 2
//        }
//    }
//
//    var title: String {
//        switch self {
//        case .yiFanShang: return "元气赏"
//        case .myYiFanShang: return "我的元气赏"
//        case .rule: return "规则说明"
//        }
//    }
//}
//
//class YiFanShangTableHeaderViewButton: UIButton {
//
//    lazy var bg = UIImageView()
//
//    lazy var container = UIView()
//
//    lazy var titleLbl = UILabel.with(textColor: .white, boldFontSize: 28, defaultText: type.title)
//
//    lazy var icon = UIImageView.with(imageName: "yfs_top_logo")
//
//    var type: YiFanShangTableHeaderViewButtonType
//
//    init(type: YiFanShangTableHeaderViewButtonType) {
//        self.type = type
//        super.init(frame: .zero)
//        self.layer.cornerRadius = 8
//        self.layer.masksToBounds = true
//        self.backgroundColor =  UIColor.UIColorFromRGB(0xff7b87)
//
//        addSubview(bg)
//        bg.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//
//        addSubview(container)
//        container.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//        }
//
//        container.addSubview(titleLbl)
//        titleLbl.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//        }
//    }
//
//    override var isSelected: Bool {
//        didSet {
//            if isSelected {
//
//                self.backgroundColor = UIColor.white
//
//                bg.image = UIImage(named: "yfs_top_bg")
//
//                container.addSubview(icon)
//                icon.snp.makeConstraints { make in
//                    make.size.equalTo(CGSize(width: 23, height: 24))
//                    make.centerY.left.equalToSuperview()
//                }
//
//                titleLbl.snp.remakeConstraints { make in
//                    make.centerY.right.equalToSuperview()
//                    make.left.equalTo(icon.snp.right).offset(4)
//                }
//            } else {
//
//                self.backgroundColor =  UIColor.UIColorFromRGB(0xff7b87)
//                bg.image = nil
//                icon.removeFromSuperview()
//                titleLbl.snp.remakeConstraints { make in
//                    make.center.equalToSuperview()
//                }
//            }
//        }
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//class YiFanShangTableHeaderView: UIView {
//
//    var selectedIndex: Int = 0 {
//        didSet {
//            allButtons.forEach { btn in
//                btn.isSelected = btn.tag == selectedIndex ? true : false
//                btn.titleLbl.textColor = btn.isSelected ? .qu_black : .white
//            }
//        }
//    }
//
//    var selectedIdnexCallback: ((Int) -> Void)?
//
//    static let ButtonWidth = (Constants.kScreenWidth - 16 - 24) / 3
//
//    lazy var yuanqishangButton: YiFanShangTableHeaderViewButton = YiFanShangTableHeaderViewButton(type: .yiFanShang(type: .recommend))
//
//    lazy var myYQSButton: YiFanShangTableHeaderViewButton = YiFanShangTableHeaderViewButton(type: .myYiFanShang(type: .all))
//
//    lazy var ruleButton: YiFanShangTableHeaderViewButton = YiFanShangTableHeaderViewButton(type: .rule)
//
//    lazy var allButtons: [YiFanShangTableHeaderViewButton] = [yuanqishangButton, myYQSButton, ruleButton]
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        backgroundColor = .qu_red
//
//        yuanqishangButton.tag = 0
//        addSubview(yuanqishangButton)
//        yuanqishangButton.snp.makeConstraints { make in
//            make.left.top.equalToSuperview()
//            make.size.equalTo(CGSize(width: YiFanShangTableHeaderView.ButtonWidth, height: YiFanShangTableHeaderView.ButtonWidth * 0.4))
//            make.bottom.equalToSuperview().offset(-12)
//        }
//
//        myYQSButton.tag = 1
//        addSubview(myYQSButton)
//        myYQSButton.snp.makeConstraints { make in
//            make.left.equalTo(yuanqishangButton.snp.right).offset(12)
//            make.size.top.equalTo(yuanqishangButton)
//        }
//
//        ruleButton.tag = 2
//        addSubview(ruleButton)
//        ruleButton.snp.makeConstraints { make in
//            make.size.top.equalTo(yuanqishangButton)
//            make.left.equalTo(myYQSButton.snp.right).offset(12)
//        }
//        defer { selectedIndex = 0 }
//
//        allButtons.forEach { btn in
//            btn.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
//        }
//    }
//
//    @objc func buttonTapped(sender: YiFanShangTableHeaderViewButton) {
//
//        selectedIndex = sender.tag
//
//        if let callback = self.selectedIdnexCallback {
//            callback(sender.tag)
//        }
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
