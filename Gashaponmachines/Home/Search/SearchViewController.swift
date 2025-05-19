import UIKit

class SearchViewController: BaseViewController {
    /// 历史记录存储路径
    let filePath = NSHomeDirectory() + "/Documents/records.plist"

    /// 顶部搜索栏
    var searchView: SearchTopView

    /// 标题栏
    let titleView = SearchTittleView()

    /// 滚动视图
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.delegate = self
        view.backgroundColor = UIColor.clear
        view.bounces = false
        view.isPagingEnabled = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.contentSize = CGSize(width: Constants.kScreenWidth * 2, height: 500)
        return view
    }()

    /// 扭蛋机
    var machineVc = SearchProductViewController(style: .machine)

    /// 兑换商城
    var mallVc = SearchProductViewController(style: .mall)

    /// 搜索记录视图
    let searchRecordView = SearchRecordView()

    /// 占位文字
    var placeholder: String = ""

    /// 高频关键字
    var keywords = [String]()

    /// 历史记录
    var historyRecords = [String]()

    init(placeholder: String, keywords: [String]) {

        searchView = SearchTopView(placeholder: placeholder)

        super.init(nibName: nil, bundle: nil)

        self.placeholder = placeholder
        self.keywords = keywords
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 系统函数
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        if let array = NSArray(contentsOfFile: filePath) {
            for record in array {
                historyRecords.append(record as! String)
            }
        }

        setupSearchView()

        setupSearchRecordView()

        setupTitleView()

        setupChildVc()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - 初始化函数
    func setupSearchView() {
        view.addSubview(searchView)
        searchView.searchTextFiled.becomeFirstResponder()
        searchView.snp.makeConstraints { (make) in
            make.top.equalTo(Constants.kStatusBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        // 搜索
        searchView.searchReturnHandle = { [weak self] keyword in
            if keyword == "" { return }
            self?.handleHistoryRecord(keyword: keyword)
            self?.changeSearchViewState(keyword: keyword)
        }

        // 清除关键字
        searchView.clearAllTextHandle = { [weak self] in
            self?.searchRecordView.isHidden = false
            self?.titleView.isHidden = true
            self?.scrollView.isHidden = true
        }
    }

    func setupSearchRecordView() {
        view.addSubview(searchRecordView)
        searchRecordView.snp.makeConstraints { (make) in
            make.top.equalTo(searchView.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
        searchRecordView.updateData(hotRecords: keywords, historyRecords: historyRecords)
        // 搜索记录点击
        searchRecordView.keywordClickHandle = { [weak self] keyword in
            self?.searchView.searchTextFiled.text = keyword
            self?.handleHistoryRecord(keyword: keyword)
            self?.changeSearchViewState(keyword: keyword)
        }
        // 清除历史记录
        searchRecordView.cleanHistoryHandle = { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.historyRecords.count == 0 { return }
            // 清除, 存储
            strongSelf.historyRecords.removeAll()
            let array: NSArray = strongSelf.historyRecords as NSArray
            array.write(toFile: strongSelf.filePath, atomically: true)
        }
    }

    func setupTitleView() {
        titleView.isHidden = true
        view.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.top.equalTo(searchView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }

        // 标题选中回调
        titleView.selectButtonHandle = { [weak self] index in
            if var offset = self?.scrollView.contentOffset {
                offset.x = Constants.kScreenWidth * CGFloat(index)
                self?.scrollView.setContentOffset(offset, animated: true)
            }
        }
    }

    func setupChildVc() {
        scrollView.isHidden = true
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.right.left.bottom.equalToSuperview()
            make.top.equalTo(titleView.snp.bottom)
        }

        let bgView = UIView.withBackgounrdColor(.clear)
        scrollView.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(2.0)
            make.height.equalToSuperview()
        }

        self.addChild(machineVc)
        bgView.addSubview(machineVc.view)
        machineVc.view.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(Constants.kScreenWidth)
        }
        machineVc.productCountHandle = { [weak self] count in
            self?.titleView.machineTitle = "扭蛋机(\(count))"
        }

        self.addChild(mallVc)
        bgView.addSubview(mallVc.view)
        mallVc.view.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(Constants.kScreenWidth)
        }
        mallVc.productCountHandle = { [weak self] count in
            self?.titleView.mallTitle = "兑换商城(\(count))"
        }
    }

    // MARK: - 自定义函数
    /// 处理历史记录
    func handleHistoryRecord(keyword: String) {
        // 去重
        for record in historyRecords {
            let recordIndex = historyRecords.firstIndex(of: record)
            if keyword == record, let index = recordIndex {
                historyRecords.remove(at: index)
                break
            }
        }
        // 新旧循环
        if historyRecords.count >= 10 {
            historyRecords.removeFirst()
        }
        // 添加, 存储
        historyRecords.append(keyword)
        let array: NSArray = historyRecords as NSArray
        array.write(toFile: filePath, atomically: true)
        searchRecordView.updateData(hotRecords: keywords, historyRecords: historyRecords)
    }

    /// 改变搜索界面的状态
    func changeSearchViewState(keyword: String) {
        machineVc.keyword = keyword
        mallVc.keyword = keyword
        titleView.currentIndex = 0
        searchView.searchTextFiled.resignFirstResponder()
        searchRecordView.isHidden = true
        titleView.isHidden = false
        scrollView.isHidden = false
    }

    // MARK: - 重写函数
    override func bindViewModels() {
        searchView.cancelButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: false)
            })
            .disposed(by: disposeBag)
    }
}

extension SearchViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = scrollView.contentOffset.x / scrollView.frame.size.width
        titleView.currentIndex = Int(index)
    }
}
