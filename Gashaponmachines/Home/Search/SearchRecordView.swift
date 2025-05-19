import UIKit

class SearchRecordView: UIView {

    /// 清楚历史记录回调
    var cleanHistoryHandle: (() -> Void)?

    /// 关键字点击回调
    var keywordClickHandle: ((String) -> Void)?

    /// 内容视图
    lazy var contentView: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        view.backgroundColor = .white
        return view
    }()

    /// 热门label
    lazy var hotLabel: UILabel = {
        let label = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: "大家都在搜")
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()

    /// 历史label
    lazy var historylabel: UILabel = {
        let label = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: "历史记录")
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()

    /// 清楚按钮
    lazy var cleanHistoryBtn: UIButton = {
        let btn = UIButton.with(title: "清空", titleColor: .qu_black, fontSize: 28)
        btn.addTarget(self, action: #selector(cleanHistory), for: .touchUpInside)
        return btn
    }()

    /// 热门buttons
    var hotButtons = [UIButton]()

    /// 历史buttons
    var historyButtons = [UIButton]()

    /// 热门记录
    var hotRecords: [String]?

    /// 历史记录
    var historyRecords: [String]?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(contentView)
    }

    func updateData(hotRecords: [String], historyRecords: [String]?) {
        self.hotRecords = hotRecords
        self.historyRecords = historyRecords
        clean()
        setupUI()
        layoutContentView()
    }

    func clean() {
        for button in hotButtons {
            button.removeFromSuperview()
        }
        hotButtons.removeAll()

        for button in historyButtons {
            button.removeFromSuperview()
        }
        historyButtons.removeAll()
    }

    func setupUI() {
        // 添加子控件
        guard let hotRecords = self.hotRecords else {
            return
        }
        if !contentView.subviews.contains(hotLabel) {
            contentView.addSubview(hotLabel)
        }
        setupButtons(titles: hotRecords, isHot: true)

        guard let hisRecords = self.historyRecords else {
            return
        }
        if !contentView.subviews.contains(historylabel) {
            contentView.addSubview(historylabel)
        }
        if !contentView.subviews.contains(cleanHistoryBtn) {
            contentView.addSubview(cleanHistoryBtn)
        }
        setupButtons(titles: hisRecords, isHot: false)
    }

    func setupButtons(titles: [String], isHot: Bool) {
        for index in 0..<titles.count {
            let text = titles[index]
            var title = text
            if text.count > 9 {
                let startIndex = text.startIndex
                let endIndex = text.index(text.startIndex, offsetBy: 8)
                title = text[startIndex...endIndex] + "..."
            }

            let button = UIButton.with(title: title, titleColor: UIColor(hex: "797979")!, fontSize: 24)
            button.tag = index
            if isHot {
                button.addTarget(self, action: #selector(searchHotKeyword), for: .touchUpInside)
            } else {
                button.addTarget(self, action: #selector(searchHistoryKeyword), for: .touchUpInside)
            }

            button.backgroundColor = UIColor(hex: "EFEFEF")
            button.layer.cornerRadius = 12
            contentView.addSubview(button)
            if isHot {
                hotButtons.append(button)
            } else {
                historyButtons.append(button)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = self.bounds

        layoutContentView()
    }

    func layoutContentView() {
        hotLabel.frame = CGRect(x: 12, y: 24, width: hotLabel.width, height: hotLabel.height)

        caculateButtons(buttons: hotButtons, startY: hotLabel.bottom + 12)

        if let lastHotbutton = hotButtons.last {
            historylabel.frame = CGRect(x: 12, y: lastHotbutton.bottom + 24, width: hotLabel.width, height: hotLabel.height)

            cleanHistoryBtn.centerY = historylabel.centerY
            cleanHistoryBtn.right = self.right - 12
            cleanHistoryBtn.sizeToFit()

            caculateButtons(buttons: historyButtons, startY: historylabel.bottom + 12)
        }
    }

    func caculateButtons(buttons: [UIButton], startY: CGFloat) {
        var btnX: CGFloat = 12
        var btnY: CGFloat = startY
        let btnH: CGFloat = 24
        let btnMaigin: CGFloat = 8
        for button in buttons {
            guard let text = button.titleLabel?.text else {
                continue
            }

            let btnW = text.sizeOfString(usingFont: UIFont.withBoldPixel(24)).width + 24

            let leftMargin = self.width - btnX
            if leftMargin < (btnW + btnMaigin + 12) { // 剩余距离不够
                btnX = 12
                btnY += btnH + btnMaigin
            }
            button.frame = CGRect(x: btnX, y: btnY, width: btnW, height: btnH)
            btnX = btnX + btnMaigin + btnW
        }
    }

    @objc func searchHotKeyword(button: UIButton) {
        if let records = self.hotRecords, button.tag < records.count {
            if let handle = keywordClickHandle {
                handle(records[button.tag])
            }
        }
    }

    @objc func searchHistoryKeyword(button: UIButton) {
        if let records = self.historyRecords, button.tag < records.count {
            if let handle = keywordClickHandle {
                handle(records[button.tag])
            }
        }
    }

    @objc func searchKeyword(button: UIButton) {
        if let handle = keywordClickHandle {
            handle(button.titleLabel?.text ?? "")
        }
    }

    @objc func cleanHistory() {
        if self.historyRecords != nil {
            self.updateData(hotRecords: self.hotRecords ?? [String](), historyRecords: nil)
            if let handle = cleanHistoryHandle {
                handle()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
