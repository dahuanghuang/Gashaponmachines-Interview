import RxCocoa
import RxSwift

class GiftViewController: BaseViewController {

    lazy var viewModel: GiftViewModel = {
       	let vm = GiftViewModel(submitTap: self.submitButton.rx.tap.asSignal())
        return vm
    }()

    let submitButton = UIButton.whiteTextCyanGreenBackgroundButton(title: "领取")

    lazy var textField: UITextField = {
       	let tf = UITextField()
        tf.textAlignment = .center
        tf.layer.borderColor = UIColor.qu_separatorLine.cgColor
        tf.layer.borderWidth = 1
        tf.layer.masksToBounds = true
        tf.layer.cornerRadius = 4
        tf.textColor = .black
        return tf
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .qu_yellow
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let navigationBarHeight: CGFloat = self.navigationController!.navigationBar.frame.height
        let nav = UIView.withBackgounrdColor(.qu_yellow)
        view.addSubview(nav)
        nav.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            make.height.equalTo(statusBarHeight + navigationBarHeight)
            make.top.equalTo(self.view)
        }

        let backButton = UIButton.with(imageName: "nav_back_black", target: self, selector: #selector(goback))
        nav.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalTo(nav).offset(24)
            make.centerY.equalTo(nav).offset(22-(statusBarHeight / 2 + navigationBarHeight / 2 - statusBarHeight))
            make.size.equalTo(CGSize(width: 25, height: 25))
        }

        let naviTitle = UILabel.with(textColor: .qu_black, boldFontSize: 36, defaultText: "我的礼物")
        nav.addSubview(naviTitle)
        naviTitle.snp.makeConstraints { make in
            make.centerX.equalTo(nav)
            make.centerY.equalTo(nav).offset(22-(statusBarHeight / 2 + navigationBarHeight / 2 - statusBarHeight))
        }

        let round = UIView.withBackgroundColor(color: .white)
        round.layer.cornerRadius = 8
        round.layer.masksToBounds = true
        view.addSubview(round)
        round.snp.makeConstraints { make in
            make.top.equalTo(nav.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
            make.width.equalTo(654/2)
        }

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: "输入礼物口令")
        round.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
        }

        round.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(48)
        }

        round.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-20)
        }

        guard let image = UIImage(named: "gift_logo") else { return }
        let bg = UIImageView(image: image)
        view.addSubview(bg)
        bg.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(Constants.kScreenWidth * image.size.height / image.size.width)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.textField.rx.text
            .filterNil()
        	.bind(to: self.viewModel.code)
            .disposed(by: disposeBag)

        self.viewModel.result
            .subscribe(onNext: { env in
                if env.code == "0" {
                    HUD.success(second: 2, text: "领取成功", completion: nil)
                } else {
                    HUD.showResultEnvelope(env: env)
                }
            })
        	.disposed(by: disposeBag)

    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    @objc func goback() {
        self.navigationController?.popViewController(animated: true)
    }

}

class GiftViewModel: BaseViewModel {

    var code = PublishSubject<String>()

    var result = PublishSubject<ResultEnvelope>()

    init(submitTap: Signal<Void>) {

        super.init()

        let request =
            submitTap.asObservable()
            .withLatestFrom(code.asObservable())
            .flatMapLatest { code in
                AppEnvironment.current.apiService.applyPromoCode(code: code).materialize()
            }
            .share(replay: 1)

        request.elements()
        	.bind(to: self.result)
        	.disposed(by: disposeBag)

        request.errors()
            .requestErrors()
            .subscribe(onNext: { err in
                HUD.showErrorEnvelope(env: err)
            })
        	.disposed(by: disposeBag)
    }
}

enum GiftError: Int, Error {
    case wrongInput = 4700
    case duplicate = 4710
    case outdated = 4720
    case used = 4730
    case operating = 4740
}
