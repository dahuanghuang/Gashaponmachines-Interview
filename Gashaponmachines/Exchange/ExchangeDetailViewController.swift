import UIKit
import RxDataSources
import RxSwift
import RxCocoa

private let ExchangeDetailTableViewCellReuseIdentifier = "ExchangeDetailTableViewCellReuseIdentifier"

class ExchangeDetailViewController: BaseViewController {

    required init(allProducts: [EggProduct],
                  selectedProducts: [EggProduct]?,
                  title: String,
                  subTitle: String) {
        self.viewModel = ExchangeDetailViewModel(allProducts: allProducts,
                                                 selectedProducts: selectedProducts,
                                                 submitSignal: self.bottomView.confirmButton.rx.tap.asSignal())
        self.header.updateTitle(title: title)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var viewModel: ExchangeDetailViewModel

    let bottomView = ExchangeDetailBottomView()
    
    let header = ExchangeDetailTableHeaderView()

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .grouped)
        tv.layer.masksToBounds = true
        tv.backgroundColor = .new_backgroundColor
        tv.register(ExchangeDetailTableViewCell.self, forCellReuseIdentifier: ExchangeDetailTableViewCellReuseIdentifier)
        return tv
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.viewWillAppearTrigger.onNext(())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear
        
        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        self.view.addSubview(header)
        header.snp.makeConstraints { make in
            make.top.equalTo(Constants.kStatusBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(52)
        }

        self.view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(Constants.kScreenBottomInset + 60)
        }

        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.tableView.rx.setDelegate(self).disposed(by: disposeBag)

        self.viewModel.products
            .drive(self.tableView.rx.items(cellIdentifier: ExchangeDetailTableViewCellReuseIdentifier, cellType: ExchangeDetailTableViewCell.self)) { (_, product, cell) in
                cell.bind(to: self.viewModel.state, as: product)
                cell.configureWith(eggProduct: product)
            }
        	.disposed(by: disposeBag)

        self.bottomView.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
            	self?.dismiss(animated: false, completion: nil)
        	})
        	.disposed(by: disposeBag)

        self.tableView.rx
            .modelSelected(EggProduct.self)
            .asDriver()
            .drive(self.viewModel.selectionObserver)
            .disposed(by: disposeBag)
    }
}

extension ExchangeDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 118
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}
