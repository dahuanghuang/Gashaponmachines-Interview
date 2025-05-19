//
import UIKit

/// 故障提示框
class YSFLiveErrorView: UIView {

    func show() {
        if let window = UIApplication.shared.keyWindow,
            !window.subviews.contains(self) {
            window.addSubview(self)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: Constants.kScreenHeight))

        setupUI()
    }

    func setupUI() {
        self.backgroundColor = UIColor.black.alpha(0.6)

        // 白色视图
        let contentView = UIView.withBackgounrdColor(.white)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.height.equalTo(280)
            make.center.equalToSuperview()
        }

        // 图标
        let iconImageView = UIImageView(image: UIImage(named: "yfs_live_error"))
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(50)
        }

        // 描述
        let desLabel = UILabel()
        desLabel.text = "扭蛋机可能发生了一些问题"
        desLabel.textColor = .qu_black
        desLabel.font = UIFont.boldSystemFont(ofSize: 14)
        contentView.addSubview(desLabel)
        desLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        // 提示
        let tipLabel = UILabel()
        tipLabel.text = "元气小哥将会在一个工作日内维修好扭蛋机，维修成功后将会写入实际的结果以及继续运行剩下的扭蛋"
        tipLabel.textAlignment = .center
        tipLabel.numberOfLines = 0
        tipLabel.textColor = .qu_black
        tipLabel.font = UIFont.boldSystemFont(ofSize: 12)
        contentView.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(desLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.left.equalTo(18)
            make.right.equalTo(-18)
        }

        // 确认
        let confirmButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "好的", fontSize: 28)
        confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(tipLabel.snp.bottom).offset(36)
            make.centerX.equalToSuperview()
            make.width.equalTo(157.5)
            make.height.equalTo(48)
        }
    }
    @objc func confirm() {
        self.removeFromSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
