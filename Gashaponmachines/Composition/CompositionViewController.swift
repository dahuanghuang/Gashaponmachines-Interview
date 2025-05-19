// 合成首页
import Foundation
import SnapKit
import MJRefresh
import RxDataSources

private let CompositionCollectionViewCellIdentifier = "CompositionCollectionViewCellIdentifier"
private let CompositionCollectionViewHeaderIdentifier = "CompositionCollectionViewHeaderIdentifier"
let CompositionCollectionViewCellWidth: CGFloat = (Constants.kScreenWidth - 12 * 3) / 2
private let CompositionCollectionViewCellHeight: CGFloat = CompositionCollectionViewCellWidth + 12 + UIFont.heightOfBoldPixel(28) + 12 + 12 + 16 + UIFont.heightOfPixel(24) + 16

class CompositionViewController: BaseViewController, Refreshable {

    var refreshHeader: MJRefreshHeader?

    var refreshFooter: MJRefreshFooter?

    let viewModel: CompositionViewModel = CompositionViewModel()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 12, right: 12)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.itemSize = CGSize(width: CompositionCollectionViewCellWidth, height: CompositionCollectionViewCellHeight)
        layout.headerReferenceSize = CGSize(width: Constants.kScreenWidth, height: 0.7 * Constants.kScreenWidth)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(hex: "ffe6ac")
        cv.register(CompositionCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CompositionCollectionViewHeaderIdentifier)
        cv.register(CompositionCollectionViewCell.self, forCellWithReuseIdentifier: CompositionCollectionViewCellIdentifier)
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        self.navigationItem.title = "合成"

        self.navigationItem.rightBarButtonItem = UIBarButtonItem.barButtonItemWith(text: "合成记录",
                                                                                   target: self,
                                                                                   selector: #selector(goToRecord))

        refreshHeader = initRefreshHeader(.index, scrollView: collectionView) { [weak self] in
            self?.viewModel.refreshTrigger.onNext(())
        }
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.collectionView.rx.reachedBottom
            .mapTo(())
            .skipWhile { self.viewModel.items.value.isEmpty }
            .bind(to: viewModel.loadNextPageTrigger)
            .disposed(by: disposeBag)

        self.collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        let tap = UITapGestureRecognizer(target: self, action: #selector(goToRules))

        let datasource = RxCollectionViewSectionedReloadDataSource<ComposePathListSectionModel>(
            configureCell: { (_, cv, ip, i) in
                let cell = cv.dequeueReusableCell(withReuseIdentifier: CompositionCollectionViewCellIdentifier, for: ip) as! CompositionCollectionViewCell
                cell.configureWith(path: self.viewModel.items.value[ip.row])
                return cell
        },
            configureSupplementaryView: { (ds, cv, kind, ip) in
                let section = cv.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CompositionCollectionViewHeaderIdentifier, for: ip) as! CompositionCollectionViewHeader
                section.configureWith(image: self.viewModel.introImage.value)
                section.addGestureRecognizer(tap)
                return section
        })

        self.viewModel.items
            .map { [ComposePathListSectionModel(paths: $0)] }
            .bind(to: self.collectionView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)

        self.collectionView.rx
            .modelSelected(ComposePath.self)
            .asDriver()
            .drive(onNext: { [weak self] path in
                self?.navigationController?.pushViewController(CompositionDetailViewController(composePathId: path.composePathId), animated: true)
            })
        	.disposed(by: disposeBag)

        self.collectionView.rx.reachedBottom
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
    }

    @objc func goToRules() {
        RouterService.route(to: self.viewModel.rule.value)
    }

    @objc func goToRecord() {
        self.navigationController?.pushViewController(CompositionRecordViewController(), animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: animated)

        viewModel.refreshTrigger.onNext(())
    }
}

extension CompositionViewController: UICollectionViewDelegate {

}

struct ComposePathListSectionModel {
    var paths: [ComposePath]
}

extension ComposePathListSectionModel: SectionModelType {
    public var items: [ComposePath] {
        return self.paths
    }

    public init(original: ComposePathListSectionModel, items: [ComposePath]) {
        self = original
    }

    public typealias Item = ComposePath
}
