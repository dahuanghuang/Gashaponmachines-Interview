class EnvironmentOverwriteViewController: BaseViewController {

    private var type: EnvType

    init(type: EnvType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    enum EnvType {
        case gachaAPI
        case socketAPI
    }

    let saveButton = UIButton.whiteTextCyanGreenBackgroundButton(title: "保存")

    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.textAlignment = .center
        tf.layer.borderColor = UIColor.qu_separatorLine.cgColor
        tf.layer.borderWidth = 1
        tf.layer.masksToBounds = true
        tf.layer.cornerRadius = 4
        tf.keyboardType = UIKeyboardType.URL
        return tf
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(48)
        }

        self.view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(48)
        }

        if self.type == .gachaAPI {
            self.textField.text = AppEnvironment.userDefault.string(forKey: AppEnvironment.userDefaultManzhanGachaAPIAddressKey)

            saveButton.rx.tap.asDriver()
                .drive(onNext: { _ in
                    AppEnvironment.userDefault.set(self.textField.text, forKey: AppEnvironment.userDefaultManzhanGachaAPIAddressKey)
                    AppEnvironment.userDefault.synchronize()
                    self.navigationController?.popViewController(animated: true)
                })
                .disposed(by: disposeBag)

        } else if self.type == .socketAPI {
            self.textField.text = AppEnvironment.userDefault.string(forKey: AppEnvironment.userDefaultManzhanSocketAPIAddressKey)

            saveButton.rx.tap.asDriver()
                .drive(onNext: { _ in
                    AppEnvironment.userDefault.set(self.textField.text, forKey: AppEnvironment.userDefaultManzhanSocketAPIAddressKey)
                    AppEnvironment.userDefault.synchronize()
                    self.navigationController?.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
        }
    }
}
