import UIKit
import RxCocoa
import RxSwift

class AddressEditorViewController: UIViewController {
    
    let disposeBag: DisposeBag = DisposeBag()

    var viewModel: AddressEditorViewModel

    /// 是否从我的界面跳转过来
    var isFromProfile = true

    var locationPickerView: QULocationPicker = QULocationPicker(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: 244))
    var locationPopView: KLCPopup?
    let detailTextView = KMPlaceholderTextView()
    let nameTextField = UITextField()
    let phoneTextField = UITextField()
    var districtButton = UIButton()

    fileprivate var provinceCode: String?
    fileprivate var cityCode: String?
    fileprivate var districtCode: String?

    // MARK: - 初始化方法
    init(addressId: String?) {
        self.viewModel = AddressEditorViewModel(addressId: addressId)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 系统方法
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.viewWillAppearTrigger.onNext(())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nav = self.navigationController {
            for vc in nav.viewControllers {
                if vc.isKind(of: ConfirmDeliveryViewController.self) {
                    isFromProfile = false
                }
            }
        }

        self.setupLocationView()
        
        self.setupUI()
        
        self.bindViewModels()
    }
    
    func setupUI() {
        view.backgroundColor = .new_backgroundColor
        
        let navBar = CustomNavigationBar()
        navBar.backgroundColor = .new_backgroundColor
        navBar.title = "编辑收货地址"
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }
        
        let editView = UIView.withBackgounrdColor(.white)
        editView.layer.cornerRadius = 12
        editView.layer.masksToBounds = true
        view.addSubview(editView)
        editView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(260)
        }

        // 收件人
        let nameView = UIView.withBackgounrdColor(.clear)
        editView.addSubview(nameView)
        nameView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(52)
        }

        let nameLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "收货人")
        nameView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(nameView).offset(12)
            make.centerY.equalTo(nameView)
        }

        nameTextField.textColor = UIColor.qu_black
        nameTextField.font = UIFont.withPixel(28)
        nameView.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(80)
            make.top.right.bottom.equalToSuperview()
        }

        let nameLine = UIView.seperatorLine()
        nameView.addSubview(nameLine)
        nameLine.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }

        // 电话号码
        let phoneView = UIView.withBackgounrdColor(.clear)
        editView.addSubview(phoneView)
        phoneView.snp.makeConstraints { make in
            make.top.equalTo(nameView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(52)
        }

        let phoneLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "联系电话")
        phoneView.addSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.centerY.equalToSuperview()
        }

        phoneTextField.textColor = UIColor.qu_black
        phoneTextField.font = UIFont.withPixel(28)
        phoneView.addSubview(phoneTextField)
        phoneTextField.snp.makeConstraints { make in
            make.left.equalTo(nameTextField)
            make.top.right.bottom.equalToSuperview()
        }

        let phoneLine = UIView.seperatorLine()
        phoneView.addSubview(phoneLine)
        phoneLine.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }

        // 地区
        let distictView = UIView.withBackgounrdColor(.clear)
        editView.addSubview(distictView)
        distictView.snp.makeConstraints { make in
            make.top.equalTo(phoneView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(52)
        }

        let districtLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "所在地区")
        distictView.addSubview(districtLabel)
        districtLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.centerY.equalToSuperview()
        }

        let indicator = UIImageView(image: UIImage(named: "select_indicator"))
        distictView.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-12)
        }

        districtButton.backgroundColor = .clear
        districtButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        districtButton.titleLabel?.font = UIFont.withPixel(28)
        districtButton.setTitleColor(.qu_black, for: .normal)
        districtButton.addTarget(self, action: #selector(selectAddress), for: .touchUpInside)
        distictView.addSubview(districtButton)
        districtButton.snp.makeConstraints { make in
            make.left.equalTo(nameTextField)
            make.top.right.bottom.equalToSuperview()
        }

        let distictLine = UIView.seperatorLine()
        distictView.addSubview(distictLine)
        distictLine.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }

        // 详情
        let detailView = UIView.withBackgounrdColor(.clear)
        editView.addSubview(detailView)
        detailView.snp.makeConstraints { make in
            make.top.equalTo(distictView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        let detailLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28, defaultText: "详细地址")
        detailView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.left.equalTo(nameLabel)
        }

        detailTextView.placeholder = "请填写除省市区以外的详细地址，5-30字之间"
        detailTextView.placeholderColor = UIColor.qu_lightGray
        detailTextView.font = UIFont.withPixel(28)
        detailTextView.textColor = .black
        detailTextView.backgroundColor = .white
        detailTextView.textContainerInset = UIEdgeInsets(top: 12, left: -3, bottom: 12, right: 0)
        detailView.addSubview(detailTextView)
        detailTextView.snp.makeConstraints { make in
            make.left.equalTo(nameTextField)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(-52)
        }
        
        let cleanIv = UIImageView(image: UIImage(named: "address_clean"))
        detailView.addSubview(cleanIv)
        cleanIv.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        
        let cleanButton = UIButton()
        cleanButton.addTarget(self, action: #selector(cleanTextView), for: .touchUpInside)
        detailView.addSubview(cleanButton)
        cleanButton.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.left.equalTo(detailTextView.snp.right)
        }

        let line4 = UIView.seperatorLine()
        detailView.addSubview(line4)
        line4.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }

        let buttonTitle = isFromProfile ? "保存" : "保存并使用"
        let confirmButton = UIButton.with(title: buttonTitle, titleColor: UIColor(hex: "754E00")!, boldFontSize: 32)
        confirmButton.backgroundColor = .new_yellow
        confirmButton.layer.cornerRadius = 8
        confirmButton.layer.masksToBounds = true
        confirmButton.addTarget(self, action: #selector(saveAddress), for: .touchUpInside)
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(editView.snp.bottom).offset(24)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(44)
        }
    }
    
    @objc func cleanTextView() {
        self.detailTextView.text = ""
    }

    func setupLocationView() {
        self.locationPopView = KLCPopup(contentView: self.locationPickerView, showType: .bounceInFromBottom, dismissType: .bounceOutToBottom, maskType: .dimmed, dismissOnBackgroundTouch: false, dismissOnContentTouch: false)

        self.locationPickerView.backgroundColor = .white
        self.locationPickerView.selectorHandler = { [weak self] (isCancel, province, city, area, provinceCode, cityCode, areaCode) in
            if !isCancel { // 点击确定
                self?.provinceCode = provinceCode
                self?.cityCode = cityCode
                self?.districtCode = areaCode

                if let province = province, let city = city, let area = area {
                    self?.districtButton.setTitle("\(province) \(city) \(area)", for: .normal)
                } else if let province = province, let city = city {
                    self?.districtButton.setTitle("\(province) \(city)", for: .normal)
                } else if let province = province {
                    self?.districtButton.setTitle("\(province)", for: .normal)
                }
            }
            self?.locationPopView?.dismiss(true)
        }
    }

    func bindViewModels() {

        self.viewModel.result.drive(onNext: { [weak self] address in
            HUD.success(second: 1.5, text: "提交成功") {
                guard let StrongSelf = self else { return }
                if StrongSelf.isFromProfile {
                    StrongSelf.navigationController?.popViewController(animated: true)
                } else {
                    // 返回确认发货界面
                    if let nav = StrongSelf.navigationController {
                        for vc in nav.viewControllers {
                            if vc.isKind(of: ConfirmDeliveryViewController.self) {
                                let viewController = vc as! ConfirmDeliveryViewController
                                viewController.viewModel.selectedAddress.onNext(address)
                                StrongSelf.navigationController?.popToViewController(vc, animated: true)
                            }
                        }
                    }
                }
            }
        })
        .disposed(by: disposeBag)

        self.viewModel.addressDetail
            .drive(onNext: { [weak self] address in
                // 更新 UI
            	self?.nameTextField.text = address.name
            	self?.phoneTextField.text = address.phone
            	self?.detailTextView.text = address.detail
            	self?.districtButton.setTitle("\(address.provinceName) \(address.cityName) \(address.districtName)", for: .normal)

                self?.locationPickerView.preSelectedProvinceCode = address.provinceCode
                self?.locationPickerView.preSelectedCityCode = address.cityCode
                self?.locationPickerView.preSelectedDistrictCode = address.districtCode

                self?.provinceCode = address.provinceCode
                self?.districtCode = address.districtCode
                self?.cityCode = address.cityCode

        	})
        	.disposed(by: disposeBag)

        self.viewModel.error.subscribe(onNext: { env in
            HUD.showErrorEnvelope(env: env)
        })
        .disposed(by: disposeBag)
    }

    @objc func selectAddress() {
		self.view.endEditing(true)

        if self.locationPopView == nil { // 为空重新创建
            self.locationPopView = KLCPopup(contentView: self.locationPickerView, showType: .bounceInFromBottom, dismissType: .bounceOutToBottom, maskType: .dimmed, dismissOnBackgroundTouch: false, dismissOnContentTouch: false)
        }

        if let popView = self.locationPopView, !popView.isShowing { // 有值, 没有正在显示
            self.locationPopView?.show(atCenter: CGPoint(x: self.view.centerX, y: self.view.bounds.size.height - 122), in: self.view)
        }
    }

    @objc func saveAddress() {

        guard let provinceCode = self.provinceCode, let cityCode = self.cityCode, let districtCode = self.districtCode else {
            HUD.showError(second: 1, text: "请选择您的地址信息", completion: nil)
            return
        }

        guard let name = nameTextField.text, !name.isEmpty else {
            HUD.showError(second: 1, text: "请填写姓名", completion: nil)
            return
        }

        guard let phone = phoneTextField.text, !phone.isEmpty else {
            HUD.showError(second: 1, text: "请填写手机号码", completion: nil)
            return
        }

        guard let detail = detailTextView.text, detail.count >= 5, !detail.isEmpty else {
            HUD.showError(second: 1, text: "请填写详细地址, 不少于五个字", completion: nil)
            return
        }

        // 去除手机号码的空格
        self.viewModel.param.onNext((name: name, phone: phone.removeWhitespaces(), proviceCode: provinceCode, cityCode: cityCode, districtCode: districtCode, detail: detail))
    }
}



