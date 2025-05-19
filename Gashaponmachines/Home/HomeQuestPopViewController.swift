import UIKit

//  首页活动弹窗
class HomeQuestPopViewController: UIViewController {
    // 新手弹窗关闭弹窗回调
    var questPopMenuClose: (() -> Void)?
    var questInfo: PopMenuQuestInfo!
    var mainImg: UIImage?

    init(questInfo: PopMenuQuestInfo, mainImg: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        self.questInfo = questInfo
        self.mainImg = mainImg
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        view.backgroundColor = .clear

        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let mainIv = UIImageView(image: mainImg)
        blackView.addSubview(mainIv)
        mainIv.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(320)
            make.height.equalTo(415)
        }

        let buttonIv = UIImageView()
        if let buttonImage = questInfo.buttonImage {
            buttonIv.gas_setImageWithURL(buttonImage)
        }
        blackView.addSubview(buttonIv)
        buttonIv.snp.makeConstraints { (make) in
            make.top.equalTo(mainIv.snp.bottom).offset(15)
            make.centerX.equalTo(mainIv)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }

        let button = UIButton()
        button.addTarget(self, action: #selector(jumpToVc), for: .touchUpInside)
        blackView.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(mainIv)
            make.bottom.equalTo(buttonIv)
        }
    }

    @objc func jumpToVc() {

        if let action = questInfo.buttonAction {
            RouterService.route(to: action)
        }

        self.dismiss(animated: true) {
            if let handle = self.questPopMenuClose {
                handle()
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
