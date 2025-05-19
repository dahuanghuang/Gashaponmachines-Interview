import UIKit

let themeHeadViewH = Constants.kScreenWidth * 0.39 + 8

class HomeThemeViewController: BaseViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    var themeListEnvelope: HomeThemeListEnvelope?

    var viewModel: HomeThemeViewModel!

    init(themeId: String) {
        super.init(nibName: nil, bundle: nil)

        viewModel = HomeThemeViewModel(themeId: themeId)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 标题视图
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: HomeMachineCell.cellW, height: HomeMachineCell.cellH)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .new_backgroundColor
        cv.dataSource = self
        cv.delegate = self
        cv.bounces = true
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.contentInset = UIEdgeInsets(top: bgIvHeight + 12, left: 12, bottom: Constants.kScreenBottomInset, right: 12)
        cv.register(HomeMachineCell.self, forCellWithReuseIdentifier: HomeMachineCellId)
        return cv
    }()
    
    
    lazy var backgroundIv: UIImageView = {
        let iv = UIImageView()
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let maskView: UIView = UIView.withBackgounrdColor(.black.alpha(0.3))
    
    let titleLb = UILabel.with(textColor: .white, boldFontSize: 48)
    
    let bgIvHeight = 126 + Constants.kStatusBarHeight
    
    let titleTopInset = Constants.kStatusBarHeight + 56

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .new_backgroundColor
        
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        view.addSubview(backgroundIv)
        backgroundIv.snp.makeConstraints({ make in
            make.top.centerX.equalToSuperview()
            make.width.equalTo(Constants.kScreenWidth)
            make.height.equalTo(bgIvHeight)
        })
        
        backgroundIv.addSubview(maskView)
        maskView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
        
        let backIv = UIImageView(image: UIImage(named: "home_theme_back"))
        backIv.isUserInteractionEnabled = true
        backIv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(popVc)))
        view.addSubview(backIv)
        backIv.snp.makeConstraints { make in
            make.top.equalTo(Constants.kStatusBarHeight + 8)
            make.left.equalTo(12)
            make.size.equalTo(28)
        }
        
        view.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.top.equalTo(titleTopInset)
            make.left.equalTo(20)
        }
        
        viewModel.requestThemeList.onNext(())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @objc func popVc() {
        self.navigationController?.popViewController(animated: true)
    }

    override func bindViewModels() {
        viewModel.themeListEnvelope
            .subscribe(onNext: { [weak self] env in
                self?.backgroundIv.gas_setImageWithURL(env.machineTopicInfo.backgroudImage)
                self?.titleLb.text = env.machineTopicInfo.title
                self?.themeListEnvelope = env
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension HomeThemeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return themeListEnvelope?.machines.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeMachineCellId, for: indexPath) as! HomeMachineCell
        if let machine = themeListEnvelope?.machines[indexPath.row] {
            cell.config(machine: machine)
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 调整初始值为0
        let y = scrollView.contentOffset.y + bgIvHeight + 12
        if y > 0 { // 往上滑缩小
            let height = bgIvHeight - y
            if height >= (Constants.kStatusBarHeight + 44) {
                backgroundIv.snp.updateConstraints { make in
                    make.height.equalTo(height)
                }
                let xIncrease = (y/82) * 36
                let yIncrease = (y/82) * 46
                titleLb.snp.updateConstraints { make in
                    make.top.equalTo(titleTopInset - yIncrease)
                    make.left.equalTo(20 + xIncrease)
                }
                let fontIncrease = (y/82) * 4
                titleLb.font = UIFont.boldSystemFont(ofSize: 24 - fontIncrease)
            }else {
                backgroundIv.snp.updateConstraints { make in
                    make.height.equalTo(Constants.kStatusBarHeight + 44)
                }
                titleLb.snp.updateConstraints { make in
                    make.top.equalTo(Constants.kStatusBarHeight + 10)
                    make.left.equalTo(56)
                }
                titleLb.font = UIFont.boldSystemFont(ofSize: 20)
            }
        }else { // 往下滑放大
            let yIncrease = -y
            let xIncrease = (Constants.kScreenWidth/bgIvHeight)*yIncrease
            let bgIvWidth = Constants.kScreenWidth + xIncrease
            let bgIvHeight = bgIvHeight + yIncrease
            backgroundIv.snp.updateConstraints { make in
                make.width.equalTo(bgIvWidth)
                make.height.equalTo(bgIvHeight)
            }
            titleLb.snp.updateConstraints { make in
                make.top.equalTo(titleTopInset)
                make.left.equalTo(20)
            }
            titleLb.font = UIFont.boldSystemFont(ofSize: 24)
        }
    }
}

extension HomeThemeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let machines = themeListEnvelope?.machines, !machines.isEmpty {
            let machine = machines[indexPath.row]
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
}
