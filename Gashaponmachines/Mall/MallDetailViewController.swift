// 商品详情
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

private let MallDetailDescriptionCellReusIdentifier = "MallDetailDescriptionCellReusIdentifier"

class MallDetailViewController: BaseViewController {

    var introImages: [String] = []

    var mallProductId: String

    let bottomView = MallDetailBottomExchangeView()
    
    let headerView = MallDetailHeaderView()
    
    /// 是否显示过特殊提醒弹窗
    var isShowNotification = false

    init(mallProductId: String) {
        self.mallProductId = mallProductId
        self.viewModel = MallDetailViewModel(mallProductId: mallProductId)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .new_backgroundColor
        tv.dataSource = self
        tv.delegate = self
        tv.separatorStyle = .none
        tv.rowHeight = MallDetailDescriptionCell.CellH
        tv.register(MallDetailDescriptionCell.self, forCellReuseIdentifier: MallDetailDescriptionCellReusIdentifier)
        return tv
    }()

    var viewModel: MallDetailViewModel!

    var detailEnvelope: MallProductDetailEnvelope?
    
    let titleView = MallDetailTitleView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .new_backgroundColor
        
        self.view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            make.height.equalTo(60 + Constants.kScreenBottomInset)
            make.bottom.equalToSuperview()
        }
        
        let statusView = UIView.withBackgounrdColor(.white)
        self.view.insertSubview(statusView, belowSubview: bottomView)
        statusView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight)
        }

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.view.insertSubview(tableView, belowSubview: bottomView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(statusView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        titleView.isHidden = true
        self.view.insertSubview(titleView, belowSubview: bottomView)
        titleView.snp.makeConstraints { make in
            make.top.equalTo(statusView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        self.viewModel.viewDidLoadTrigger.onNext(())
    }
    
    func setupHeaderView(env: MallProductDetailEnvelope) {
        headerView.configureWith(product: env.product)
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        headerView.frame = CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: height)
        tableView.tableHeaderView = headerView
    }
    
    /// 底部按钮点击跳转处理
    func bottonViewTapHandle() {
        guard let env = self.detailEnvelope else { return }
        
        if let view = self.exchangeView, self.view.subviews.contains(view) { // 跳转发货界面
            let worth = Int(env.product.worth) ?? 0
            let vc = ConfirmDeliveryViewController(style: .mallProduct, mallProductId: self.mallProductId, worth: worth, count: view.currentCount)
            self.navigationController?.pushViewController(vc, animated: true)
            view.hide()
        }else { // 展示兑换视图
            let exchangeView = MallDetailExchangeView(env: env)
            self.view.insertSubview(exchangeView, belowSubview: self.bottomView)
            exchangeView.snp.makeConstraints({ (make) in
                make.left.top.right.equalToSuperview()
                make.bottom.equalTo(self.bottomView.snp.top).offset(12)
            })
            self.exchangeView = exchangeView
        }
    }

    override func bindViewModels() {
        super.bindViewModels()
        
        self.viewModel.detail.subscribe(onNext: { [weak self] env in
            self?.detailEnvelope = env
            self?.bottomView.config(worth: env.product.worth)
            self?.titleView.config(title: env.product.title)
            self?.setupHeaderView(env: env)
            self?.introImages = env.product.introImages ?? []
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)

        headerView.rx.backButtonTap.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        titleView.rx.backButtonTap.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        bottomView.rx.buttonTap.asObservable()
            .subscribe(onNext: { [weak self] in
                guard let s = self else { return }
                guard let env = s.detailEnvelope else { return }
                
                // 有提醒字段, 且没有提醒过
                if let n1 = env.notification1, !s.isShowNotification {
                    s.isShowNotification = true
                    let vc = RemindPopViewController(imageStr: "mall_exchange_remind", title: "确认兑换吗", n1Text: n1, n2Text: env.notification2)
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    vc.comfirmButtonClickHandle = { [weak self] in
                        self?.bottonViewTapHandle()
                    }
                    s.navigationController?.present(vc, animated: true, completion: nil)
                    return
                }
            
                // 走正常点击逻辑
                s.bottonViewTapHandle()
            })
            .disposed(by: disposeBag)

        self.viewModel.error.subscribe(onNext: { env in
            HUD.showErrorEnvelope(env: env)
        })
        .disposed(by: disposeBag)
    }

    var exchangeView: MallDetailExchangeView?
}

extension MallDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.introImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MallDetailDescriptionCellReusIdentifier, for: indexPath) as! MallDetailDescriptionCell
        cell.configureWith(image: introImages[indexPath.row])
        return cell
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
        var y = scrollView.contentOffset.y
        
        // 改变底部兑换视图的状态
        if y <= 40 { // 下拉
            if y <= 0 {
                tableView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: 0), animated: false)
                tableView.bounces = false
            }
            bottomView.changeState(false)
            titleView.isHidden = true
        } else { // 上拉
            tableView.bounces = true
            if y >= Constants.kStatusBarHeight {
                y = Constants.kStatusBarHeight
            }
            bottomView.changeState(true)
            titleView.isHidden = false
        }
    }
}
