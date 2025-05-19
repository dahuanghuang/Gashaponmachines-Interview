import UIKit
import SnapKit
import RxSwift
import RxCocoa
import MJRefresh

//extension Notification.Name {
//    // 商城页内容上划下划通知(顶部背景状态控制)
//    public static let MallContentScroll = Notification.Name("MallContentScroll")
//}

private let MallContentCollectionViewCellId = "MallContentCollectionViewCellId"

class MallChildViewController: BaseViewController, Refreshable {
    
//    /// 当前滚动的Y值
//    var contentOffSetY: CGFloat = 0

    lazy var contentView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = (Constants.kScreenWidth - 38)/3
        layout.itemSize = CGSize(width: width, height: width + 72)
        layout.minimumInteritemSpacing = 7
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 0, right: 12)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
//        cv.delegate = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(MallContentCollectionViewCell.self, forCellWithReuseIdentifier: MallContentCollectionViewCellId)
        return cv
    }()

    private var viewModel: MChildViewModel!

    private var mallCollectionId: String!

    private var refreshHeader: MJRefreshHeader?

    private var refreshFooter: MJRefreshFooter?

    init(mallCollectionId: String) {
        super.init(nibName: nil, bundle: nil)
        self.mallCollectionId = mallCollectionId
        self.viewModel = MChildViewModel(mallCollectionId: mallCollectionId)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white

        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        refreshHeader = initRefreshHeader(.index, scrollView: contentView) { [weak self] in
            self?.viewModel?.refreshTrigger.onNext(())
        }

        self.refreshHeader?.beginRefreshing()
    }
    

    override func bindViewModels() {
        super.bindViewModels()

        self.viewModel.items
            .asDriver()
            .drive(self.contentView.rx.items(cellIdentifier: MallContentCollectionViewCellId, cellType: MallContentCollectionViewCell.self)) { (indexPath, item, cell) in
                cell.configureWith(product: item)
            }
            .disposed(by: disposeBag)

        self.contentView.rx.modelSelected(MallProduct.self)
            .asDriver()
            .map { $0.productId }
            .filterNil()
            .drive(onNext: { [weak self] productId in
                self?.navigationController?.pushViewController(MallDetailViewController(mallProductId: productId), animated: true)
            })
            .disposed(by: disposeBag)

        self.contentView.rx.reachedBottom
            .withLatestFrom(viewModel.items.asObservable())
            .filterEmpty()
            .mapTo(())
            .bind(to: viewModel.loadNextPageTrigger)
            .disposed(by: disposeBag)

        self.viewModel.items
            .mapTo(())
            .subscribe(onNext: { [weak self] in
                self?.refreshHeader?.endRefreshing()
            })
            .disposed(by: disposeBag)

        self.viewModel.error
            .subscribe(onNext: { env in
                HUD.showErrorEnvelope(env: env)
            })
            .disposed(by: disposeBag)
    }
}

//extension MallChildViewController: UICollectionViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let difference = scrollView.contentOffset.y - contentOffSetY
//        if difference > 0 { // 上拉
//            NotificationCenter.default.post(name: .MallContentScroll, object: nil, userInfo: ["isPullUP": true])
//        } else { // 下拉
//            NotificationCenter.default.post(name: .MallContentScroll, object: nil, userInfo: ["isPullUP": false])
//        }
//        contentOffSetY = scrollView.contentOffset.y
//    }
//}
