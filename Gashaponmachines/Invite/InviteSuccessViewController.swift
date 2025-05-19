class InviteSuccessViewController: BaseViewController {

    let inviteButton = UIButton.whiteTextCyanGreenBackgroundButton(title: "+ 立即邀请")

    fileprivate func setupInviteSuccessView() {
        self.view.backgroundColor = .clear
        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        blackView.tag = 440
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        contentView.tag = 441
        blackView.addSubview(contentView)

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: "您已经成功使用邀请码\n立即邀请好友可获得高达")
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(contentView).offset(20)
        }

//        let titleLbl = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "立即邀请好友可获得高达")
//        contentView.addSubview(titleLbl)
//        titleLbl.snp.makeConstraints { make in
//            make.centerX.equalTo(contentView)
//            make.top.equalTo(titleLabel.snp.bottom).offset(10)
//        }

        let quitButton = UIButton.with(imageName: "input_close")
        quitButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        contentView.addSubview(quitButton)
        quitButton.snp.makeConstraints { make in
            make.size.equalTo(25)
            make.right.equalTo(contentView).offset(-4)
            make.top.equalTo(contentView).offset(4)
        }

        let logo = UIImageView(image: UIImage(named: "invite_success"))
        contentView.addSubview(logo)
        logo.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalTo(contentView)
            make.width.equalToSuperview()
            make.height.equalTo(160)
        }

        contentView.addSubview(inviteButton)
        inviteButton.snp.makeConstraints { make in
            make.top.equalTo(logo.snp.bottom).offset(16)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(48)
            make.bottom.equalTo(contentView).offset(-16)
        }

        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.center.equalTo(blackView)
//            make.height.equalTo(210)
//            make.top.equalTo(titleLabel.snp.top).offset(-12)
//            make.bottom.equalTo(inviteButton.snp.bottom).offset(12)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInviteSuccessView()
    }

    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}
