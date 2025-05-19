import RxCocoa
import RxSwift
import RxSwiftExt

class MallLoginViewController: BaseViewController {

    let loginButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "邮箱登录")
    let mallTextField = UITextField()
    let passwordTextField = UITextField()
    let backButton = UIButton.with(imageName: "login_back")
    var currentResponder: UITextField?
//    lazy var scrollView: UIScrollView = {
//        let sv = UIScrollView()
//        sv.backgroundColor = .white
//        sv.delaysContentTouches = false
//        sv.showsHorizontalScrollIndicator = false
//        return sv
//    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.automaticallyAdjustsScrollViewInsets = false
//        self.view.addSubview(scrollView)
//        scrollView.snp.makeConstraints { make in
//            make.edges.equalTo(self.view)
//        }

        let closeControl = UIControl()
        closeControl.addTarget(self, action: #selector(closeKeyboard), for: .touchUpInside)
        self.view.addSubview(closeControl)
        closeControl.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        self.view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeArea.top).offset(12+20)
            make.left.equalTo(self.view).offset(12)
            make.size.equalTo(25)
        }

        let privacyView = LoginPrivacyView(viewType: .loginOrRegister)
        self.view.addSubview(privacyView)
        privacyView.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeArea.bottom).offset(-30)
            make.centerX.equalTo(self.view)
            make.height.equalTo(15)
        }

        let mallLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "邮箱地址")
        self.view.addSubview(mallLabel)
        mallLabel.snp.makeConstraints { make in
            make.left.equalTo(self.view).offset(32)
            make.width.equalTo(60)
            make.top.equalTo(backButton.snp.bottom).offset(40)
        }

        let phoneLine = UIView.seperatorLine()
        self.view.addSubview(phoneLine)
        phoneLine.snp.makeConstraints { make in
            make.top.equalTo(mallLabel.snp.bottom).offset(8)
            make.left.equalTo(mallLabel)
            make.right.equalTo(self.view).offset(-32)
            make.height.equalTo(0.5)
        }

        let passwordLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "登录密码")
        self.view.addSubview(passwordLabel)
        passwordLabel.snp.makeConstraints { make in
            make.left.equalTo(mallLabel)
            make.width.equalTo(mallLabel)
            make.top.equalTo(mallLabel.snp.bottom).offset(40)
        }

        let passwordLine = UIView.seperatorLine()
        self.view.addSubview(passwordLine)
        passwordLine.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(8)
            make.left.equalTo(passwordLabel)
            make.right.equalTo(self.view).offset(-32)
            make.height.equalTo(0.5)
        }

        self.view.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
           	make.width.equalTo(200)
            make.height.equalTo(48)
            make.centerX.equalTo(self.view)
            make.top.equalTo(passwordLine.snp.bottom).offset(40)
        }

        mallTextField.placeholder = "请输入邮箱"
        mallTextField.autocapitalizationType = .none // 关闭首字母大写
        mallTextField.keyboardType = .emailAddress
        mallTextField.font = UIFont.withPixel(28)
        mallTextField.delegate = self
        self.view.addSubview(mallTextField)
        mallTextField.snp.makeConstraints { make in
            make.centerY.equalTo(mallLabel)
            make.left.equalTo(mallLabel.snp.right).offset(10)
            make.right.equalTo(self.view).offset(-32)
            make.height.equalTo(35)
        }

        passwordTextField.font = UIFont.withPixel(28)
        passwordTextField.placeholder = "请输入密码"
        passwordTextField.delegate = self
        passwordTextField.clearsOnBeginEditing = true
        passwordTextField.isSecureTextEntry = true
        self.view.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(35)
            make.centerY.equalTo(passwordLabel)
            make.left.equalTo(passwordLabel.snp.right).offset(10)
            make.right.equalTo(self.view).offset(-32)
        }

    }

    override func bindViewModels() {
        super.bindViewModels()

        let viewModel = MallLoginViewModel(input: (
            phone: mallTextField.rx.text.orEmpty.asDriver(),
            password: passwordTextField.rx.text.orEmpty.asDriver(),
            loginTap: loginButton.rx.tap.asSignal()
        ))

        viewModel.logined
            .do(onNext: { _ in
                self.currentResponder?.endEditing(true)
            })
            .drive(onNext: { env in
            if env.code == String(GashaponmachinesError.success.rawValue) {

                HUD.success(second: 2, text: "登录成功") {
                    AppEnvironment.login(sessionToken: env.sessionToken, user: env.user)
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                HUD.showError(second: 2, text: env.msg, completion: nil)
            }
        })
        .disposed(by: disposeBag)

//        RxKeyboard.instance.willShowVisibleHeight
//            .drive(onNext: { keyboardVisibleHeight in
//                self.scrollView.contentOffset.y += keyboardVisibleHeight / 2
//            })
//            .disposed(by: disposeBag)
//
//        RxKeyboard.instance.isHidden.filter { $0 == true }
//            .drive(onNext: { _ in
//                self.scrollView.contentOffset = CGPoint.zero
//            })
//            .disposed(by: disposeBag)

        viewModel.error.subscribe(onNext: { env in
            HUD.showError(second: 2, text: env.msg, completion: nil)
        })
        .disposed(by: disposeBag)

        backButton.rx.tap.asDriver().drive(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })
        .disposed(by: disposeBag)

    }

    @objc func closeKeyboard() {
        self.currentResponder?.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.mallTextField.becomeFirstResponder()
        self.navigationController?.setNavigationBarHidden(true, animated: animated)

        #if DEBUG
        mallTextField.text = "app@quqqi.com"
        #endif
    }
}

extension MallLoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentResponder = textField
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.currentResponder?.endEditing(true)
        return true
    }
}
