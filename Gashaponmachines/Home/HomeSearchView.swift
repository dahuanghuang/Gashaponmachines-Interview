import UIKit

class HomeSearchView: UIView {
    
    /// 搜索点击回调
    var searchButtonClickHandle: (() -> Void)?

    /// 整体背景
    lazy var searchBgView: UIView = {
        let v = UIView.withBackgounrdColor(.white)
        v.layer.borderColor = UIColor.new_yellow.cgColor
        v.layer.borderWidth = 2
        v.layer.cornerRadius = 16
        return v
    }()
    
    /// 眼睛
    let searchIv = UIImageView(image: UIImage(named: "home_search"))
    
    /// 分割线
    let line = UIView.withBackgounrdColor(.qu_lightGray.alpha(0.3))
    
    /// 搜索内容
    lazy var searchLabel: UILabel = {
        let lb = UILabel.with(textColor: .qu_lightGray, fontSize: 22)
        return lb
    }()
    
    /// 搜索按钮
    lazy var searchButton: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 18
        btn.backgroundColor = .new_bgYellow
        btn.setTitle("搜索", for: .normal)
        btn.setTitleColor(UIColor(hex: "754E00"), for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        return btn
    }()
    
    /// 新手活动
    lazy var newUserIv: UIImageView = {
        let iv = UIImageView() 
        iv.isHidden = true
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(jumpToNewUser)))
        return iv
    }()
    
    /// 搜索点击跳转
    lazy var clickButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(buttonOnClick), for: .touchUpInside)
        return btn
    }()

    var info: HomeActivityInfo?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        addSubview(searchBgView)
        
        searchBgView.addSubview(searchIv)
        
        searchBgView.addSubview(line)
        
        searchBgView.addSubview(searchLabel)
        
        searchBgView.addSubview(searchButton)

        addSubview(newUserIv)
        
        searchBgView.addSubview(clickButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        searchBgView.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
            make.right.equalTo(-12)
            make.height.equalTo(36)
        }
        
        searchIv.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }
        
        line.snp.makeConstraints { make in
            make.left.equalTo(searchIv.snp.right).offset(8)
            make.centerY.equalTo(searchIv)
            make.width.equalTo(1)
            make.height.equalTo(16)
        }
        
        searchLabel.snp.makeConstraints { make in
            make.left.equalTo(line.snp.right).offset(8)
            make.centerY.equalTo(line)
        }
        
        searchButton.snp.makeConstraints { make in
            make.centerY.right.height.equalToSuperview()
            make.width.equalTo(72)
        }
        
        newUserIv.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-12)
            make.size.equalTo(28)
        }
        
        clickButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public func setPlaceholder(_ placeholder: String) {
        searchLabel.text = "\(placeholder)"
    }
    
    public func showNewUser(info: HomeActivityInfo?) {
        self.info = info
        
        let isShow = info != nil
        newUserIv.isHidden = !isShow
        newUserIv.gas_setImageWithURL(info?.icon)
        searchBgView.snp.updateConstraints { make in
            make.right.equalTo(isShow ? -48 : -12)
        }
    }
    
    // 跳转新手任务
    @objc func jumpToNewUser() {
        if let action = self.info?.action {
            RouterService.route(to: action)
        }
    }
    
    // 搜索点击跳转
    @objc func buttonOnClick() {
        if let handle = self.searchButtonClickHandle {
            handle()
        }
    }
    
}
