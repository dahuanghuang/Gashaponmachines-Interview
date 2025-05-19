import RxSwift
import RxCocoa

protocol MallHeaderViewDelegate: class {
    func didClickSaerchButton()
    func didClickRecordButton()
}

class MallHeaderView: UIView {

    weak var delegate: MallHeaderViewDelegate?
    
    var balance: String = "" {
        didSet {
            self.balanceLb.text = balance
        }
    }
    
    /// 余额
    lazy var balanceLb: UILabel = {
        let lb = UILabel.numberFont(size: 20)
        lb.textAlignment = .left
        lb.textColor = .black
        return lb
    }()
    
    /// 搜索背景
    lazy var searchBgView: UIView = {
        let v = UIView.withBackgounrdColor(.white)
        v.layer.cornerRadius = 16
        return v
    }()
    
    /// 眼睛
    let searchIv = UIImageView(image: UIImage(named: "home_search"))
    
    /// 分割线
    let line = UIView.withBackgounrdColor(.qu_lightGray.alpha(0.3))
    
    /// 搜索内容
    lazy var searchLabel: UILabel = {
        let lb = UILabel.with(textColor: .qu_lightGray, fontSize: 22, defaultText: "高达")
        return lb
    }()
    
    /// 搜索点击跳转
    lazy var searchButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(searchButtonClick), for: .touchUpInside)
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        let myLb = UILabel.with(textColor: .black.alpha(0.6), fontSize: 16, defaultText: "我的蛋壳")
        myLb.textAlignment = .left
        self.addSubview(myLb)
        myLb.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.equalTo(12)
        }
        
        self.addSubview(balanceLb)
        balanceLb.snp.makeConstraints { make in
            make.left.equalTo(myLb)
            make.top.equalTo(myLb.snp.bottom)
        }
        
        let recordIv = UIImageView(image: UIImage(named: "mall_record"))
        recordIv.isUserInteractionEnabled = true
        recordIv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(recordButtonClick)))
        self.addSubview(recordIv)
        recordIv.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-12)
            make.size.equalTo(28)
        }
        
        self.addSubview(searchBgView)
        searchBgView.snp.makeConstraints { make in
            make.left.equalTo(balanceLb.snp.right).offset(20)
            make.centerY.equalToSuperview()
            make.right.equalTo(recordIv.snp.left).offset(-12)
            make.height.equalTo(32)
        }
        
        searchBgView.addSubview(searchIv)
        searchIv.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }
        
        searchBgView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalTo(searchIv.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(16)
        }
        
        searchBgView.addSubview(searchLabel)
        searchLabel.snp.makeConstraints { make in
            make.left.equalTo(line.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        
        searchBgView.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc func recordButtonClick() {
        if let delegate = self.delegate {
            delegate.didClickRecordButton()
        }
    }
    
    @objc func searchButtonClick() {
        if let delegate = self.delegate {
            delegate.didClickSaerchButton()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
