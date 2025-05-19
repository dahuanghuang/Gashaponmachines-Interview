import UIKit

enum GuideType {
    case game
    case index
    case mall
}

private let BannerItemHeight: CGFloat = (Constants.kScreenWidth - 16) / 2

// 新手引导
class GuideViewController: BaseViewController {

    var completionBlock: (() -> Void)?

    var type: GuideType

    init(type: GuideType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear
        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        blackView.tag = 440
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissVC)))
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        if self.type == .game {

            let top = UIImageView(image: UIImage(named: "guide_game_1"))
            top.contentMode = .scaleAspectFit
            blackView.addSubview(top)
            var topOffset: CGFloat = 0
            if #available(iOS 11.0, *) {
                topOffset += self.view.safeAreaInsets.top + 24
            } else {
                topOffset = 24
            }
            top.snp.makeConstraints { make in
                make.right.equalTo(blackView)
                make.top.equalTo(blackView).offset(topOffset)
            }

            let bottom = UIImageView(image: UIImage(named: "guide_game_2"))
            bottom.contentMode = .scaleAspectFit
            blackView.addSubview(bottom)

            var bottomOffset = 64 + Constants.kScreenWidth
            if #available(iOS 11.0, *) {
                bottomOffset += self.view.safeAreaInsets.top + 24
            } else {
                bottomOffset += 24
            }
            bottom.snp.makeConstraints { make in
                make.top.equalTo(blackView).offset(bottomOffset)
                make.centerX.equalTo(blackView)
                make.left.equalTo(blackView).offset(8)
                make.right.equalTo(blackView).offset(-8)
            }
        } else if self.type == .index {
            let top = UIImageView(image: UIImage(named: "guide_index"))
            top.contentMode = .scaleAspectFit
            blackView.addSubview(top)

            let offset = BannerItemHeight + 364/2
            top.snp.makeConstraints { make in
                make.centerX.equalTo(blackView)
                make.top.equalTo(blackView).offset(offset)
                make.left.equalTo(blackView).offset(8)
                make.right.equalTo(blackView).offset(-8)
            }
        } else if self.type == .mall {
            let top = UIImageView(image: UIImage(named: "guide_mall"))
            top.contentMode = .scaleAspectFit
            blackView.addSubview(top)
            var offset: CGFloat = 175
            if #available(iOS 11.0, *) {
                offset += self.view.safeAreaInsets.top
            }
            top.snp.makeConstraints { make in
                make.centerX.equalTo(blackView)
                make.top.equalTo(blackView).offset(offset)
                make.left.equalTo(blackView).offset(8)
                make.right.equalTo(blackView).offset(-8)
            }
        }
    }

    @objc func dismissVC() {
        self.dismiss(animated: true) { [weak self] in
            if let cb = self?.completionBlock {
                cb()
            }
        }
    }
}
