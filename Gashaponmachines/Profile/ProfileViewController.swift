import UIKit
import RxSwift
import RxCocoa
import SnapKit
import ESTabBarController_swift
import Kingfisher
import AVKit

private let BindPhoneNoticeKey = "BindPhoneNoticeKey"
private let MemberShipNoticeKey = "MemberShipNoticeKey"

private let ProfileCollectionViewCellId = "ProfileCollectionViewCellId"

class ProfileViewController: BaseViewController {

    /// 用户信息
    var userInfo: UserInfo?

    /// 头部广告栏
    var banner: UserBanner?

    /// 第三行按钮数据
    var services = [UserService]()

    /// 第一行和第二行数据
    var profileArrays: [[Profile]] = CONST_PROFILES

    let viewModel = ProfileViewModel()

    /// 头部视图
    var headerView: ProfileHeaderView!

    /// 是否绑定了头部视图
    var isBind: Bool = false

    let layout = UICollectionViewFlowLayout()

    lazy var collectionView: UICollectionView = {
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 12, right: 12)
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = CGSize(width: Constants.kScreenWidth, height: ProfileHeaderView.headerViewH)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.contentInset = UIEdgeInsets(top: -Constants.kStatusBarHeight, left: 0, bottom: 0, right: 0)
        cv.backgroundColor = .viewBackgroundColor
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false

        cv.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: ProfileCollectionViewCellId)
        cv.register(ProfileHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeadViewId)
        cv.register(ProfileSectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileSectionViewId)
        return cv
    }()

    /// 导航栏
    var navigationBar = ProfileNavigationBar()

    // MARK: - 系统函数
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }

        if let root = UIApplication.shared.keyWindow?.rootViewController as? MainViewController {
            root.updateUnreadNotificationCount(9)
        }

        bindNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DanmakuService.shared.alertDelegate = self
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.viewWillAppearTrigger.onNext(())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DanmakuService.shared.showAlert(type: .Mine)
    }

    /// 会员
    private func showMembershipPop() {
        let value = UserDefaults.standard.bool(forKey: MemberShipNoticeKey)
        if !value {
            UserDefaults.standard.set(true, forKey: MemberShipNoticeKey)
            UserDefaults.standard.synchronize()

            let vc = MembershipPopViewController()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }

    func messageBtnClick() {
        navigationController?.pushViewController(NotificationViewController(), animated: true)
    }

    func settingBtnClick() {
        if let info = userInfo {
            navigationController?.pushViewController(SettingsViewController(hasBindPhone: info.hasBoundPhone ?? false, bindPhoneTip: info.bindPhoneTip, phone: info.phone), animated: true)
        }
    }

    func bindNavigationBar() {
        navigationBar.rx.settingButtonTap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.settingBtnClick()
            })
            .disposed(by: disposeBag)

        navigationBar.rx.messageButtonTap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.messageBtnClick()
            })
            .disposed(by: disposeBag)
    }

    func bindHeaderView() {

        if !isBind {
            isBind = true

            headerView.rx.exchangeButtonTap
                .asDriver()
                .drive(onNext: { _ in
                    if let root = UIApplication.shared.keyWindow?.rootViewController as? ESTabBarController {
                        root.selectedIndex = AppEnvironment.isYfs ? 2 : 1
                    }
                })
                .disposed(by: disposeBag)

            headerView.rx.rechargeButtonTap
                .asDriver()
                .drive(onNext: { [weak self] in
                    self?.navigationController?.pushViewController(RechargeViewController(isOpenFromGameView: false), animated: true)
                })
                .disposed(by: disposeBag)

            headerView.rx.upgradeTap
                .asDriver()
                .drive(onNext: { [weak self] in
                    if let isNDVip = self?.userInfo?.isNDVip, isNDVip == "0" {
                        self?.navigationController?.pushViewController(MembershipViewController(), animated: true)
                    }
                })
                .disposed(by: disposeBag)
        }
    }

    override func bindViewModels() {
        super.bindViewModels()

        viewModel.userInfoEnvelope
            .map { $0.userInfo.needNDVipWarning }
            .filterNil()
            .filter { $0 == "1" }
            .subscribe(onNext: { [weak self] isVIP in
                self?.showMembershipPop()
            })
            .disposed(by: disposeBag)

        viewModel.userInfoEnvelope
            .subscribe(onNext: { [weak self] env in
                guard let self = self else { return }

                self.banner = env.banner?.first
                self.userInfo = env.userInfo
                if env.userInfo.isBlackGold == "1" {
                    self.navigationBar.setNavBlackGoldState()
                }
                self.navigationBar.nameText = env.userInfo.nickname
                if let services = env.services {
                    self.services = services
                }

                self.collectionView.reloadData()

                if let id = env.userInfo.userId {
                    AppEnvironment.userDefault.setValue(id, forKey: AppEnvironment.userDefaultUserIdKey)
                    AppEnvironment.userDefault.synchronize()
                }
            }).disposed(by: disposeBag)

        viewModel.userInfoEnvelope
            .map { Int($0.userInfo.notificationCount ?? "0") }
            .filterNil()
            .subscribe(onNext: { [weak self] count in
                self?.navigationBar.showUnreadMessage(count)
                if let root = UIApplication.shared.keyWindow?.rootViewController as? MainViewController {
                    root.updateUnreadNotificationCount(count)
                }
            })
            .disposed(by: disposeBag)

        viewModel.userInfoEnvelope
            .map { $0.userInfo.hasBoundPhone }
            .filterNil()
            .filter { $0 == false }
            .subscribe(onNext: { [weak self] need in
                guard let self = self else { return }
                self.bindPhone()
            })
            .disposed(by: disposeBag)
    }

    func bindPhone() {
        // 拿到上次绑定手机弹出时间
        let lastDate = UserDefaults.standard.object(forKey: BindPhoneNoticeKey)
        if let date = lastDate { // 已经展示过
            // 当前时间
            let com1 = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            // 上次提示时间
            let com2 = Calendar.current.dateComponents([.year, .month, .day], from: date as! Date)
            // 判断是否上次更新时间和现在是否为同一天
            if  com1.year == com2.year &&
                com1.month == com2.month &&
                com1.day == com2.day {
            } else { // 不为同一天才展示
                showPhoneVc()
            }
        } else { // 还未展示
            showPhoneVc()
        }
    }

    func showPhoneVc() {
        UserDefaults.standard.setValue(Date(), forKey: BindPhoneNoticeKey)
        UserDefaults.standard.synchronize()

        let vc = PhoneViewController()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services.isEmpty ? profileArrays.count : profileArrays.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCollectionViewCellId, for: indexPath) as! ProfileCollectionViewCell

        if indexPath.row < 2 {
            let sectionProfiles = profileArrays[indexPath.row]
            cell.configureWith(profiles: sectionProfiles, row: indexPath.row)
            cell.buttonTapHandle = { [weak self] index in
                self?.navigationController?.pushViewController(sectionProfiles[index].vc, animated: true)
            }
        } else if indexPath.row == 2, !services.isEmpty {
            cell.configureWith(services: services)
            cell.buttonTapHandle = { [weak self] index in
                RouterService.route(to: self?.services[index].action)
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 2 {
            let rows = ceil(Double(services.count) / 4.0)
            return CGSize(width: Constants.kScreenWidth - 24, height:  rows * 80 + 48)
        } else {
            return CGSize(width: Constants.kScreenWidth - 24, height: 128)
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            self.headerView = (collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeadViewId, for: indexPath) as! ProfileHeaderView)
            headerView.configureWith(userInfo: self.userInfo, banner: self.banner)
            bindHeaderView()
            return self.headerView!
        } else {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileSectionViewId, for: indexPath) as! ProfileSectionView
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 控制navigationBar显示
        var y = scrollView.contentOffset.y
        if y <= 0 { // 下拉
            collectionView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: 0), animated: false)
            collectionView.bounces = false
            navigationBar.backgroundColor = .clear
            navigationBar.nameLabel.isHidden = true
        } else { // 上拉
            collectionView.bounces = true
            if y >= Constants.kStatusBarHeight {
                y = Constants.kStatusBarHeight
            }
            navigationBar.backgroundColor = .qu_yellow
            navigationBar.nameLabel.isHidden = false
        }
    }
}

