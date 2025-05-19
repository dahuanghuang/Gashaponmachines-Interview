import RxSwift
import RxGesture

class PhoneRebindView: DimBackgroundView {

    lazy var iv = UIImageView.with(imageName: "phone_binded")

    lazy var titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)

    lazy var bindButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "重新绑定", fontSize: 28)

    override init(frame: CGRect) {
        super.init(frame: frame)

        let contentView = RoundedCornerView(corners: .allCorners, radius: 4)
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.center.equalToSuperview()
        }

        contentView.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(50)
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iv.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        contentView.addSubview(bindButton)
        bindButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(36)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(48)
        }
    }

    convenience init(phone: String) {
        self.init(frame: .zero)

        titleLabel.text = "已绑定手机号码：\(phone)"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
