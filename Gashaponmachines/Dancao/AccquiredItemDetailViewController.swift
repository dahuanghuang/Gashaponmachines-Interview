import RxCocoa
import RxSwift

final class AccquiredItemDetailViewController: BaseViewController {

    init(product: EggProduct) {
        super.init(nibName: nil, bundle: nil)
        setupView(product: product)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    private func setupView(product: EggProduct) {
        
        self.view.backgroundColor = .qu_yellow
        
        let navBar = CustomNavigationBar()
        navBar.title = product.title
        navBar.backgroundColor = .clear
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }

        let sv = UIScrollView()
        sv.bounces = false
        sv.showsVerticalScrollIndicator = false
        sv.layer.cornerRadius = 4
        sv.layer.masksToBounds = true
        sv.backgroundColor = .white
        self.view.addSubview(sv)
        sv.snp.makeConstraints { make in
            make.left.equalTo(self.view).offset(8)
            make.right.equalTo(self.view).offset(-8)
            make.bottom.equalTo(self.view.safeArea.bottom)
            make.top.equalTo(navBar.snp.bottom)
        }

        var lastView: UIView = sv

        let icon = UIImageView()
        if let iconURL = product.icon {
            icon.qu_setImageWithURL(URL(string: iconURL)!)
        }
        sv.addSubview(icon)
        icon.snp.makeConstraints { make in
            if lastView is UIImageView {
                make.top.equalTo(lastView.snp.bottom).offset(16)
            } else {
                make.top.equalTo(lastView).offset(16)
            }

            make.left.equalTo(sv).offset(12)
            make.size.equalTo(15)
        }

        let titleLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: product.title)
        sv.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(icon)
            make.left.equalTo(icon.snp.right).offset(4)
            make.width.equalTo(sv.snp.width).offset(-24)
        }

        lastView = titleLabel

        if let images = product.introImages {

            for (idx, img) in images.enumerated() {

                // 图片宽高比例为5/3
                let ivWidth: CGFloat = Constants.kScreenWidth - 40
                let ivHeight = ivWidth / (5/3)
                let iv = UIImageView()
                iv.qu_setImageWithURL(URL(string: img)!)
                sv.addSubview(iv)
                iv.snp.makeConstraints { make in
                    make.top.equalTo(lastView.snp.bottom).offset(lastView is UILabel ? 12 : 0)
                    make.centerX.equalTo(sv)
                    make.width.equalTo(ivWidth)
                    make.height.equalTo(ivHeight)
                    if idx == images.count - 1 {
                        make.bottom.equalTo(sv).offset(-16)
                    }
                }

                lastView = iv
            }

        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
