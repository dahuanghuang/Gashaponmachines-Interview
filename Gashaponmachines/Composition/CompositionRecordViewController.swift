import RxDataSources
import RxSwift
import MJRefresh

private let CompositionRecordCollectionCellIdentifier = "CompositionRecordCollectionCellIdentifier"
private let CompositionRecordCollectionViewHeaderIdentifier = "CompositionRecordCollectionViewHeaderIdentifier"

class CompositionRecordViewController: BaseViewController, Refreshable {

    let vm = CompositionRecordViewModel()

    var refreshHeader: MJRefreshHeader?

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: Constants.kScreenWidth, height: 0.34 * Constants.kScreenWidth)
        layout.itemSize = CGSize(width: CompositionRecordCollectionCell.width, height: CompositionRecordCollectionCell.height)
        layout.sectionInset = UIEdgeInsets(top: 4, left: 12, bottom: 12, right: 12)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(hex: "ffe6ac")
        cv.showsHorizontalScrollIndicator = false
        cv.register(CompositionRecordCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CompositionRecordCollectionViewHeaderIdentifier)
        cv.register(CompositionRecordCollectionCell.self, forCellWithReuseIdentifier: CompositionRecordCollectionCellIdentifier)
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "合成记录"

        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.vm.refreshTrigger.onNext(())

        refreshHeader = initRefreshHeader(.index, scrollView: collectionView) { [weak self] in
            self?.vm.refreshTrigger.onNext(())
        }
    }

    override func bindViewModels() {
    	super.bindViewModels()

        self.collectionView.rx.setDelegate(self).disposed(by: disposeBag)

        let datasource = RxCollectionViewSectionedReloadDataSource<ComposeRecordListSectionModel>(
            configureCell: { (_, cv, ip, i) in
                let cell = cv.dequeueReusableCell(withReuseIdentifier: CompositionRecordCollectionCellIdentifier, for: ip) as! CompositionRecordCollectionCell
                cell.configureWith(record: self.vm.items.value[ip.row])
                return cell
        },
            configureSupplementaryView: { (ds, cv, kind, ip) in
                let header = cv.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CompositionRecordCollectionViewHeaderIdentifier, for: IndexPath(item: 0, section: 0)) as! CompositionRecordCollectionViewHeader
                header.configureWith(savingCount: self.vm.totalSavingCount.value)
                return header
        })

        self.vm.items
            .map { [ComposeRecordListSectionModel(records: $0)] }
            .bind(to: self.collectionView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)

        self.collectionView.rx.modelSelected(ComposeRecord.self)
            .asDriver()
            .drive(onNext: { [weak self] item in
                self?.navigationController?.pushViewController(CompositionRecordDetailViewController(record: item), animated: true)
            })
        	.disposed(by: disposeBag)

        self.collectionView.rx.reachedBottom
            .mapTo(())
            .skipWhile { self.vm.items.value.isEmpty }
            .bind(to: vm.loadNextPageTrigger)
            .disposed(by: disposeBag)

        self.vm.items
            .mapTo(())
            .subscribe(onNext: { [weak self] in
                self?.refreshHeader?.endRefreshing()
            })
            .disposed(by: disposeBag)
    }
}

extension CompositionRecordViewController: UICollectionViewDelegate {}

struct ComposeRecordListSectionModel {
    var records: [ComposeRecord]
}
extension ComposeRecordListSectionModel: SectionModelType {
    public var items: [ComposeRecord] {
        return self.records
    }

    public init(original: ComposeRecordListSectionModel, items: [ComposeRecord]) {
        self = original
    }

    public typealias Item = ComposeRecord
}
