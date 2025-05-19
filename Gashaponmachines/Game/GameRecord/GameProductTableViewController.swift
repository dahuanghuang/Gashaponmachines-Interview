// 奖品详情
import UIKit
import RxDataSources
import Kingfisher

private let GameProductTableViewCellReusableIdentifier = "GameProductTableViewCellReusableIdentifier"

class GameProductTableViewController: BaseViewController {

    var canScroll: Bool = false

    var viewModel: GameProductTableViewModel = GameProductTableViewModel()

    var footerHeight: CGFloat = 0

    weak var delegate: GameContainerCellDelegate?

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .clear
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.kScreenBottomInset, right: 0)
        tv.register(GameProductTableViewCell.self, forCellReuseIdentifier: GameProductTableViewCellReusableIdentifier)
        return tv
    }()

    var footerView: GameProductTableFooterView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        self.viewModel.products
            .drive(self.tableView.rx.items(cellIdentifier: GameProductTableViewCellReusableIdentifier, cellType: GameProductTableViewCell.self)) { (_, item, cell) in
				cell.configureWith(product: item)
                cell.delegate = self
            }
            .disposed(by: disposeBag)

        self.viewModel.luckyProduct
            .drive(onNext: { [weak self] product in
                // 下载商品图, 计算出商品图实际高度, 再展示
                if let imageUrls = product.images {
                    ImageDownloadManager.shared.downloadImages(imageStrs: imageUrls) { images in
                        // 根据图片实际宽高比算出实际展示高度
                        let imagesHeight = images.map { (Constants.kScreenWidth - 24)/($0.size.width/$0.size.height) }.reduce(0, +)
                        self?.footerHeight = imagesHeight + GameProductTableFooterViewTitleBgIvH
                        self?.footerView = GameProductTableFooterView(luckyProduct: product, images: images)
                        self?.tableView.reloadData()
                    }
                }
        	})
        	.disposed(by: disposeBag)

        self.tableView.rx
            .modelSelected(Product.self)
            .asDriver()
            .drive(onNext: { [weak self] product in
                self?.delegate?.didSelectedGameProductTableviewCell(product: product)
            })
        	.disposed(by: disposeBag)

        self.viewModel.error.subscribe(onNext: { env in
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

extension GameProductTableViewController: GameProductTableViewCellDelegate {
    func didTappedProduct(product: Product) {
        self.delegate?.didSelectedGameProductTableviewCell(product: product)
    }
}

extension GameProductTableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 176
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.footerHeight
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.footerView
    }
}
