import UIKit

class UserShareScreenShotViewController: BaseViewController {

    lazy var renderView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "invite_bg"))
        return iv
    }()

    init(info: UserShareInfo, avatarImage: UIImage, productImage: UIImage) {
        super.init(nibName: nil, bundle: nil)

        self.view.backgroundColor = .clear

        view.addSubview(renderView)
        renderView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalTo(375)
            make.height.equalTo(667)
        }

        let image = avatarImage.ss_drawRectWithRoundedCorner(radius: 40, CGSize(width: 80, height: 80))
        let avatar = UIImageView(image: image)
//        avatar.gas_setImageWithURL(info.avatar, placeHolder: nil, targetSize: 60, roundingCorner: true)
        renderView.addSubview(avatar)
        avatar.snp.makeConstraints { make in
            make.top.equalTo(195)
            make.size.equalTo(60)
            make.centerX.equalToSuperview()
        }

        let nameLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: info.nickname)
        renderView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(avatar.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(14)
        }

        let productIv = UIImageView(image: productImage)
//        productIv.gas_setImageWithURL(info.productImage, placeHolder: nil, targetSize: 60, roundingCorner: true)
        productIv.layer.cornerRadius = 40
        productIv.layer.masksToBounds = true
        renderView.addSubview(productIv)
        productIv.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(35)
            make.left.equalTo(40)
            make.size.equalTo(80)
        }

        let attrM = NSMutableAttributedString(string: "剩余")
        attrM.append(NSAttributedString(string: info.progress, attributes: [.foregroundColor: UIColor(hex: "f96249")!, .font: UIFont.boldSystemFont(ofSize: 20)]))
        attrM.append(NSAttributedString(string: "我就免费拿到啦!\n下载填写下面邀请码帮我吧!"))
        let productDescLb = UILabel.with(textColor: .qu_black, boldFontSize: 28)
        productDescLb.numberOfLines = 0
        productDescLb.attributedText = attrM
        productDescLb.setLineSpacing(lineHeightMultiple: 1.5)
        renderView.addSubview(productDescLb)
        productDescLb.snp.makeConstraints { (make) in
            make.left.equalTo(productIv.snp.right).offset(15)
            make.right.equalToSuperview().offset(-30)
            make.centerY.equalTo(productIv)
        }

        let inviteCodeLb = UILabel.with(textColor: .qu_black, boldFontSize: 100, defaultText: info.invitationCode)
        inviteCodeLb.attributedText = NSAttributedString(string: info.invitationCode, attributes: [NSAttributedString.Key.kern: 2.0])
        inviteCodeLb.textAlignment = .center
        renderView.addSubview(inviteCodeLb)
        inviteCodeLb.snp.makeConstraints { (make) in
            make.top.equalTo(productIv.snp.bottom).offset(35)
            make.height.equalTo(75)
            make.left.equalTo(30)
            make.right.equalTo(-30)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    func circle(image: UIImage) -> UIImage {
//        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
//        let ctx = UIGraphicsGetCurrentContext()
//
//    }

}

public struct UserShareInfo {
    var avatar: String
    var invitationCode: String
    var nickname: String
    var productImage: String
    var progress: String
}
