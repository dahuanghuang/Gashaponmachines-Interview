import RxCocoa
import RxSwift
import RxKeyboard

private let Width: CGFloat = 280

private let Height: CGFloat = 760 / 2

class PhoneViewController: BaseViewController {

    static let askForRequestUserDefaultKey = "com.gashaponmachines.bindphone"

    var completionBlock: ((String) -> Void)?

    let viewModel = PhoneViewModel()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var timer: Timer?

    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.layer.cornerRadius = 4
        v.layer.masksToBounds = true
        v.backgroundColor = .white
        v.isScrollEnabled = false
        return v
    }()

    private var totalTimeInSeconds = 60 {
        didSet {
            if totalTimeInSeconds <= 0 {
                self.timer?.invalidate()
                inputCodeView.timerButton.isUserInteractionEnabled = true
                inputCodeView.timerButton.setTitle("重新获取>>", for: .normal)
                inputCodeView.timerButton.setTitleColor(.qu_black, for: .normal)
            } else {
                inputCodeView.timerButton.isUserInteractionEnabled = false
                inputCodeView.timerButton.setTitle("\(totalTimeInSeconds)(s)重新获取", for: .normal)
                inputCodeView.timerButton.setTitleColor(.qu_lightGray, for: .normal)
            }
        }
    }

    @objc func ticktak() {
        totalTimeInSeconds -= 1
    }

    lazy var closeButton = UIButton.with(imageName: "phone_close")

    lazy var bindingView = PhoneBindingView()

    lazy var inputCodeView: PhoneInputCodeView = {
        let v = PhoneInputCodeView()
        v.inputCodeTextField.completionClosure = { [weak self] code in
            guard let self = self else { return }
            self.viewModel.bindPhoneTrigger.onNext((self.bindingView.inputCodeView.text!, code))
        }
        return v
    }()

    @objc func didBecomeActive() {
        let timerHasGone = Date().timeIntervalSince(_enterBackgroundDate)
        totalTimeInSeconds -= Int(timerHasGone)
    }

    @objc func willEnterBackground() {
        _enterBackgroundDate = Date()
    }

    private var _enterBackgroundDate: Date = Date()

    private var _currentPhone: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        AppEnvironment.userDefault.set(Date(), forKey: PhoneViewController.askForRequestUserDefaultKey)
        AppEnvironment.userDefault.synchronize()

        NotificationCenter.default.addObserver(self, selector: #selector(willEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)

        self.view.backgroundColor = UIColor.black.alpha(0.6)

        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.width.equalTo(Width)
            make.height.equalTo(Height)
            make.center.equalToSuperview()
        }

        scrollView.contentSize = CGSize(width: Width * 2, height: Height)

        scrollView.addSubview(bindingView)
        scrollView.addSubview(inputCodeView)

        bindingView.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.width.equalTo(Width)
            make.height.equalTo(Height)
        }

        inputCodeView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(Width)
            make.width.equalTo(Width)
            make.height.equalTo(Height)
        }

        self.view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(28)
            make.right.equalTo(scrollView).offset(-8)
            make.top.equalTo(scrollView).offset(8)
        }
    }

    override func bindViewModels() {
        super.bindViewModels()

        scrollView.rx.contentOffset.asObservable()
            .map { $0.x }
            .subscribe(onNext: { [weak self] offsetX in
                if offsetX == 0 {
                    self?.bindingView.inputCodeView.becomeFirstResponder()
                } else {
                    self?.inputCodeView.inputCodeTextField.becomeFirstResponder()
                }
            })
            .disposed(by: disposeBag)

        bindingView.inputCodeView.rx.text
            .filterNil()
            .bind(to: inputCodeView.rx.phone)
            .disposed(by: disposeBag)

        closeButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.timer?.invalidate()
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        inputCodeView.backButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.scrollView.setContentOffset(.zero, animated: true)
            })
            .disposed(by: disposeBag)

        bindingView.inputCodeView.rx.text
            .asObservable()
            .filterNil()
            .map { $0.isValidPhoneNumber() }
            .startWith(false)
            .bind(to: bindingView.bindButton.rx.isEnabled)
            .disposed(by: disposeBag)

        bindingView.bindButton.rx.tap
            .asDriver()
            .withLatestFrom(self.bindingView.inputCodeView.rx.text.asDriver().filterNil())
            .drive(onNext: { [weak self] phone in
                self?.viewModel.sendCodeTrigger.onNext(phone)
            })
            .disposed(by: disposeBag)

        inputCodeView.timerButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self, let phone = self.bindingView.inputCodeView.text else { return }
                self.viewModel.sendCodeTrigger.onNext(phone)
                self.inputCodeView.inputCodeTextField.clear()
                self.totalTimeInSeconds = 60
                self.startTimer()
            })
            .disposed(by: disposeBag)

        RxKeyboard.instance.willShowVisibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                self?.view.frame.origin.y -= 68
            })
            .disposed(by: disposeBag)

        RxKeyboard.instance.isHidden
            .filter { $0 == true }
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.view.center = UIApplication.shared.keyWindow!.center
            })
            .disposed(by: disposeBag)

        // 已经发送成功
        viewModel.sendCodeEnvelope
            .success()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.scrollView.setContentOffset(CGPoint(x: Width, y: 0), animated: true)
                self.inputCodeView.inputCodeTextField.clear()
                self.totalTimeInSeconds = 60
                self.startTimer()
            })
            .disposed(by: disposeBag)

        viewModel.bindPhoneEnvelope
            .subscribe(onNext: { [weak self] env in
                if env.code == "0" {
                    if let phone = self?.bindingView.inputCodeView.text, let block = self?.completionBlock {
                        block(phone)
                    }
                    HUD.success(second: 2, text: "绑定成功", completion: {
                        self?.dismiss(animated: true, completion: {
                            self?.navigationController?.popToRootViewController(animated: true)
                        })
                    })
                }
            })
            .disposed(by: disposeBag)

        viewModel.error
            .subscribe(onNext: { env in
                HUD.showErrorEnvelope(env: env)
            })
            .disposed(by: disposeBag)

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endKeyboardEditing)))
    }

    func startTimer() {
        if let timer = self.timer {
            timer.invalidate()
        }
        self.timer = Timer(timeInterval: 1.0, target: self, selector: #selector(ticktak), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .default)
    }

    @objc func endKeyboardEditing() {
        self.view.endEditing(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

}
