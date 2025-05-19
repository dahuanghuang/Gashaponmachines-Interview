import UIKit
import Photos

//  用户分享弹窗
class UserSharePopViewController: UIViewController {
    lazy var shares: [Share] = {
        return [Share(image: "invite_share_friend", title: "微信好友", type: .WechatFriend),
                Share(image: "invite_share_pyq", title: "微信朋友圈", type: .WechatPyq),
                Share(image: "invite_share_image", title: "生成海报", type: .Image),
                Share(image: "invite_share_code", title: "复制邀请码", type: .InviteCode)
        ]
    }()

    private let blackView = UIView.withBackgounrdColor(.qu_popBackgroundColor)

    private lazy var cancelButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(dismissVc), for: .touchUpInside)
        btn.backgroundColor = .white
        btn.setTitle("取消", for: .normal)
        btn.setTitleColor(.qu_black, for: .normal)
        return btn
    }()

    let inviteHandleVM = InviteHandleViewModel()

    var image: UIImage!

    var inviteCode: String!

    init(image: UIImage, inviteCode: String) {
        super.init(nibName: nil, bundle: nil)

        self.image = image
        self.inviteCode = inviteCode
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        blackView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(Constants.kScreenBottomInset + 45)
        }

        let lineView = UIView.withBackgounrdColor(.viewBackgroundColor)
        blackView.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(cancelButton.snp.top)
            make.height.equalTo(10)
        }

        let shareBgView = UIView.withBackgounrdColor(.clear)
        blackView.addSubview(shareBgView)
        shareBgView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(lineView.snp.top)
            make.height.equalTo(152)
        }

        let shareContentView = UIView.withBackgounrdColor(.white)
        shareBgView.addSubview(shareContentView)
        shareContentView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(97)
        }

        var lastView: UIView?
        for i in 0..<shares.count {
            let shareView = ShareView(share: shares[i])
            shareContentView.addSubview(shareView)
            shareView.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview()
                make.width.equalTo((Constants.kScreenWidth - 30) / 4)
                if let view = lastView {
                    make.left.equalTo(view.snp.right)
                } else {
                    make.left.equalTo(15)
                }
                lastView = shareView
            }

            let shareButton = UIButton()
            shareButton.tag = i
            shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
            shareView.addSubview(shareButton)
            shareButton.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }

        let shareTitleView = UIView.withBackgounrdColor(.white)
        shareBgView.addSubview(shareTitleView)
        shareTitleView.roundCorners([.topLeft, .topRight], radius: 15, bounds: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: 55))
        shareTitleView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(shareContentView.snp.top)
        }

        let shareTitleLb = UILabel.with(textColor: UIColor(hex: "8a8a8a")!, fontSize: 28, defaultText: "分享两个群以上更容易成功哦~")
        shareTitleView.addSubview(shareTitleLb)
        shareTitleLb.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }

    @objc func share(button: UIButton) {
        let shareType = ShareType(rawValue: button.tag)!

        switch shareType {
        case .WechatFriend:
            ShareService.shareTo(.subTypeWechatSession, title: nil, text: nil, shareImage: image, urlStr: "", type: .image) { [weak self] (isSuccess) in
                QLog.debug("微信好友分享成功")
                self?.inviteSuccess(platform: "Wechat")
            }
        case .WechatPyq:
            ShareService.shareTo(.subTypeWechatTimeline, title: nil, text: nil, shareImage: image, urlStr: "", type: .image) { [weak self] (isSuccess) in
                QLog.debug("微信朋友圈分享成功")
                self?.inviteSuccess(platform: "WechatMoments")
            }
        case .Image:
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: self.image)
                    }) { (isSuccess, error) in
                        DispatchQueue.main.sync {
                            if isSuccess {
                                HUD.success(second: 1.0, text: "保存成功", completion: nil)
                                self.dismissVc()
                            } else {
                                HUD.showError(second: 2.0, text: "保存失败", completion: nil)
                            }
                        }
                    }
                }
            }
        case .InviteCode:
            UIPasteboard.general.string = self.inviteCode
            HUD.success(second: 1.0, text: "复制成功", completion: nil)
            self.dismissVc()
        }
    }

    func inviteSuccess(platform: String) {
        self.inviteHandleVM.inviteTrigger.onNext((platform))
        self.dismissVc()
    }

    @objc func dismissVc() {
        self.dismiss(animated: true, completion: nil)
    }
}

struct Share {
    var image: String
    var title: String
    var type: ShareType
}

enum ShareType: Int {
    case WechatFriend // 微信好友
    case WechatPyq // 微信朋友圈
    case Image // 海报
    case InviteCode // 邀请码
}

class ShareView: UIView {

    init(share: Share) {
        super.init(frame: .zero)

        self.backgroundColor = .white

        let shareIv = UIImageView(image: UIImage(named: share.image))
        addSubview(shareIv)
        shareIv.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
            make.size.equalTo(55)
        }

        let shareTittle = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: share.title)
        addSubview(shareTittle)
        shareTittle.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(shareIv.snp.bottom).offset(10)
            make.height.equalTo(12)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
