import UIKit
import RxSwift
import RxCocoa

/// 搜索控制器类型
enum SearchProductVcStyle: String {
    case machine = "EGG"    // 扭蛋机
    case mall = "MALL"      // 商城
}

class SearchProductViewController: BaseViewController {

    /// 商品数量回调
    var productCountHandle: ((Int) -> Void)?

    var keyword: String? {
        willSet {
            if let keyword = newValue {
                self.viewModel.searchKeyword.onNext(keyword)
            }
        }
    }

    var viewModel: SearchViewModel!

    var style: SearchProductVcStyle!

    var machines = [HomeMachine]()

    var products = [SearchMallProduct]()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 8, right: 12)
        layout.itemSize = CGSize(width: HomeMachineCell.cellW, height: HomeMachineCell.cellH)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(hex: "f5f4f2")
        cv.dataSource = self
        cv.delegate = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        if self.style == .machine {
            cv.register(HomeMachineCell.self, forCellWithReuseIdentifier: HomeMachineCellId)
        } else {
            cv.register(SearchProductMallCell.self, forCellWithReuseIdentifier: SearchProductMallCellId)
        }

        return cv
    }()

    init(style: SearchProductVcStyle) {
        self.viewModel = SearchViewModel(style: style)
        super.init(nibName: nil, bundle: nil)

        self.style = style
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    override func bindViewModels() {
        viewModel.searchEnvelope
            .subscribe(onNext: { [weak self] env in
                if self?.style == .machine {
                    if let handle = self?.productCountHandle {
                        handle(env.machines.count)
                    }
                    self?.machines = env.machines
                } else {
                    if let handle = self?.productCountHandle {
                        handle(env.mallProducts.count)
                    }
                    self?.products = env.mallProducts
                }
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    func pushToGameVc(machine: HomeMachine) {
        if let type = MachineColorType(rawValue: machine.type.rawValue) {
            let vc = NavigationController(rootViewController: GameNewViewController(physicId: machine.physicId, type: type))
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        } else {
            HUD.showError(second: 1.0, text: "机台类型出错", completion: nil)
        }
    }
}

extension SearchProductViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.style == .machine ? self.machines.count : self.products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.style == .machine {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeMachineCellId, for: indexPath) as! HomeMachineCell
            cell.config(machine: machines[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchProductMallCellId, for: indexPath) as! SearchProductMallCell
            cell.config(product: products[indexPath.row])
            return cell
        }
    }
}

extension SearchProductViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if style == .machine {
            pushToGameVc(machine: machines[indexPath.row])
        } else {
            let product = products[indexPath.row]
            navigationController?.pushViewController(MallDetailViewController(mallProductId: product.productId), animated: true)
        }
    }
}
