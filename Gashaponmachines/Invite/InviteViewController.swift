import RxDataSources
import RxSwift
import RxCocoa

private let InviteTableViewCellReuseIdentifier = "InviteTableViewCellReuseIdentifier"
private let InviteTableHeaderViewHeight: CGFloat = 460

class InviteViewController: BaseViewController {

    let inviteHandleVM = InviteHandleViewModel()

    lazy var tableview: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .qu_yellow
        tv.estimatedSectionHeaderHeight = InviteSectionView.Height
        tv.estimatedSectionFooterHeight = 180+16+16
        tv.register(InviteTableViewCell.self, forCellReuseIdentifier: InviteTableViewCellReuseIdentifier)
        return tv
    }()

    var screenshotViewController: InviteScreeshotViewController?

    let viewModel = InviteViewModel()

    var heightForHeaderInSection = InviteSectionView.Height

    let headerView = InviteHeaderView(frame: CGRect(x: 8, y: 0, width: Constants.kScreenWidth - 16, height: InviteTableHeaderViewHeight))
    let footerView = InviteFooterView()
    let sectionView = InviteSectionView()
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

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 36, defaultText: "邀请好友")
        nav.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(nav)
            make.centerY.equalTo(nav).offset(22-(statusBarHeight / 2 + navigationBarHeight / 2 - statusBarHeight))
        }

        let inviteButton = UIButton.with(title: "输入邀请码", titleColor: .qu_black, fontSize: 28)
        nav.addSubview(inviteButton)
        inviteButton.snp.makeConstraints { make in
            make.right.equalTo(nav).offset(-24)
            make.centerY.equalTo(nav).offset(22-(statusBarHeight / 2 + navigationBarHeight / 2 - statusBarHeight))
        }
        inviteButton
            .rx.tap
            .asObservable()
            .withLatestFrom(self.viewModel.info)
            .subscribe(onNext: { [weak self] info in
                if info.isReferExist {
                    self?.showInviteSuccess()
                } else {
                    self?.enterInviteCode()
                }
            })
            .disposed(by: disposeBag)

        view.addSubview(tableview)
        tableview.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self.view)
            make.top.equalTo(nav.snp.bottom)
        }

        tableview.tableHeaderView = self.headerView
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.tableview.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        self.viewModel.info
            .asDriver(onErrorDriveWith: .never())
            .map { $0.friends }
            .drive(self.tableview.rx.items(cellIdentifier: InviteTableViewCellReuseIdentifier, cellType: InviteTableViewCell.self)) { (_, item, cell) in
				cell.configureWith(friend: item)
            }
            .disposed(by: disposeBag)

        self.viewModel.info
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] info in
                self?.heightForHeaderInSection = info.friends.isEmpty ? 0 : InviteSectionView.Height
                self?.sectionView.updateInviteCount(count: info.inviteCount)
                self?.headerView.configureWithInfo(info: info)
                self?.screenshotViewController = InviteScreeshotViewController(info: info)
            })
            .disposed(by: disposeBag)

        self.viewModel.info
            .asDriver(onErrorDriveWith: .never())
            .map { $0.invitationRules }
        	.drive(self.footerView.rx.rules)
        	.disposed(by: disposeBag)

        self.headerView.inviteButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.inviteAction()
            })
        	.disposed(by: disposeBag)

        viewModel.error
            .subscribe(onNext: { env in
                HUD.showErrorEnvelope(env: env)
            })
            .disposed(by: disposeBag)

        viewModel.inputCodeResult.asObservable()
            .subscribe(onNext: { [weak self] env in
                if env.code == String(GashaponmachinesError.success.rawValue) {
                    self?.showInviteSuccess()
                } else {
                    HUD.showError(second: 2, text: env.msg, completion: nil)
                }
            })
        	.disposed(by: disposeBag)

        self.sectionView.button.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.navigationController?.pushViewController(InviteFriendListViewController(), animated: true)
            })
        	.disposed(by: disposeBag)
    }

    func showInviteSuccess() {
        let inviteSuccess = InviteSuccessViewController()
        inviteSuccess.modalTransitionStyle = .crossDissolve
        inviteSuccess.modalPresentationStyle = .overFullScreen
        inviteSuccess.inviteButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: { [weak self] in
                    self?.inviteAction()
                })
            })
            .disposed(by: inviteSuccess.disposeBag)
        self.present(inviteSuccess, animated: true, completion: nil)
    }

    func inviteAction() {

        guard let image = self.generateScreenshot() else {
            HUD.showError(second: 2, text: "无法生成图片", completion: nil)
            return
        }

        let pop = UIAlertController(title: "分享邀请码", message: nil, preferredStyle: .actionSheet)
        let moment = UIAlertAction(title: "微信朋友圈", style: .default, handler: { action in
            ShareService.shareTo(.subTypeWechatTimeline, title: nil, text: nil, shareImage: image, urlStr: "", type: .image) { [weak self] (isSuccess) in
                QLog.debug("微信朋友圈分享成功")
                self?.inviteSuccess(platform: "WechatMoments")
            }
        })

        let friend = UIAlertAction(title: "微信好友", style: .default, handler: { action in
            ShareService.shareTo(.subTypeWechatSession, title: nil, text: nil, shareImage: image, urlStr: "", type: .image) { [weak self] (isSuccess) in
                QLog.debug("微信好友分享成功")
                self?.inviteSuccess(platform: "Wechat")
            }
        })

        let sina = UIAlertAction(title: "微博", style: .default, handler: { action in
            ShareService.shareTo(.typeSinaWeibo, title: nil, text: nil, shareImage: image, urlStr: "", type: .image) { [weak self] (isSuccess) in
                QLog.debug("微博分享成功")
                self?.inviteSuccess(platform: "SinaWeibo")
            }
        })

        let copy = UIAlertAction(title: "直接复制", style: .default, handler: { [weak self] action in
            if Platform.isSimulator, let vc = self?.screenshotViewController {
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true, completion: nil)
            } else {
                let pasteboard = UIPasteboard.general
                pasteboard.string = self?.headerView.numberView.inviteCodes
                HUD.success(second: 2, text: "复制成功", completion: nil)
            }
        })

        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: { action in

        })

        if WXApiManager.isWechatInstalled {
            pop.addAction(moment)
            pop.addAction(friend)
        }

        if WeiboSDK.isWeiboAppInstalled() {
            pop.addAction(sina)
        }

        pop.addAction(copy)
        pop.addAction(cancel)

        self.present(pop, animated: true, completion: nil)
    }

    func inviteSuccess(platform: String) {
        self.inviteHandleVM.inviteTrigger.onNext((platform))
    }

    @objc func goback() {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)

        viewModel.viewWillAppearTrigger.onNext(())
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @objc func enterInviteCode() {

        let inputvc = InviteCodeInputViewController()
        inputvc.modalPresentationStyle = .overFullScreen
        inputvc.modalTransitionStyle = .crossDissolve
        inputvc.inputCodeView.completionClosure = { [weak self] codes in
            self?.viewModel.inputCode.onNext(codes)
        }
        inputvc.submitButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: { [weak self] in
                    self?.viewModel.submitButtonTap.onNext(())
                })
            })
        	.disposed(by: inputvc.disposeBag)
        self.present(inputvc, animated: true, completion: nil)
    }

    func generateScreenshot() -> UIImage? {
        guard let vc = self.screenshotViewController else { return nil }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 375, height: 667), false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        vc.renderView.layer.render(in: context)
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return renderedImage
    }
}

extension InviteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.heightForHeaderInSection
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.sectionView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.footerView
    }
}

class InviteHandleViewModel: BaseViewModel {
    var inviteTrigger = PublishSubject<String>()

    override init() {
        super.init()

        self.inviteTrigger.asObservable()
            .flatMapLatest { platform in
                AppEnvironment.current.apiService.invitationFriendSuccess(platform: platform).materialize()
            }
            .share(replay: 1)
            .subscribe()
            .disposed(by: disposeBag)
    }
}
