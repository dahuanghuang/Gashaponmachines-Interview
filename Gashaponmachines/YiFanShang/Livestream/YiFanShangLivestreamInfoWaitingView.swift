class YiFanShangLivestreamInfoWaitingView: UIView {

    var tipLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .clear

        // 红色背景
        let waitingBgIv = UIImageView()
        waitingBgIv.image = UIImage(named: "yfs_waiting_bg")
        addSubview(waitingBgIv)
        waitingBgIv.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        // 顶部透明背景
        let topView = UIView()
        topView.backgroundColor = UIColor.clear
        addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.67)
        }

        // 底部透明背景
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor.clear
        addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.33)
        }

        // 白色视图
        let whiteView = RoundedCornerView(corners: [.topLeft, .topRight], radius: 12, backgroundColor: .white)
        addSubview(whiteView)
        whiteView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(8)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.bottom.equalTo(bottomView.snp.top)
        }

        tipLabel.textColor = UIColor.UIColorFromRGB(0xe12f3f)
        tipLabel.font = UIFont.systemFont(ofSize: 14)
        tipLabel.text = "等待机台"
        topView.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
