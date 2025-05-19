class InfomationViewController: BaseViewController {
    
    let viewModel = InfomationViewModel()
    
    let avatarIv = UIImageView()
    
    let avatarEditIv = UIImageView(image: UIImage(named: "profile_avatar_edit"))
    
    let changeAvatarButton = UIButton()
    
    lazy var imagePickerController: UIImagePickerController = {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        return vc
    }()
    
    lazy var nameLabel: UILabel = {
        let lb = UILabel.with(textColor: .black, boldFontSize: 28)
        lb.textAlignment = .right
        return lb
    }()
    
    let arrowIv = UIImageView(image: UIImage(named: "delivery_arrow"))
    
    lazy var uidLabel: UILabel = {
        let lb = UILabel.with(textColor: .black, boldFontSize: 28)
        lb.textAlignment = .right
        return lb
    }()
    
    let nameEditButton = UIButton()
    
    /// 需要上传的图片
    var uploadImage: UIImage?
     
    /// 注销账号按钮
    let destroyAccountBtn = UIButton(type: .custom)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        self.viewModel.viewWillAppearTrigger.onNext(())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let topView = UIView.withBackgounrdColor(.new_yellow)
        view.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + 170)
        }
        
        let navBar = CustomNavigationBar()
        navBar.backgroundColor = .clear
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }
        
        let contentView = RoundedCornerView(corners: [.topLeft, .topRight], radius: 12)
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(Constants.kStatusBarHeight + 102)
            make.left.right.bottom.equalToSuperview()
        }
        
        let avatarView = UIView.withBackgounrdColor(.white)
        avatarView.layer.cornerRadius = 66
        view.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.snp.top)
            make.centerX.equalToSuperview()
            make.size.equalTo(132)
        }
        
        avatarIv.layer.cornerRadius = 62
        avatarIv.layer.masksToBounds = true
        avatarView.addSubview(avatarIv)
        avatarIv.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(124)
        }
        
        avatarView.addSubview(avatarEditIv)
        avatarEditIv.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.size.equalTo(32)
        }
        
        changeAvatarButton.isEnabled = false
        changeAvatarButton.addTarget(self, action: #selector(changeAvatarButtonClick), for: .touchUpInside)
        view.addSubview(changeAvatarButton)
        changeAvatarButton.snp.makeConstraints { make in
            make.edges.equalTo(avatarView)
        }
        
        let nameView = UIView.withBackgounrdColor(.clear)
        contentView.addSubview(nameView)
        nameView.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.bottom).offset(24)
            make.left.equalTo(24)
            make.right.equalTo(-24)
            make.height.equalTo(52)
        }
        
        let nameDescLb = UILabel.with(textColor: .new_gray, fontSize: 28, defaultText: "名称")
        nameView.addSubview(nameDescLb)
        nameDescLb.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }
        
        nameView.addSubview(arrowIv)
        arrowIv.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        
        nameView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-28)
        }
        
        nameEditButton.isEnabled = false
        nameEditButton.addTarget(self, action: #selector(nameButtonClick), for: .touchUpInside)
        nameView.addSubview(nameEditButton)
        nameEditButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let uidView = UIView.withBackgounrdColor(.clear)
        contentView.addSubview(uidView)
        uidView.snp.makeConstraints { make in
            make.top.equalTo(nameView.snp.bottom)
            make.left.equalTo(24)
            make.right.equalTo(-24)
            make.height.equalTo(52)
        }
        
        let uidDescLb = UILabel.with(textColor: .new_gray, fontSize: 28, defaultText: "UID")
        uidView.addSubview(uidDescLb)
        uidDescLb.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }
        
        uidView.addSubview(uidLabel)
        uidLabel.snp.makeConstraints { make in
            make.centerY.right.equalToSuperview()
        }
        
        destroyAccountBtn.isHidden = true
        destroyAccountBtn.addTarget(self, action: #selector(showDestroyAccountPopVc), for: .touchUpInside)
        let title = NSAttributedString(string: "注销账号", attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor: UIColor.new_middleGray,
            NSAttributedString.Key.underlineStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)
            ])
        destroyAccountBtn.setAttributedTitle(title, for: .normal)
        view.addSubview(destroyAccountBtn)
        destroyAccountBtn.snp.makeConstraints { make in
            make.bottom.equalTo(-Constants.kScreenBottomInset-66)
            make.centerX.equalToSuperview()
        }
    }
    
    /// 展示注销账号弹窗
    @objc func showDestroyAccountPopVc() {
        let vc = DestroyAccountPopViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.comfirmButtonClickHandle = { [weak self] in
            self?.showDestroyConfirmPopVc()
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    /// 展示注销账号再次确认弹窗
    @objc func showDestroyConfirmPopVc() {
        let vc = DestroyConfirmPopViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.comfirmButtonClickHandle = { [weak self] in
            self?.showDestroyCompletePopVc()
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    /// 展示注销账号手动输入完成弹窗
    @objc func showDestroyCompletePopVc() {
        let vc = DestroyCompletePopViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.comfirmButtonClickHandle = { [weak self] text in
            guard let self = self else { return }
            self.viewModel.destroyAccountTrigger.onNext(())
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func changeAvatarButtonClick() {
        let vc = EditAvatarPopViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.confirmButtonClickHandle = { [weak self] in
            guard let s = self else { return }
            s.present(s.imagePickerController, animated: true, completion: nil)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func nameButtonClick() {
        self.navigationController?.pushViewController(EditNameViewController(), animated: true)
    }
    
    override func bindViewModels() {
        super.bindViewModels()
        
        viewModel.personalInfoEnvelope
            .subscribe(onNext: { [weak self] env in
                guard let self = self else { return }
                
                self.avatarIv.gas_setImageWithURL(env.avatar)
                self.nameLabel.text = env.nickname
                self.uidLabel.text = env.uid
                
                // 更改头像状态
                if env.leftChangeAvatarTimes < 1 {
                    self.changeAvatarButton.isEnabled = false
                    self.avatarEditIv.isHidden = true
                }else {
                    self.changeAvatarButton.isEnabled = true
                    self.avatarEditIv.isHidden = false
                }
                
                // 更改昵称状态
                if env.leftRenameTimes < 1 {
                    self.nameEditButton.isEnabled = false
                    self.arrowIv.isHidden = true
                    self.nameLabel.snp.updateConstraints { make in
                        make.right.equalTo(0)
                    }
                }else {
                    self.nameEditButton.isEnabled = true
                    self.arrowIv.isHidden = false
                    self.nameLabel.snp.updateConstraints { make in
                        make.right.equalTo(-28)
                    }
                }
                
                // 更改注销账号按钮状态
                self.destroyAccountBtn.isHidden = !env.enableDestroyAccount
            }).disposed(by: disposeBag)
        
        viewModel.getUploadTokenResp
            .subscribe(onNext: { [weak self] env in
                guard let self = self else { return }
                if let image = self.uploadImage, let key = env.keys.first {
                    // 压缩, 上传七牛
                    guard let data = image.jpegData(compressionQuality: 0.3) else { return }
                    HUD.shared.persist(text: "上传中...")
                    UploadService.shared.upload(data: data, key: key, token: env.token, complete: { (info, key, resp) in
                        HUD.shared.dismiss()
                        if let info = info, let k = key, info.statusCode == 200 { // 更改头像
                            self.viewModel.editUserInfo.onNext((nil, k))
                        }else {
                            HUD.showError(second: 2, text: "更改头像失败", completion: nil)
                        }
                    }, progressHandler: nil)
                }  
            })
            .disposed(by: disposeBag)
        
        viewModel.editUserInfoEnvelope.subscribe(onNext: { [weak self] env in
            guard let self = self else { return }
            if env.code == String(GashaponmachinesError.success.rawValue) {
                HUD.success(second: 1, text: "头像修改成功") {
                    self.viewModel.viewWillAppearTrigger.onNext(())
                }
            } else {
                HUD.showError(second: 2, text: env.msg, completion: nil)
            }
        }).disposed(by: disposeBag)
        
        viewModel.destroyAccountEnvelope.subscribe(onNext: { env in
            if env.code == String(GashaponmachinesError.success.rawValue) {
                HUD.success(second: 1, text: "账户注销中, 请等待审核") {
                    self.viewModel.viewWillAppearTrigger.onNext(())
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

extension InfomationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            HUD.showError(second: 2, text: "图片信息有误，请重新选择", completion: nil)
            picker.dismiss(animated: true, completion: nil)
            return
        }
        self.uploadImage = image
        self.viewModel.getUploadToken.onNext(1)
        picker.dismiss(animated: true, completion: nil)
    }
}
