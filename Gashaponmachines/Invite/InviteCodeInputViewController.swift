import RxSwift
import RxCocoa

class InviteCodeInputViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupEnterCodeView()
        self.inputCodeView.becomeFirstResponder()
    }

    let submitButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "提交")
    let inputCodeView = InviteCodeTextField()

    fileprivate func setupEnterCodeView() {
        self.view.backgroundColor = .clear
        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        blackView.tag = 440
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        let contentView = UIView()
        contentView.isUserInteractionEnabled = true
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        contentView.tag = 441
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.center.equalTo(blackView)
            make.height.equalTo(192)
        }

        let container = UIView()
        contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.center.equalTo(contentView)
        }

        let quitButton = UIButton.with(imageName: "input_close")
        quitButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        contentView.addSubview(quitButton)
        quitButton.snp.makeConstraints { make in
            make.size.equalTo(25)
            make.right.equalTo(contentView).offset(-4)
            make.top.equalTo(contentView).offset(4)
        }

        let titleLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "请输入邀请码")
        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(container)
            make.top.equalTo(container).offset(24)
        }

        container.addSubview(inputCodeView)
        inputCodeView.snp.makeConstraints { make in
            make.centerX.equalTo(container)
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.height.equalTo(45)
            make.width.equalTo(240)
        }

        let tipView = UILabel.with(textColor: UIColor.UIColorFromRGB(0xff0000), fontSize: 28)
        container.addSubview(tipView)
        tipView.snp.makeConstraints { make in
            make.top.equalTo(inputCodeView.snp.bottom).offset(4)
            make.centerX.equalTo(container)
        }

//        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        contentView.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(tipView.snp.bottom).offset(8)
            make.width.equalTo(160)
            make.height.equalTo(48)
            make.centerX.equalTo(container)
            make.bottom.equalTo(container).offset(-16)
        }
    }

    override func bindViewModels() {
        super.bindViewModels()
    }

    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}
