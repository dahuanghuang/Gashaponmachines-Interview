import RxCocoa
import RxSwift

final class CompositionDetailIntroImagesViewController: BaseViewController {

    init(introImages: [String]) {
        self.images = introImages
        super.init(nibName: nil, bundle: nil)
    }

    var images: [String]

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "商品详情"

//        self.view.backgroundColor = UIColor.qu_cyanBlue
        self.view.backgroundColor = UIColor(hex: "ffe6ac")

        let sv = UIScrollView()
        sv.bounces = false
        sv.showsVerticalScrollIndicator = false
        sv.layer.cornerRadius = 4
        sv.layer.masksToBounds = true
        sv.backgroundColor = .white
        self.view.addSubview(sv)
        sv.snp.makeConstraints { make in
            make.left.equalTo(self.view).offset(12)
            make.right.equalTo(self.view).offset(-12)
            make.bottom.equalTo(self.view.safeArea.bottom).offset(-12)
            make.top.equalTo(self.view).offset(12)
        }

        var lastview: UIView = sv
        for (idx, img) in images.enumerated() {

            let iv = UIImageView()
            iv.gas_setImageWithURL(img)
            sv.addSubview(iv)
            iv.snp.makeConstraints { make in
                if type(of: lastview) == UIScrollView.self {
                    make.top.equalTo(lastview).offset(12)
                } else {
                    make.top.equalTo(lastview.snp.bottom)
                }

                make.centerX.equalTo(sv)
                make.width.equalTo(sv.snp.width).offset(-24)
                make.height.equalTo((Constants.kScreenWidth - 24) * 0.6)
                if idx == images.count - 1 {
                    make.bottom.equalTo(sv).offset(-16)
                }
            }

            lastview = iv
        }
    }
}
