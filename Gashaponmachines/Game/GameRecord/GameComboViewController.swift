// 规则介绍
class GameComboViewController: BaseViewController {

    let viewModel = GameComboTableViewModel()

    var canScroll: Bool = false

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .plain)
        tv.backgroundColor = .white
//        tv.bounces = false
        tv.estimatedRowHeight = UITableView.automaticDimension
        tv.rowHeight = GameComboTableViewCell.cellHeight
        tv.register(GameComboTableViewCell.self, forCellReuseIdentifier: "GameComboTableViewCell")
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        self.viewModel.images
            .drive(self.tableView.rx.items(cellIdentifier: "GameComboTableViewCell", cellType: GameComboTableViewCell.self)) { (_, item, cell) in
                cell.configureWith(image: item)
            }
            .disposed(by: disposeBag)

        self.viewModel.error
            .subscribe(onNext: { env in
                HUD.showErrorEnvelope(env: env)
            })
            .disposed(by: disposeBag)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !canScroll {
            scrollView.contentOffset = .zero
            return
        }
        if scrollView.contentOffset.y <= 0 {
            canScroll = false
            scrollView.contentOffset = .zero
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "leaveTop"), object: nil)
        }
    }
}

extension GameComboViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GameComboTableViewCell.cellHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}

class GameComboTableViewCell: BaseTableViewCell {
    
    static let cellHeight = floor((Constants.kScreenWidth - 16 - 24) * 0.6)

    lazy var iv = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(Self.cellHeight)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
    }

    func configureWith(image: String) {
        iv.gas_setImageWithURL(image)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        iv.cancelNetworkImageDownloadTask()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
