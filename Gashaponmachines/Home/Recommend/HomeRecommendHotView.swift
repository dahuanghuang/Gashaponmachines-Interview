import UIKit
import RxSwift
import RxCocoa

class HomeRecommendHotView: UIView {
    let disposeBag = DisposeBag()

    var theme: HomeTheme! {
        didSet {
            
            if let t = theme.title {
                self.titleLabel.text = t
            }
            
            if let machines = self.theme.machineList {
                if machines.count > 6 {
                    self.machines = Array(machines.prefix(6))
                } else {
                    self.machines = machines
                }
                
                self.collectionView.reloadData()
            }
        }
    }

    var machines = [HomeMachine]()

    /// 顶部标题背景
    let titleView = UIView.withBackgounrdColor(.clear)

    /// 标题
    lazy var titleLabel: UILabel = {
        let lb = UILabel.with(textColor: .black, boldFontSize: 32)
        lb.textAlignment = .left
        return lb
    }()
    
    let logoIv = UIImageView(image: UIImage(named: "home_hot_logo"))
    
    /// 商品列表
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.bounces = false
        cv.delegate = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.register(HomeRecommendHotCell.self, forCellWithReuseIdentifier: HomeRecommendHotCellId)
        return cv
    }()

    /// 换一换
    lazy var changeView: UIView = {
        let view = UIView.withBackgounrdColor(UIColor(hex: "EFEFEF")!)
        view.layer.cornerRadius = 20
        return view
    }()
    
    lazy var changeLabel: UILabel = {
        let lb = UILabel.with(textColor: .qu_black, boldFontSize: 26, defaultText: "换一换")
        lb.textAlignment = .left
        return lb
    }()
    
    let changeIv = UIImageView(image: UIImage(named: "home_change"))
    
    lazy var changeButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(changeButtonClick), for: .touchUpInside)
        return btn
    }()

    let viewModel = HomeRecommendViewModel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        
        /// 标题
        self.addSubview(titleView)
        titleView.addSubview(titleLabel)
        titleView.addSubview(logoIv)
        
        /// 商品
        self.addSubview(collectionView)
        
        /// 换一换
        self.addSubview(changeView)
        changeView.addSubview(changeLabel)
        changeView.addSubview(changeIv)
        changeView.addSubview(changeButton)
        
        bindViewModels()
    }

    func bindViewModels() {
        self.viewModel.hotThemeEnvelope.subscribe(onNext: { [weak self] theme in
            self?.theme = theme
        }).disposed(by: disposeBag)
    }

    @objc func changeButtonClick() {
        self.viewModel.requestNextTheme.onNext((self.theme))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
        }
        
        logoIv.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.right.equalTo(-12)
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(titleView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(HomeRecommendHotCell.cellH * 2 + 8)
        }
        
        changeView.snp.makeConstraints { (make) in
            make.top.equalTo(collectionView.snp.bottom).offset(12)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(40)
        }
        
        changeLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(6)
            make.centerY.equalToSuperview()
        }

        changeIv.snp.makeConstraints { (make) in
            make.right.equalTo(changeLabel.snp.left).offset(-4)
            make.centerY.equalTo(changeLabel)
            make.size.equalTo(12)
        }
        
        changeButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeRecommendHotView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.machines.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeRecommendHotCellId, for: indexPath) as! HomeRecommendHotCell
        cell.config(machine: self.machines[indexPath.row])
        return cell
    }
}

extension HomeRecommendHotView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: HomeRecommendHotCell.cellW, height: HomeRecommendHotCell.cellH)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let machine = machines[indexPath.row]
        if let type = MachineColorType(rawValue: machine.type.rawValue) {
            if let root = UIApplication.shared.keyWindow?.rootViewController as? MainViewController {

                guard AppEnvironment.current.apiService.accessToken != nil else {
                    let vc = LoginViewController.controller
                    vc.modalPresentationStyle = .fullScreen
                    root.present(vc, animated: true, completion: nil)
                    return
                }

                let vc = NavigationController(rootViewController: GameNewViewController(physicId: machine.physicId, type: type))
                vc.modalPresentationStyle = .fullScreen
                root.present(vc, animated: true, completion: nil)
            }
        } else {
            HUD.showError(second: 1.0, text: "机台类型出错", completion: nil)
        }
    }
}
