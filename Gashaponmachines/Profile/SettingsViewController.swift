import UIKit
import RxDataSources
import RxCocoa
import RxSwift
import Kingfisher
import RxGesture

private let SettingsTableViewCellReusableIdentifier = "SettingsTableViewCellReusableIdentifier"
private let SettingsSubTitleCellReusableIdentifier = "SettingsClearCacheCellReusableIdentifier"

extension SettingsEnvelope: SectionModelType {
    public var items: [Setting] {
        return self.settings
    }

    public init(original: SettingsEnvelope, items: [Setting]) {
        self = original
    }

    public typealias Item = Setting
}

final class SettingsViewController: BaseViewController {

    private var hasBindPhone: Bool

    private var bindPhoneTip: String?

    private var phone: String?

    private var bindPhoneCell: SettingsSubTitleCell?

    init(hasBindPhone: Bool, bindPhoneTip: String?, phone: String?) {
        self.hasBindPhone = hasBindPhone
        self.bindPhoneTip = bindPhoneTip
        self.phone = phone
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var logoutButton = UIButton.with(title: "退出当前账号", titleColor: UIColor.UIColorFromRGB(0xff0000), fontSize: 28)

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .grouped)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .new_backgroundColor
        tv.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCellReusableIdentifier)
        tv.register(SettingsSubTitleCell.self, forCellReuseIdentifier: SettingsSubTitleCellReusableIdentifier)
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .new_backgroundColor
        
        let navBar = CustomNavigationBar()
        navBar.title = "系统设置"
        navBar.backgroundColor = .clear
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalToSuperview()
        }
        
        self.setupHeaderView()
        
        self.setupFooterView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func setupHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: 64))
        headerView.backgroundColor = .clear
        tableView.tableHeaderView = headerView
        
        let infomationView = RoundedCornerView(corners: .allCorners, radius: 12, backgroundColor: .white)
//        infomationView.frame = CGRect(x: 0, y: 0, width: Constants.kScreenWidth-24, height: 52)
        headerView.addSubview(infomationView)
        infomationView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(52)
        }
        
        let infomationLb = UILabel.with(textColor: .black, fontSize: 28, defaultText: "个人资料")
        infomationView.addSubview(infomationLb)
        infomationLb.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
        }
        
        let arrowIv = UIImageView(image: UIImage(named: "delivery_arrow"))
        infomationView.addSubview(arrowIv)
        arrowIv.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        
        let infomationButton = UIButton()
        infomationButton.addTarget(self, action: #selector(editInfomation), for: .touchUpInside)
        infomationView.addSubview(infomationButton)
        infomationButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupFooterView() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: 52))
        footerView.layer.cornerRadius = 12
        footerView.backgroundColor = .white
        footerView.addSubview(logoutButton)

        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        logoutButton.snp.makeConstraints { make in
            make.edges.equalTo(footerView)
        }
        self.tableView.tableFooterView = footerView
    }

    override func bindViewModels() {
        super.bindViewModels()
    }

    @objc func editInfomation() {
        self.navigationController?.pushViewController(InfomationViewController(), animated: true)
    }
    
    @objc func logout() {
        let alertVC = UIAlertController.genericConfirm("元気扭蛋", message: "确定退出当前账号吗？", actionTitle: "确定", cancelTitle: "取消", confirmHandler: { _ in
            AppEnvironment.logout()
            self.navigationController?.popViewController(animated: true)
        })
        self.present(alertVC, animated: true, completion: nil)
    }

    private func clearTempFolder() {
        let fileManager = FileManager.default
        let tempFolderPath = NSTemporaryDirectory()
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: tempFolderPath + filePath)
            }
        } catch {
            QLog.error("Could not clear temp folder: \(error.localizedDescription)")
        }
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
    	return CONST_SETTINGS.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CONST_SETTINGS[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let setting = CONST_SETTINGS[indexPath.section][indexPath.row]

        switch setting {
        case .bgm, .music, .vibrate, .danmaku:
            let cell: SettingsTableViewCell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCellReusableIdentifier) as! SettingsTableViewCell
            cell.configureWith(setting: setting, isLast: indexPath.row == CONST_SETTINGS[indexPath.section].count-1, isFirst: indexPath.row == 0)
            cell.switcher.isOn = setting.isEnabled
            cell.switcher.rx.isOn.asDriver()
                .skip(1)
                .drive(onNext: { isOn in
                    setting.setEnable(enable: isOn)
                })
                .disposed(by: cell.rx.reuseBag)
            return cell
        case .bindPhone:
            let cell: SettingsSubTitleCell = tableView.dequeueReusableCell(withIdentifier: SettingsSubTitleCellReusableIdentifier) as! SettingsSubTitleCell
            cell.configureWith(setting, isLast: indexPath.row == CONST_SETTINGS[indexPath.section].count-1)
            cell.subTitleLabel.text = bindPhoneTip
            self.bindPhoneCell = cell
            return cell
        case .clearCache, .aboutMe:
            let cell: SettingsSubTitleCell = tableView.dequeueReusableCell(withIdentifier: SettingsSubTitleCellReusableIdentifier) as! SettingsSubTitleCell
            cell.configureWith(setting, isLast: indexPath.row == CONST_SETTINGS[indexPath.section].count-1)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let setting = CONST_SETTINGS[indexPath.section][indexPath.row]
        if setting == .clearCache {
            clearCache()
        } else if setting == .bindPhone {

            if hasBindPhone, let phone = self.phone {
                let view = PhoneRebindView(phone: phone)
                view.canDismissOnBackgroundTap = true
                view.bindButton.rx.tap
                    .asDriver()
                    .drive(onNext: { [weak self] in
                        view.removeFromSuperview()
                        self?.showBindPhoneVC()
                    })
                    .disposed(by: disposeBag)
                UIApplication.shared.keyWindow?.addSubview(view)
            } else {
                showBindPhoneVC()
            }
        } else if setting == .aboutMe {
            self.navigationController?.pushViewController(AboutViewController(), animated: true)

        }
    }

    private func showBindPhoneVC() {
        let vc = PhoneViewController()
        vc.completionBlock = { [weak self] phone in
            self?.bindPhoneCell?.subTitleLabel.text = phone.hidesMiddleCharacters()
            self?.hasBindPhone = true
            self?.phone = phone
        }
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }

    private func clearCache() {
        let alertVC = UIAlertController.genericConfirm("清除缓存", message: "是否清除缓存？", actionTitle: "确定", cancelTitle: "取消", confirmHandler: { [weak self] _ in
            KingfisherManager.shared.cache.clearDiskCache()
            self?.clearTempFolder()
            self?.tableView.reloadData()
            HUD.success(second: 2, text: "清除成功", completion: nil)
        })
        self.navigationController?.present(alertVC, animated: true, completion: nil)
    }
}

fileprivate extension String {

    func hidesMiddleCharacters(beginIdx: Int = 3, endIdx: Int = 7) -> String {
        guard endIdx > beginIdx, self.count == 11 else { return self }
        let lowerBound = String.Index(encodedOffset: beginIdx)
        let upperBound = String.Index(encodedOffset: endIdx)
        let substr = self[lowerBound...upperBound]
        var star = ""
        for _ in 0...endIdx-beginIdx {
            star += "*"
        }
        return self.replacingOccurrences(of: substr, with: star)
    }
}
