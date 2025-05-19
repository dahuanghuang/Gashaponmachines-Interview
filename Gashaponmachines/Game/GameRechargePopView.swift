// 补充元气弹窗
import UIKit
import RxSwift

class GameRechargePopView: UIView {

    let disposeBag = DisposeBag()

    lazy var contentView = UIView.withBackgounrdColor(.white)

    /// 补充元气
    lazy var addButton: UIButton = {
        let btn = UIButton.with(title: "+ 补充元气", titleColor: .white, fontSize: 28)
        btn.layer.cornerRadius = 8
        btn.backgroundColor = .qu_cyanGreen
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .clear
        
        let blackView = UIView()
        blackView.layer.cornerRadius = 8
        blackView.backgroundColor = .qu_popBackgroundColor
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        self.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(279)
            make.height.equalTo(332)
            make.center.equalTo(blackView)
        }

        let titleLabel = UILabel.with(textColor: .black, boldFontSize: 32, defaultText: "元气不足")
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(50)
        }

        let icon = UIImageView(image: UIImage(named: "game_no_balance"))
        contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(152)
        }

        let subTitleLabel = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: "需要补充元气才能扭蛋哦")
        subTitleLabel.textAlignment = .center
        contentView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom)
            make.centerX.equalTo(contentView)
            make.height.equalTo(40)
        }

        addButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        contentView.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(12)
            make.height.equalTo(44)
            make.left.equalTo(contentView).offset(12)
            make.right.equalTo(contentView).offset(-12)
        }

        let desLabel = UILabel.with(textColor: .new_middleGray, fontSize: 20, defaultText: "邀请好友也可以获得元气")
    	contentView.addSubview(desLabel)
        desLabel.snp.makeConstraints { make in
            make.top.equalTo(addButton.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
    }

    @objc func dismiss() {
        self.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
