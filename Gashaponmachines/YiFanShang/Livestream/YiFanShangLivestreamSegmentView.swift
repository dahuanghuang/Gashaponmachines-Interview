class YiFanShangLivestreamSegmentView: UIView {

    static let height: CGFloat = 52

    private lazy var containerView = UIView.withBackgounrdColor(UIColor(hex: "FF7C74")!)

    let bottomLine = UIView.withBackgounrdColor(UIColor(hex: "FFC3A1")!)

    var myRecordTapCallBack: (() -> Void)?

    var allRecordTapCallBack: (() -> Void)?

    var myRecordsCount: Int = 0 {
        didSet {
            myButton.setTitle("我的(\(myRecordsCount))", for: .normal)
        }
    }
    
    private lazy var allButton = UIButton.with(title: "全部", titleColor: .white, boldFontSize: 32)
    private lazy var myButton = UIButton.with(title: "我的", titleColor: .white, fontSize: 32)

    private lazy var line = UIView.withBackgounrdColor(.white)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    func setupUI() {
        self.backgroundColor = UIColor(hex: "FFD3D4")
        
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        allButton.addTarget(self, action: #selector(allRecordButtonTap), for: .touchUpInside)
        containerView.addSubview(allButton)
        allButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }

        myButton.addTarget(self, action: #selector(myRecordButtonTap), for: .touchUpInside)
        containerView.addSubview(myButton)
        myButton.snp.makeConstraints { make in
            make.left.equalTo(allButton.snp.right).offset(24)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }

        bottomLine.layer.cornerRadius = 2
        containerView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.top.equalTo(allButton.snp.bottom).offset(4)
            make.height.equalTo(4)
            make.width.equalTo(24)
            make.centerX.equalTo(allButton)
        }
    }

    @objc func myRecordButtonTap() {
        setIndicatorLocation(at: 1)
        
        if let callback = myRecordTapCallBack {
            callback()
        }
    }

    @objc func allRecordButtonTap() {
        setIndicatorLocation(at: 0)
        
        if let callback = allRecordTapCallBack {
            callback()
        }
    }

    /// 设置指示器位置
    func setIndicatorLocation(at index: Int) {
        if index == 0 {
            allButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            myButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        }else {
            allButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            myButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        }
        
        bottomLine.snp.remakeConstraints { (make) in
            make.top.equalTo(allButton.snp.bottom).offset(4)
            make.height.equalTo(4)
            make.width.equalTo(24)
            if index == 0 {
                make.centerX.equalTo(allButton)
            } else if index == 1 {
                make.centerX.equalTo(myButton)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        containerView.roundCorners([.topLeft, .topRight], radius: 12)
    }
}
