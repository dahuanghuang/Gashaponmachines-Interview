import UIKit
import RxSwift
import RxCocoa
import MJRefresh

/// 首页机台列表类型
enum HomeMachineListStyle {
    case all // 全部
    case other // 其他(如: 最近, 新入荷, 扭蛋...)
}

class HomeMachineListViewController: BaseViewController, Refreshable {

    var refreshHeader: MJRefreshHeader?

    var refreshFooter: MJRefreshFooter?

    let viewModel: HomeMachineViewModel!
    /// 机台类型数组(白机台, 红机台, 黑机台...)
    var machineTypes: [HomeMachineType]?
    /// 当前Tag标签(如: 最近, 新入荷, 扭蛋...)
    var machineTag: HomeMachineTag?
    /// 控制器类型
    var style: HomeMachineListStyle!
    /// 空视图
    let emptyView = EmptyView(type: .home)
    /// 当前滚动的Y值
    var contentOffSetY: CGFloat = 0
    /// 上一次滚动是否向上
    var isScrollUp: Bool = false

    /// 标题视图
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 44, left: 12, bottom: 12, right: 12)
        layout.itemSize = CGSize(width: HomeMachineCell.cellW, height: HomeMachineCell.cellH)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.contentInset = UIEdgeInsets(top: headViewH, left: 0, bottom: 0, right: 0)
        cv.register(HomeMachineCell.self, forCellWithReuseIdentifier: HomeMachineCellId)
        return cv
    }()

    /// 头部标签视图
    let headView = HomeMachineListHeadView()
    /// 头部标签视图高度
    var headViewH: CGFloat = 60
    /// 是否没有数据
    var isNoData: Bool = false

    // MARK: - Initialize
    /// 初始化"全部"机台列表
    ///   - machineTypes: 机台类型数组(如:白机台, 红机台, 黑机台...)
    init(style: HomeMachineListStyle, machineTypes: [HomeMachineType]) {
        self.viewModel = HomeMachineViewModel(style: style)
        super.init(nibName: nil, bundle: nil)

        self.style = style
        self.machineTypes = machineTypes
    }

    /// 初始化"其他"机台列表
    ///   - machineTag: 当前的展示Tag标签(如: 最近, 新入荷, 扭蛋...)
    init(style: HomeMachineListStyle, machineTag: HomeMachineTag) {
        self.viewModel = HomeMachineViewModel(style: style)
        super.init(nibName: nil, bundle: nil)

        if let tags = machineTag.subTags {
            headView.isHidden = tags.isEmpty
        }

        self.style = style
        self.machineTag = machineTag
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        self.refreshHeader = initRefreshHeader(.index, scrollView: self.collectionView, { [weak self] in
            guard let sSelf = self else { return }
            if sSelf.isNoData {
                sSelf.refreshHeader?.endRefreshing()
            }
            sSelf.refreshFooter?.endRefreshing()
            sSelf.viewModel.refreshTrigger.onNext(())
        })

        self.refreshFooter = initBlackRefreshFooter(scrollView: self.collectionView, { [weak self] in
            self?.refreshHeader?.endRefreshing()
            self?.viewModel.loadNextPageTrigger.onNext(())
        })

        requestData(index: 0)

        self.refreshFooter?.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showSearchBar()
    }

    func setupUI() {
        view.backgroundColor = .new_backgroundColor

        // 列表
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        // 头部标签
        headView.frame = CGRect(x: 0, y: 44, width: Constants.kScreenWidth, height: headViewH)
        view.addSubview(headView)
        if style == .all {
            if let types = machineTypes {
                headView.setupDatas(style: .all, machineTypes: types)
            }
        } else {
            if let subTags = machineTag?.subTags {
                headView.setupDatas(style: .other, machineTags: subTags)
            }
        }
        headView.selectTypeHandle = { [weak self] index in
            self?.requestData(index: index)
        }

        // 空视图
        collectionView.addSubview(emptyView)
        emptyView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.size.equalToSuperview()
        }
    }

    func hideSearchBar() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.headView.top = 0
            self.headView.backgroundColor = .white
        }, completion: { _ in
            self.isScrollUp = true
        })
    }

    func showSearchBar() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.headView.top = 44
            self.headView.backgroundColor = .new_backgroundColor
        }, completion: { _ in
            self.isScrollUp = false
        })
    }

    /// 请求机台数据
    /// - Parameter index: 选中的第几个标签
    func requestData(index: Int) {
        if style == .all {
            if let machineTypes = self.machineTypes {
                viewModel.requestMachineList.onNext(machineTypes[index].type)
            }
        } else {
            if index == 0 { // 请求当前Tag数据(全部)
                if let machineTag = self.machineTag {
                    viewModel.requestMachineList.onNext(machineTag.tagId)
                }
            } else { // 请求subTag数据(全部后面的)
                if let tags = machineTag?.subTags, !tags.isEmpty {
                    viewModel.requestMachineList.onNext(tags[index].tagId)
                }
            }
        }

        viewModel.refreshTrigger.onNext(())
    }

    /// 改变机台列表的状态
    func changeMachineListState(itemCount: Int) {
        if itemCount == 0 { // 没有数据
            isNoData = true
            emptyView.isHidden = false
            refreshFooter?.isHidden = true
        } else { // 有数据
            isNoData = false
            emptyView.isHidden = true
            refreshFooter?.isHidden = false
        }
        
        // 修改collectionView离上面的间距
        if self.style == .other {
            if let subTags = self.machineTag?.subTags {
                collectionView.contentInset = UIEdgeInsets(top: subTags.isEmpty ? 12 : headViewH, left: 0, bottom: 0, right: 0)
            }else {
                collectionView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
            }
        }
    }

    override func bindViewModels() {
        viewModel.items
            .subscribe(onNext: { [weak self] items in
                self?.changeMachineListState(itemCount: items.count)
                self?.refreshHeader?.endRefreshing()
                self?.refreshFooter?.endRefreshing()
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension HomeMachineListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeMachineCellId, for: indexPath) as! HomeMachineCell
        cell.config(machine: viewModel.items.value[indexPath.row])
        return cell
    }
}

extension HomeMachineListViewController: UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 { // 防止回弹效果
            return
        }

        let difference = scrollView.contentOffset.y - contentOffSetY
        if difference > 0 { // 上拉
            if !isScrollUp {
                NotificationCenter.default.post(name: .HomeContentPullUpScroll, object: nil)
                isScrollUp = true
                hideSearchBar()
            }
        } else { // 下拉
            if isScrollUp {
                NotificationCenter.default.post(name: .HomeContentPullDownScroll, object: nil)
                isScrollUp = false
                showSearchBar()
            }
        }

        contentOffSetY = scrollView.contentOffset.y
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let machine = viewModel.items.value[indexPath.row]
        if let type = MachineColorType(rawValue: machine.type.rawValue) {
            // 登录界面
            guard AppEnvironment.current.apiService.accessToken != nil else {
                let vc = LoginViewController.controller
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
                return
            }

            // 游戏界面
            let vc = NavigationController(rootViewController: GameNewViewController(physicId: machine.physicId, type: type))
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        } else {
            HUD.showError(second: 1.0, text: "机台类型出错", completion: nil)
        }
    }
}
