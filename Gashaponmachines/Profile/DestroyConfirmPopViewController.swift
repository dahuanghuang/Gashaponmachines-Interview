import Foundation

/// 注销账号再次确认弹窗
class DestroyConfirmPopViewController: BaseViewController {

    var comfirmButtonClickHandle: (() -> Void)?

    lazy var confirmButton: UIButton = {
        let button = UIButton.with(title: "确定注销", titleColor: .new_middleGray, fontSize: 28)
        button.addTarget(self, action: #selector(comfirmButtonClick), for: .touchUpInside)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.new_yellow.cgColor
        return button
    }()

    lazy var quitButton: UIButton = {
        let button = UIButton.with(title: "我再想想", titleColor: .black, boldFontSize: 28)
        button.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.backgroundColor = .new_yellow
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear
        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        let contentView = RoundedCornerView(corners: .allCorners, radius: 12, backgroundColor: .white)
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.center.equalToSuperview()
            make.height.equalTo(226)
        }
        
        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "请再次确认")
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        let centerView = UIView.withBackgounrdColor(.clear)
        contentView.addSubview(centerView)
        centerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(104)
        }

        let topString = NSMutableAttributedString(string: "确认", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.new_gray])
        topString.append(NSAttributedString(string: "是否已消耗完毕账号里的资产", attributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor(hex: "FF602E")!]))
        let topContentLabel = UILabel.with(textColor: .new_gray, fontSize: 28)
        topContentLabel.attributedText = topString
        topContentLabel.textAlignment = .center
        centerView.addSubview(topContentLabel)
        topContentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(centerView.snp.centerY).offset(-2)
        }

        let bottomString = NSMutableAttributedString(string: "注销后", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.new_gray])
        bottomString.append(NSAttributedString(string: "无法恢复请谨慎操作", attributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor(hex: "FF602E")!]))
        let bottomContentLabel = UILabel.with(textColor: .new_gray, fontSize: 28)
        bottomContentLabel.attributedText = bottomString
        bottomContentLabel.textAlignment = .center
        centerView.addSubview(bottomContentLabel)
        bottomContentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(centerView.snp.centerY).offset(2)
        }

        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.bottom.equalTo(-12)
            make.height.equalTo(44)
            make.left.equalTo(12)
        }

        contentView.addSubview(quitButton)
        quitButton.snp.makeConstraints { make in
            make.bottom.size.equalTo(confirmButton)
            make.left.equalTo(confirmButton.snp.right).offset(12)
            make.right.equalTo(-12)
        }
    }

    @objc func comfirmButtonClick() {
        self.dismiss(animated: true) {
            if let handle = self.comfirmButtonClickHandle {
                handle()
            }
        }
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}
