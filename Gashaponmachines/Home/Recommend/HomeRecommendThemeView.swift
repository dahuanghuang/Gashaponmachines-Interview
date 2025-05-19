import UIKit

let HomeRecommendThemeCellId = "HomeRecommendThemeCellId"

class HomeRecommendThemeView: UIView {

    var theme: HomeTheme! {
        didSet {
            if let machines = self.theme.machineList {
                self.machines = machines
                // 设置背景图片
                if let image = self.theme.backgroudImage {
                    self.themeIv.gas_setImageWithURL(image)
                }
            }
        }
    }

    var machines = [HomeMachine]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    /// 背景渐变色
    lazy var bgGradientLayer: CAGradientLayer = {
        let ly = CAGradientLayer()
        ly.colors = [UIColor(hex: "6F96FF")!.cgColor, UIColor(hex: "DCE6FF")!.cgColor]
        ly.startPoint = CGPoint(x: 0.5, y: 0)
        ly.endPoint = CGPoint(x: 0.5, y: 1)
        return ly
    }()
    
    /// 顶部标题背景
    let titleView = UIView.withBackgounrdColor(.clear)
    
    /// 标题图片
    let titleIv = UIImageView(image: UIImage(named: "home_theme_title"))
    
    /// 白色箭头
    let enterIv = UIImageView(image: UIImage(named: "home_theme_arrow"))
    
    let enterLb = UILabel.with(textColor: .white, boldFontSize: 24, defaultText: "进入专题")
    
    lazy var enterBtn: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(enterTheme), for: .touchUpInside)
        return btn
    }()
    
    /// 专题图片
    lazy var themeIv: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 6
        iv.layer.masksToBounds = true
        return iv
    }()
    
    /// 商品列表
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.itemSize = CGSize(width: 96, height: 153)
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(HomeRecommendThemeCell.self, forCellWithReuseIdentifier: HomeRecommendThemeCellId)
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .clear

        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        
        self.layer.addSublayer(bgGradientLayer)
        self.addSubview(titleView)
        titleView.addSubview(titleIv)
        titleView.addSubview(enterIv)
        titleView.addSubview(enterLb)
        titleView.addSubview(enterBtn)
        self.addSubview(themeIv)
        self.addSubview(collectionView)
    }

    @objc func enterTheme() {
        if let link = theme.topicLink {
            // 自动跳转
            RouterService.route(to: link)
        } else {
            // 手动跳转
            if let root = UIApplication.shared.keyWindow?.rootViewController as? MainViewController {
                if root.presentedViewController != nil {
                    root.dismiss(animated: true, completion: nil)
                }

                if let top = root.selectedViewController as? NavigationController,
                    let id = theme.machineTopicId {
                    top.pushViewController(HomeThemeViewController(themeId: id), animated: true)
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgGradientLayer.frame = self.bounds
        
        titleView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        titleIv.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
        }
        
        enterIv.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalToSuperview()
        }
        
        enterLb.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(enterIv.snp.left).offset(-2)
        }
        
        enterBtn.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        themeIv.snp.makeConstraints { (make) in
            make.top.equalTo(titleView.snp.bottom)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(130)
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(themeIv.snp.bottom).offset(8)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalTo(-12)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeRecommendThemeView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return machines.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeRecommendThemeCellId, for: indexPath) as! HomeRecommendThemeCell
        cell.config(machine: machines[indexPath.row])
        return cell
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
