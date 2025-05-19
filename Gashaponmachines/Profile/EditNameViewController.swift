class EditNameViewController: BaseViewController {
    
    let viewModel = InfomationViewModel()
    
    lazy var editTextFiled: CheckTextFiled = {
        let tf = CheckTextFiled()
        tf.autocapitalizationType = .none // 关闭首字母大写
        tf.font = UIFont.boldSystemFont(ofSize: 14)
        tf.placeholder = "请输入昵称"
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .new_backgroundColor
        
        let navBar = CustomNavigationBar()
        navBar.title = "修改名称"
        navBar.backgroundColor = .clear
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }
        
        let saveButton = UIButton.with(title: "保存", titleColor: UIColor(hex: "FF602E")!, fontSize: 32, target: self, selector: #selector(saveName))
        navBar.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(Constants.kStatusBarHeight)
            make.right.equalTo(-16)
            make.height.equalTo(44)
        }
        
        let contentView = RoundedCornerView(corners: .allCorners, radius: 12, backgroundColor: .white)
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(84)
        }
        
        let myNameLabel = UILabel.with(textColor: .new_gray, fontSize: 24, defaultText: "我的名称")
        contentView.addSubview(myNameLabel)
        myNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(12)
            make.height.equalTo(32)
        }
        
        
        contentView.addSubview(editTextFiled)
        editTextFiled.snp.makeConstraints { make in
            make.top.equalTo(myNameLabel.snp.bottom)
            make.left.equalTo(12)
            make.height.equalTo(40)
            make.right.equalTo(-12)
        }
        
        let warningIv = UIImageView(image: UIImage(named: "profile_warning"))
        view.addSubview(warningIv)
        warningIv.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.bottom).offset(8)
            make.left.equalTo(contentView)
            make.size.equalTo(14)
        }
        
        let warningLb = UILabel.with(textColor: UIColor(hex: "FF602E")!, fontSize: 20, defaultText: "只能修改一次请谨慎修改哦")
        view.addSubview(warningLb)
        warningLb.snp.makeConstraints { make in
            make.centerY.equalTo(warningIv)
            make.left.equalTo(warningIv.snp.right).offset(6)
        }
    }
    
    @objc func saveName() {
        if let username = editTextFiled.text {
            self.viewModel.editUserInfo.onNext((username, nil))
        }
    }
    
    override func bindViewModels() {
        super.bindViewModels()
        
        viewModel.editUserInfoEnvelope.subscribe(onNext: { [weak self] env in
            guard let self = self else { return }
            if env.code == String(GashaponmachinesError.success.rawValue) {
                HUD.success(second: 1, text: "昵称修改成功") {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                HUD.showError(second: 2, text: env.msg, completion: nil)
            }
        }).disposed(by: disposeBag)
        
        viewModel.error
            .subscribe(onNext: { env in
                HUD.showErrorEnvelope(env: env)
            })
            .disposed(by: disposeBag)
    }
}

class CheckTextFiled: UITextField {
    /// 最大输入字符数
    var maxInputCount: Int = 16
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addTarget(self, action: #selector(handleEditingChanged(_:)), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func handleEditingChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        // 排除键盘拼音显示的计算, 直接按照TextField输出文字计算
        if sender.markedTextRange != nil { return }
        let s = (text as NSString)
        let minCount = min(s.length, maxInputCount)
        self.text = s.substring(to: minCount)
    }
}


