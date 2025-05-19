import UIKit
import RxCocoa
import RxSwift

class EventUploadViewController: BaseViewController {

    let button = SingleButtonBottomView(title: "上传日志")

    let viewModel = EventUploadViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(button)
        button.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            make.height.equalTo(72)
            make.top.equalTo(self.view.safeArea.top)
        }

        button.rx.buttonTap.asDriver()
            .drive(self.viewModel.getUploadKeyTrigger)
            .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationItem.title = "日志上传"
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.viewModel.uploadSuccessEnvelope
            .subscribe(onNext: { _ in
                HUD.success(second: 2, text: "上传成功", completion: nil)
            })
        	.disposed(by: disposeBag)

        self.viewModel.error
            .subscribe(onNext: { env in
                HUD.showErrorEnvelope(env: env)
            })
        	.disposed(by: disposeBag)

    }
}

import RxCocoa
import RxSwift

class EventUploadViewModel: BaseViewModel {

    var getUploadKeyTrigger = PublishSubject<Void>()

    var envelope = PublishSubject<UploadEventKeyEnvelope>()

    var uploadSuccessTrigger = PublishSubject<String>()

    var uploadSuccessEnvelope = PublishSubject<ResultEnvelope>()

    override init() {
		super.init()

        let response = getUploadKeyTrigger.asObservable()
            .flatMapLatest {
                AppEnvironment.current.apiService.getClientLogReportKey().materialize()
        	}
            .share(replay: 1)

        let envelope = response.elements()

        envelope.asObservable()
            .subscribe(onNext: { [weak self] env in
                self?.uploadFile(key: env.key, token: env.token)
            })
        	.disposed(by: disposeBag)

        let uploadSuccessResp = self.uploadSuccessTrigger.asObservable()
            .flatMapLatest { key in
            	AppEnvironment.current.apiService.reportUploadClientLogSuccess(key: key).materialize()
        	}
        	.share(replay: 1)

        uploadSuccessResp.elements()
        	.bind(to: uploadSuccessEnvelope)
        	.disposed(by: disposeBag)

        Observable
            .merge(
                response.errors(),
                uploadSuccessResp.errors()
            )
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)
    }

    private func uploadFile(key: String, token: String) {
        guard let filedata = BugTrackService<SocketEmitEvent>.fileData else { return }
        HUD.shared.persist(text: "正在上传中...", timeout: 10)
        UploadService.shared.upload(data: filedata, key: key, token: token, complete: { [weak self] (info, key, resp) in
            if let returnkey = key {
                HUD.shared.dismiss()
                self?.uploadSuccessTrigger.onNext(returnkey)
            } else {
                HUD.shared.dismiss()
                HUD.showError(second: 2, text: "上传失败", completion: nil)
            }
        })
    }
}
