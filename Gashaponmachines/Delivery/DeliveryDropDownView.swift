import UIKit

let DeliveryDropDownCellId = "DeliveryDropDownCellId"

class DeliveryDropDownView: UIView {

    public var selectedClosure: ((Int) -> Void)?

    public var dataSource = [String]() {
        didSet {
            if self.dataSource.count > 0 {
                self.layoutContentViews()
                self.tableView.reloadData()
            }
        }
    }

    /// 当前类型
    private var currentIndex: Int = 0

    private lazy var container: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .white
        tv.dataSource = self
        tv.delegate = self
        tv.separatorStyle = .none
        tv.rowHeight = 48
        tv.bounces = false
        tv.register(DeliveryDropDownCell.self, forCellReuseIdentifier: DeliveryDropDownCellId)
        return tv
    }()

    private lazy var bottomMaskView: UIView = {
        let view = UIView()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(remove))
        view.addGestureRecognizer(tap)
        view.backgroundColor = UIColor.qu_black.alpha(0.6)
        return view
    }()

    init() {
        super.init(frame: .zero)

        self.addSubview(container)
        container.addSubview(tableView)
        container.addSubview(bottomMaskView)
    }

    @objc func remove() {
        self.tableView.reloadData()
        self.isHidden = true
    }

    func layoutContentViews() {
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        let height = CGFloat(dataSource.count) * tableView.rowHeight
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(height)
        }

        bottomMaskView.snp.makeConstraints { (make) in
            make.top.equalTo(tableView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DeliveryDropDownView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DeliveryDropDownCellId, for: indexPath) as! DeliveryDropDownCell
        cell.configure(text: self.dataSource[indexPath.row], isSelect: currentIndex == indexPath.row)
        return cell
    }
}

extension DeliveryDropDownView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentIndex = indexPath.row
        if let closure = self.selectedClosure {
            closure(indexPath.row)
        }
        self.remove()
    }
}

class DeliveryDropDownCell: UITableViewCell {

    lazy var titleLabel: UILabel = {
        let tl = UILabel()
        tl.textAlignment = .center
        tl.font = UIFont.systemFont(ofSize: 14)
//        tl.textColor = .black
        tl.textColor = .qu_lightGray
        return tl
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = .clear

        // 选中颜色
        let view = UIView()
        view.frame = self.bounds
        self.selectedBackgroundView = view
        self.selectedBackgroundView?.backgroundColor = .qu_lightYellow

        // 标题
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }

        // 分割线
        let line = UIView()
        line.backgroundColor = UIColor.qu_separatorLine
        contentView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

//    func configureWith(text: String) {
//        titleLabel.text = text
//    }

    func configure(text: String, isSelect: Bool) {
        titleLabel.text = text
        titleLabel.textColor = isSelect ? .qu_black : .qu_lightGray
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
