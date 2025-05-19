import Foundation

/// 注销账号完成弹窗
class DestroyCompletePopViewController: BaseViewController {

    var comfirmButtonClickHandle: ((String) -> Void)?
    
    let confirmTextFiled = UITextField()

    lazy var confirmButton: UIButton = {
        let button = UIButton.with(title: "注销账号", titleColor: .new_middleGray, fontSize: 28)
        button.addTarget(self, action: #selector(comfirmButtonClick), for: .touchUpInside)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.new_yellow.cgColor
        return button
    }()

    lazy var quitButton: UIButton = {
        let button = UIButton.with(title: "取消", titleColor: .black, boldFontSize: 28)
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
        
        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "请手动输入以下文字")
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
            make.height.equalTo(120)
        }

        let string = NSMutableAttributedString(string: "请输入", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.new_gray])
        string.append(NSAttributedString(string: "我确认注销确认资产已消耗完毕", attributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor(hex: "FF602E")!]))
        string.append(NSAttributedString(string: "，输入完成后注销此账号，将在审核后完成注销。", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.new_gray]))
        let topContentLabel = UILabel.with(textColor: .new_gray, fontSize: 28)
        topContentLabel.attributedText = string
        topContentLabel.textAlignment = .left
        topContentLabel.numberOfLines = 0
        centerView.addSubview(topContentLabel)
        topContentLabel.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.top.equalTo(4)
            make.centerX.equalToSuperview()
        }
        
        let cornerView = UIView.withBackgounrdColor(.clear)
        cornerView.layer.cornerRadius = 8
        cornerView.layer.borderColor = UIColor.new_lightGray.cgColor
        cornerView.layer.borderWidth = 2
        centerView.addSubview(cornerView)
        cornerView.snp.makeConstraints { make in
            make.top.equalTo(topContentLabel.snp.bottom).offset(4)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(44)
        }

        confirmTextFiled.font = UIFont.boldSystemFont(ofSize: 12)
        cornerView.addSubview(confirmTextFiled)
        confirmTextFiled.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.top.right.bottom.equalToSuperview()
        }
        
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(centerView.snp.bottom)
            make.height.equalTo(44)
            make.left.equalTo(12)
        }

        contentView.addSubview(quitButton)
        quitButton.snp.makeConstraints { make in
            make.top.size.equalTo(confirmButton)
            make.left.equalTo(confirmButton.snp.right).offset(12)
            make.right.equalTo(-12)
        }
    }

    @objc func comfirmButtonClick() {
        guard let text = self.confirmTextFiled.text else {
            HUD.showError(second: 1.5, text: "请输入提示文字", completion: nil)
            return
        }
        if text.isEmpty || text != "我确认注销确认资产已消耗完毕" {
            HUD.showError(second: 1.5, text: "请输入正确的提示文字", completion: nil)
            return
        }
        self.dismiss(animated: true) {
            if let handle = self.comfirmButtonClickHandle {
                handle(text)
            }
        }
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}
