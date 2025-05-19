import UIKit

/// 修改头像提醒弹窗
class EditAvatarPopViewController: BaseViewController {

    var confirmButtonClickHandle: (() -> Void)?
    
    let tipLabel = UILabel.with(textColor: .black, fontSize: 28, defaultText: "头像只能修改一次哦~")
    
    lazy var confirmButton: UIButton = {
        let button = UIButton.with(title: "确定", titleColor: .black, boldFontSize: 28)
        button.addTarget(self, action: #selector(comfirmButtonClick), for: .touchUpInside)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.backgroundColor = .new_yellow
        return button
    }()
    lazy var quitButton: UIButton = {
        let button = UIButton.with(title: "我再想想", titleColor: .new_middleGray, fontSize: 28)
        button.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.new_yellow.cgColor
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
            make.height.equalTo(154)
            make.width.equalTo(279)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        tipLabel.numberOfLines = 0
        tipLabel.textAlignment = .center
        contentView.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(98)
        }

        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(tipLabel.snp.bottom)
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
        
        self.dismiss(animated: true) {
            if let handle = self.confirmButtonClickHandle {
                handle()
            }
        }
    }

    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}
