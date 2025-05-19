// 奖赏详情 - 详情页
import RxCocoa
import RxSwift

final class GameProductDetailViewController: BaseViewController {

    init(product: Product) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }

    var product: Product

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .new_backgroundColor
        
        let nav = CustomNavigationBar()
        nav.title = product.title
        nav.backgroundColor = .new_backgroundColor
        view.addSubview(nav)
        nav.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + 44)
        }

        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.layer.cornerRadius = 4
        sv.layer.masksToBounds = true
        sv.backgroundColor = .clear
        self.view.addSubview(sv)
        sv.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(nav.snp.bottom)
        }

        DanmakuService.shared.delegate = self

        var lastView: UIView!
        
        // 占位视图, 没有任何作用, 用来承载lastView属性
        let placeHoderView = UIView.withBackgounrdColor(.clear)
        sv.addSubview(placeHoderView)
        placeHoderView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0)
        }
        lastView = placeHoderView
        
        guard let intros = product.intros else { return }

        for (index, intro) in intros.enumerated() {

            if let title = intro.title {
                let container = UIView.withBackgounrdColor(.white)
                sv.addSubview(container)
                container.snp.makeConstraints { make in
                    make.top.equalTo(lastView.snp.bottom)
                    make.left.right.equalToSuperview()
                    make.height.equalTo(44)
                }
                lastView = container
                
                let icon = UIImageView()
                if let iconURL = product.icon {
                    icon.qu_setImageWithURL(URL(string: iconURL)!)
                }
                container.addSubview(icon)
                icon.snp.makeConstraints { make in
                    make.left.equalTo(12)
                    make.centerY.equalToSuperview()
                    make.size.equalTo(24)
                }
                
                let titleLabel = UILabel.with(textColor: .black, boldFontSize: 24, defaultText: title)
                container.addSubview(titleLabel)
                titleLabel.snp.makeConstraints { make in
                    make.left.equalTo(icon.snp.right).offset(6)
                    make.centerY.equalToSuperview()
                }
            }
            
            if let images = intro.introImages {

                for (idx, img) in images.enumerated() {

                    let iv = UIImageView()
                    iv.qu_setImageWithURL(URL(string: img)!)
                    sv.addSubview(iv)
                    iv.snp.makeConstraints { make in
                        make.top.equalTo(lastView.snp.bottom).offset(lastView is UILabel ? 12 : 0)
                        make.centerX.equalTo(sv)
                        make.width.equalTo(sv.snp.width).offset(-24)
                        make.height.equalTo((Constants.kScreenWidth - 24) * 0.6)
                        if index == intros.count - 1 && idx == images.count - 1 {
                            make.bottom.equalTo(sv).offset(-16)
                        }
                    }

                    lastView = iv
                }
            }
            
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
