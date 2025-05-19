import RxSwift
import RxCocoa

protocol CollectionSelectionDelegate: class {
    func didSelected(collection: EggProduct.Collection, from product: EggProduct, indexPath: IndexPath)
}

class CollectionSelectionViewController: BaseViewController {

    private let CollectionSelectionCellIdentifier = "CollectionSelectionCellIdentifier"

    weak var delegate: CollectionSelectionDelegate?

    var viewModel: CollectionSelectionViewModel!

    var completionBlock: (() -> Void)?

    let contentView = UIView()

    init(product: EggProduct, indexPath: IndexPath, cachedCollection: EggProduct.Collection?) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = CollectionSelectionViewModel(product: product, indexPath: indexPath, cachedCollection: cachedCollection)
    }

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .grouped)
        tv.register(CollectionSelectionCell.self, forCellReuseIdentifier: CollectionSelectionCellIdentifier)
        tv.allowsMultipleSelection = false
        tv.isUserInteractionEnabled = true
        return tv
    }()

    let detailButton = UIButton.with(imageName: "snack_detail")

    let nextButton: UIButton = {
        let button = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "要定你啦！")
        button.setBackgroundColor(color: .qu_lightGray, forUIControlState: .disabled)
        button.setTitleColor(.white, for: .disabled)
        return button
    }()

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupView() {
        self.view.backgroundColor = .clear
        let blackView = UIView.withBackgounrdColor(.qu_popBackgroundColor)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        gesture.delegate = self
        blackView.addGestureRecognizer(gesture)
        blackView.tag = 440

        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        contentView.tag = 441
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.center.equalTo(blackView)
            make.height.equalTo(401)
        }

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: self.viewModel.product.value?.title)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(contentView).offset(24)
        }

        contentView.addSubview(detailButton)
        detailButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.left.equalTo(titleLabel.snp.right).offset(4)
            make.size.equalTo(15)
        }

        contentView.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(12)
            make.right.equalTo(contentView).offset(-12)
            make.height.equalTo(48)
            make.bottom.equalTo(contentView).offset(-20)
        }

    	contentView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalTo(contentView)
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.bottom.equalTo(nextButton.snp.top).offset(-20)
        }

        let line = UIView.seperatorLine()
        contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.equalTo(contentView)
            make.top.equalTo(tableView)
            make.height.equalTo(0.5)
        }

    }

    override func bindViewModels() {
        super.bindViewModels()

        self.tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        self.viewModel.items
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: CollectionSelectionCellIdentifier, cellType: CollectionSelectionCell.self)) { (_, item, cell) in
                cell.configureWith(collection: item)
                cell.bind(to: self.viewModel.state.asDriver(), as: item)
            }
            .disposed(by: disposeBag)

        self.tableView.rx.modelSelected(EggProduct.Collection.self)
            .asDriver()
            .drive(self.viewModel.selectedSubject)
            .disposed(by: disposeBag)

//        self.tableView.rx.itemDeselected
//            .subscribe(onNext: { [weak self] ip in
//                let cell = self?.tableView.cellForRow(at: ip) as! CollectionSelectionCell
//                cell.isSelected = false
//            })
//            .disposed(by: disposeBag)

        self.detailButton.rx.tap
            .asDriver()
            .withLatestFrom(self.viewModel.product.asDriver().filterNil())
            .drive(onNext: { [weak self] in
                self?.navigationController?.pushViewController(AccquiredItemDetailViewController(product: $0), animated: true)
            })
        	.disposed(by: disposeBag)

    	self.viewModel.state
            .map { $0.isNotEmpty }
        	.bind(to: self.nextButton.rx.isEnabled)
        	.disposed(by: disposeBag)

        let param = Driver.combineLatest(
        	self.viewModel.product.asDriver().filterNil(),
            self.viewModel.state.asDriver().map { $0.first }.filterNil(),
            self.viewModel.indexPath
        )

        self.nextButton.rx.tap
            .asDriver()
            .withLatestFrom(
            	param
            )
            .drive(onNext: { [weak self] pair in
                self?.delegate?.didSelected(collection: pair.1, from: pair.0, indexPath: pair.2)
                self?.dismissVC()
            })
        	.disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    @objc func dismissVC() {
        if let completion = self.completionBlock {
            completion()
        }

        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}

extension CollectionSelectionViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        let p = gestureRecognizer.location(in: view)
        if self.contentView.frame.contains(p) {
            return false
        }
        return true
    }
}

extension CollectionSelectionViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}
