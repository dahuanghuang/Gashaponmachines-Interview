import UIKit
import Kingfisher

class OccupyRechargeErrorViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    fileprivate func setupView() {
        self.view.backgroundColor = .clear

        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(280)
        }

        let iconIv = UIImageView(image: UIImage(named: "occupy_confirm_quit"))
        contentView.addSubview(iconIv)
        iconIv.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(20)
            make.size.equalTo(50)
        }

        let titleLb = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: "未查询到充值结果")
        contentView.addSubview(titleLb)
        titleLb.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconIv.snp.bottom).offset(20)
        }

        let descLb = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "请重新完成一次充值保证霸机成功, 多次付款都会全部到账! 请放心充值")
        descLb.numberOfLines = 0
        descLb.setLineSpacing(lineHeightMultiple: 1.5)
        contentView.addSubview(descLb)
        descLb.snp.makeConstraints { (make) in
            make.top.equalTo(titleLb.snp.bottom)
            make.centerX.equalToSuperview()
            make.left.equalTo(32)
            make.right.equalTo(-32)
        }

        let tipLb = UILabel.with(textColor: .qu_lightGray, fontSize: 24, defaultText: "若多次完成，可结束后联系客服撤销")
        tipLb.numberOfLines = 0
        tipLb.setLineSpacing(lineHeightMultiple: 1.2)
        contentView.addSubview(tipLb)
        tipLb.snp.makeConstraints { (make) in
            make.top.equalTo(descLb.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.left.equalTo(32)
            make.right.equalTo(-32)
        }

        let confirmBtn = UIButton.with(title: "好的", titleColor: .qu_black, fontSize: 28)
        confirmBtn.addTarget(self, action: #selector(confirmClick), for: .touchUpInside)
        confirmBtn.setBackgroundColor(color: .qu_yellow, forUIControlState: .normal)
        confirmBtn.layer.cornerRadius = 4
        confirmBtn.layer.masksToBounds = true
        contentView.addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { (make) in
            make.top.equalTo(tipLb.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
            make.width.equalTo(158)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    @objc func confirmClick() {
        self.dismiss(animated: true, completion: nil)
    }

}
