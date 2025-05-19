import RxSwift
import RxCocoa
import RxDataSources
import UIKit
import SnapKit
import RxKeyboard

class ReportViewController: BaseViewController {

    var phoneTextField: UITextField?

    init(physicId: String) {
        self.viewModel = ReportCrashViewModel(physicId: physicId)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let viewModel: ReportCrashViewModel!

    var submitButton: UIButton = {
        let submitButton = UIButton.blackTextYellowBackgroundYellowRoundedButton(title: "提交")
        submitButton.setBackgroundColor(color: .qu_lightGray, forUIControlState: .disabled)
        submitButton.setTitleColor(.white, for: .disabled)
        return submitButton
    }()

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .grouped)
        tv.allowsMultipleSelection = false
        tv.keyboardDismissMode = .onDrag
        tv.register(ReportReasonCell.self, forCellReuseIdentifier: "ReportReasonCell")
        tv.register(ReportDescriptionCell.self, forCellReuseIdentifier: "ReportDescriptionCell")
        return tv
    }()

    lazy var footerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: 68))

        view.addSubview(submitButton)
		submitButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
            	self?.viewModel.buttonTap.onNext(())
        	})
            .disposed(by: disposeBag)
        submitButton.snp.makeConstraints { make in
            make.left.equalTo(view).offset(12)
            make.right.equalTo(view).offset(-12)
            make.top.equalTo(view).offset(20)
            make.height.equalTo(48)
        }
        return view
    }()

    var dataSources: RxTableViewSectionedReloadDataSource<ReportSectionModel>!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "报修"
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        self.tableView.rx.setDelegate(self).disposed(by: disposeBag)

        let sections: [ReportSectionModel] = [
            .reasonSection(title: "请选择故障原因", items: [.reasonSectionItem(title: "视频无反应"), .reasonSectionItem(title: "按钮无反应"), .reasonSectionItem(title: "出球颜色与实际不符"), .reasonSectionItem(title: "其他问题")]),
            .descriptionSection(title: "请描述具体原因", items: [.descriptionSectionItem(title: "故障时间", placeholder: nil, subTitle: String.dateNow()), .descriptionSectionItem(title: "补充内容", placeholder: "未填写", subTitle: nil)]),
            .phoneSection(title: "联系方式", items: [.phoneSectionItem(title: "联系电话", placeholder: "便于我们与您联系", subTitle: nil)])
        ]

        self.dataSources = RxTableViewSectionedReloadDataSource<ReportSectionModel>(
            configureCell: { [unowned self] (ds, tv, ip, _) in
                switch ds[ip] {
                case let .reasonSectionItem(title):
                    let cell: ReportReasonCell = tv.dequeueReusableCell(withIdentifier: "ReportReasonCell") as! ReportReasonCell
                    cell.titleLabel.text = title
                    return cell
                case let .descriptionSectionItem(title, placeholder, subTitle):
                    let cell: ReportDescriptionCell = tv.dequeueReusableCell(withIdentifier: "ReportDescriptionCell") as! ReportDescriptionCell
                    cell.titleLabel.text = title
                    cell.placeholder = placeholder
                    if let sub = subTitle {
                        cell.textView.text = sub
                        cell.textView.isEnabled = false
                    }
                    cell.textView.rx.text.orEmpty.bind(to: self.viewModel.detail).disposed(by: cell.rx.reuseBag)
                    return cell
                case let .phoneSectionItem(title, placeholder, _):
                    let cell: ReportDescriptionCell = tv.dequeueReusableCell(withIdentifier: "ReportDescriptionCell") as! ReportDescriptionCell
                    cell.titleLabel.text = title
                    cell.placeholder = placeholder
                    cell.textView.delegate = self
                    self.phoneTextField = cell.textView
                    cell.textView.rx.text.bind(to: self.viewModel.contact).disposed(by: cell.rx.reuseBag)
                    return cell
                }
        	}
        )

        self.tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] ip in
                let cell = self?.tableView.cellForRow(at: ip) as! ReportReasonCell
                cell.isSelected = true
                self?.viewModel.cause.onNext(cell.titleLabel.text ?? "未知原因")
            })
            .disposed(by: disposeBag)

        self.tableView.rx.itemDeselected
            .subscribe(onNext: { [weak self] ip in
                let cell = self?.tableView.cellForRow(at: ip) as! ReportReasonCell
                cell.isSelected = false
            })
            .disposed(by: disposeBag)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapGesture)

        Observable
            .just(sections)
            .bind(to: tableView.rx.items(dataSource: dataSources))
            .disposed(by: disposeBag)

        self.tableView.tableFooterView = footerView

        RxKeyboard.instance.willShowVisibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                self?.tableView.contentOffset.y += keyboardVisibleHeight
            })
        	.disposed(by: disposeBag)

        RxKeyboard.instance.isHidden
            .filter { $0 == true }
            .drive(onNext: { [weak self] _ in
                self?.tableView.contentOffset = CGPoint.zero
        	})
        	.disposed(by: disposeBag)

        self.viewModel.submitResult
            .drive(onNext: { [weak self] env in
                if env.code == String(GashaponmachinesError.success.rawValue) {
                    let vc = UIAlertController.genericAlert("提交成功", message: "您的反馈已经提交到后台", actionTitle: "好的")
                    self?.present(vc, animated: true, completion: nil)
                } else {
                    HUD.showError(second: 2, text: env.msg, completion: nil)
                }
        	})
        	.disposed(by: disposeBag)

        self.viewModel.cause
            .asObservable()
            .mapTo(true)
            .startWith(false)
            .bind(to: submitButton.rx.isEnabled)
            .disposed(by: disposeBag)

        self.viewModel.error
            .subscribe(onNext: { env in
            	HUD.showErrorEnvelope(env: env)
        	})
        	.disposed(by: disposeBag)
    }

    override func willMove(toParent parent: UIViewController?) {
        self.navigationController?.navigationBar.barTintColor = .qu_yellow
        self.navigationController?.navigationBar.tintColor = .qu_black
    }
}

extension ReportViewController: UITextFieldDelegate {

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {

        if textField == self.phoneTextField {
            if let phoneNum = textField.text, !phoneNum.isValidPhoneNumber() {
                HUD.showError(second: 2, text: "请输入正确的手机号码", completion: nil)
                return true
            }
        }
        return true
    }
}

extension ReportViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 {
            return indexPath
        }
        return nil
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel.with(textColor: .qu_lightGray, fontSize: 24)
        label.text = self.dataSources[section].title
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(view).offset(12)
            make.centerY.equalTo(view)
            make.height.equalTo(48)
        }
        return view
    }
}

enum ReportSectionModel {
    case reasonSection(title: String, items: [ReportSectionItem])
    case descriptionSection(title: String, items: [ReportSectionItem])
    case phoneSection(title: String, items: [ReportSectionItem])
}

enum ReportSectionItem {
    case reasonSectionItem(title: String)
    case descriptionSectionItem(title: String, placeholder: String?, subTitle: String?)
    case phoneSectionItem(title: String, placeholder: String?, subTitle: String?)
}

extension ReportSectionModel: SectionModelType {
    init(original: ReportSectionModel, items: [ReportSectionItem]) {
        switch original {
        case let .reasonSection(title: title, items: _):
            self = .reasonSection(title: title, items: items)
        case let .descriptionSection(title: title, items: _):
            self = .descriptionSection(title: title, items: items)
        case let .phoneSection(title: title, items: _):
            self = .phoneSection(title: title, items: items)
        }
    }

    typealias Item = ReportSectionItem

    var items: [ReportSectionItem] {
        switch self {
        case .reasonSection(title: _, items: let items):
            return items.map { $0 }
        case .descriptionSection(title: _, items: let items):
            return items.map { $0 }
        case .phoneSection(title: _, items: let items):
            return items.map { $0 }
        }
    }

    var title: String {
        switch self {
        case .reasonSection(title: let title, items: _):
            return title
        case .descriptionSection(title: let title, items: _):
            return title
        case .phoneSection(title: let title, items: _):
            return title
        }
    }
}
