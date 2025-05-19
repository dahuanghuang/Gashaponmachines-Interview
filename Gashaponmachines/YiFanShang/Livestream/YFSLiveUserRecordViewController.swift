import UIKit

extension Notification.Name {
    static let userCenterScrollState = Notification.Name("userCenterScrollState")
}

class YFSLiveUserRecordViewController: BaseViewController {

    let YiFanShangLivestreamTableViewCellReusableIdentifier = "YiFanShangLivestreamTableViewCellReusableIdentifier"

    var records: [YiFanShangLiveStreamRecord] = []

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor(hex: "FF7C74")
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 8
        tableView.layer.masksToBounds = true
        tableView.register(YiFanShangLivestreamTableViewCell.self, forCellReuseIdentifier: YiFanShangLivestreamTableViewCellReusableIdentifier)
        return tableView
    }()

    let emptyView = EmptyView(type: .yfsLive)

    var isCanContentScroll = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "FF7C74")

        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalTo(-Constants.kScreenBottomInset)
        }

        view.addSubview(emptyView)
        emptyView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.bottom.equalToSuperview()
        }
    }

    func scrollToTop() {
        tableView.setContentOffset(.zero, animated: false)
    }

    func updateData(records: [YiFanShangLiveStreamRecord]) {

        self.records = records

        tableView.reloadData()
    }
}

extension YFSLiveUserRecordViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: YiFanShangLivestreamTableViewCellReusableIdentifier, for: indexPath) as! YiFanShangLivestreamTableViewCell
        let record = records[indexPath.row]
        cell.configureWith(record: record)
        cell.isEvenNumber = indexPath.row % 2 == 0
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
}

extension YFSLiveUserRecordViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isCanContentScroll { // 内容不可滚动时
            scrollView.setContentOffset(.zero, animated: false)
            return
        }

        if scrollView.contentOffset.y <= 0 { // 下拉，即将显示头部时
            isCanContentScroll = false
            scrollView.setContentOffset(.zero, animated: false)
            NotificationCenter.default.post(name: .userCenterScrollState, object: nil)
        }
    }
}
