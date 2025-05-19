import RxCocoa
import RxSwift

class EnvironmentViewController: BaseViewController {

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: self.view.frame, style: .grouped)
        tv.register(EnvironmentTableViewCell.self, forCellReuseIdentifier: "EnvironmentTableViewCell")
        tv.backgroundColor = .white
        tv.separatorStyle = .singleLine
        return tv
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "测试功能 \(AppEnvironment.current.stage.rawValue)"
        self.view.addSubview(tableView)

    }

    override func bindViewModels() {
        super.bindViewModels()

        Observable.just(EnvironmentOption.allCases)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: "EnvironmentTableViewCell", cellType: EnvironmentTableViewCell.self)) { (_, item, cell) in
                cell.titleLabel.text = item.rawValue
            }
            .disposed(by: disposeBag)

        self.tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        self.tableView.rx.modelSelected(EnvironmentOption.self)
        	.asDriver()
            .drive(onNext: { [weak self] option in
                switch option {
                case .testvc:
                    self?.navigationController?.pushViewController(TestViewController(), animated: true)
                case .copyAccessToken:
                    UIPasteboard.general.string = AppEnvironment.current.apiService.accessToken
                    HUD.success(second: 2, text: "复制成功", completion: nil)
                case .clearUserDefault:
                    let domain = Bundle.main.bundleIdentifier!
                    AppEnvironment.userDefault.removePersistentDomain(forName: domain)
                    AppEnvironment.userDefault.synchronize()
                    HUD.success(second: 2, text: "清除成功", completion: nil)
                case .bugtagsFloatingball:
//                    BugtagsService.openBundle()
                    HUD.success(second: 2, text: "切换成功", completion: nil)
                case .bugtagsShake:
//                    BugtagsService.openShake()
                    HUD.success(second: 2, text: "切换成功", completion: nil)
                case .test:
                    AppEnvironment.switchEnvironmentStage(.test)
                    HUD.success(second: 2, text: "切换成功", completion: nil)
                case .stage:
                    AppEnvironment.switchEnvironmentStage(.stage)
                    HUD.success(second: 2, text: "切换成功", completion: nil)
                case .release:
                    AppEnvironment.switchEnvironmentStage(.release)
                    HUD.success(second: 2, text: "切换成功", completion: nil)
                }
            })
        	.disposed(by: disposeBag)
    }
}

extension EnvironmentViewController: UITableViewDelegate {

}

class EnvironmentTableViewCell: BaseTableViewCell {

    lazy var titleLabel = UILabel()

    lazy var detailLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.textColor = .black
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
        }

        detailLabel.textColor = .black
        self.contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right).offset(20)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum EnvironmentOption: String, CaseIterable {
    case testvc = "测试试图"
    case copyAccessToken = "复制 AccessToken"
    case clearUserDefault = "清除本地缓存"
    case bugtagsFloatingball = "Bugtags 悬浮球"
    case bugtagsShake = "Bugtags 摇一摇"
    case test = "测试环境 - test"
    case stage = "预发布环境 - stage"
    case release = "正式环境 - release"
}
