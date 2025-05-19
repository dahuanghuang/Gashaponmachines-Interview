// 我的 - 扭蛋记录
import UIKit
import RxDataSources
import MJRefresh

private let GameRecordTableViewCellReusableIdentifier = "GameRecordTableViewCellReusableIdentifier"

class GameRecordViewController: BaseViewController, Refreshable {

    var viewModel: GameRecordViewModel = GameRecordViewModel()

    var refreshHeader: MJRefreshHeader?

    var refreshFooter: MJRefreshFooter?

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .plain)
        tv.emptyDataSetDelegate    = self
        tv.emptyDataSetDataSource = self
        tv.backgroundColor = .new_backgroundColor
        tv.register(GameRecordTableViewCell.self, forCellReuseIdentifier: GameRecordTableViewCellReusableIdentifier)
        return tv
    }()

    var types: [GameRecordEnvelope.GameRecordType] = []
    
    let dropDownView = GameRecordDropDownView()
    
    let arrowIv = UIImageView(image: UIImage(named: "game_record_arrow_down"))
    
    let navBar = CustomNavigationBar()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.viewBackgroundColor
        
        navBar.backgroundColor = .new_backgroundColor
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }
        
        let titleView = UIView.withBackgounrdColor(.clear)
        navBar.addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.left.equalTo(52)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(Constants.kNavHeight)
        }
        
        let recordTitleLb = UILabel.with(textColor: .black, boldFontSize: 32, defaultText: "全部扭蛋记录")
        titleView.addSubview(recordTitleLb)
        recordTitleLb.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }
        
        titleView.addSubview(arrowIv)
        arrowIv.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(recordTitleLb.snp.right)
            make.size.equalTo(28)
        }
        
        let titleButton = UIButton()
        titleButton.addTarget(self, action: #selector(titleButtonClick), for: .touchUpInside)
        titleView.addSubview(titleButton)
        titleButton.snp.makeConstraints { make in
            make.left.equalTo(recordTitleLb)
            make.right.equalTo(arrowIv)
            make.centerY.height.equalToSuperview()
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(view)
            make.top.equalTo(navBar.snp.bottom)
        }
        
        dropDownView.delegate = self
        dropDownView.isHidden = true
        dropDownView.frame = CGRect(x: 0, y: Constants.kStatusBarHeight + Constants.kNavHeight, width: Constants.kScreenWidth, height: 0)
        view.addSubview(dropDownView)

        refreshHeader = initRefreshHeader(.index, scrollView: tableView) { [weak self] in
            self?.viewModel.refreshTrigger.onNext(())
        }
        refreshHeader?.beginRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @objc func titleButtonClick() {
        dropDownView.isHidden = !dropDownView.isHidden
        if !dropDownView.isHidden {
            navBar.backgroundColor = .white
        }
        let img = dropDownView.isHidden ? "game_record_arrow_down" : "game_record_arrow_up"
        arrowIv.image = UIImage(named: img)
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        self.viewModel.items
            .asDriver()
            .drive(self.tableView.rx.items(cellIdentifier: GameRecordTableViewCellReusableIdentifier, cellType: GameRecordTableViewCell.self)) { (_, item, cell) in
            	cell.configureWith(record: item)
            }
            .disposed(by: disposeBag)

        self.viewModel.error
            .subscribe(onNext: { env in
                HUD.showErrorEnvelope(env: env)
            })
            .disposed(by: disposeBag)

        self.tableView.rx.reachedBottom
            .mapTo(())
            .skipWhile { self.viewModel.items.value.isEmpty }
            .bind(to: viewModel.loadNextPageTrigger)
            .disposed(by: disposeBag)

        self.viewModel.items
            .mapTo(())
            .subscribe(onNext: { [weak self] in
                self?.refreshHeader?.endRefreshing()
            })
            .disposed(by: disposeBag)

        self.viewModel.types
            .asObservable()
            .subscribe(onNext: { [weak self] types in
                self?.types = types
                self?.dropDownView.setupButtons(titles: types.compactMap { $0.name })
            })
            .disposed(by: disposeBag)
    }
}

extension GameRecordViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 103
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        if contentOffsetY <= 0 { // 下拉
            if dropDownView.isHidden {
                navBar.backgroundColor = .new_backgroundColor
            }
        } else { // 上拉
            navBar.backgroundColor = .white
        }
    }
}

extension GameRecordViewController: GameRecordDropDownViewDelegate {
    func didButtonClick(index: Int) {
        if let type = self.types[index].type, let IntType = Int(type) {
            self.viewModel.selectedType.accept(IntType)
        }
    }
}
