
import RxSwift
import RxCocoa

extension Reactive where Base: MallDetailBottomExchangeView {
    var buttonTap: ControlEvent<Void> {
        return self.base.exchangeButton.rx.controlEvent(.touchUpInside)
    }
}

class MallDetailBottomExchangeView: UIView {
    
    let valueIv = UIImageView(image: UIImage(named: "mall_egg"))
    let valueLb = UILabel.numberFont(size: 28)
    /// 立即兑换视图
    let exchangeView = UIView.withBackgounrdColor(UIColor(hex: "FFDA60")!)
    /// 立即兑换按钮
    lazy var exchangeButton: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.new_yellow.cgColor
        btn.backgroundColor = .white.alpha(0.2)
        btn.setTitle("立即兑换", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        btn.setTitleColor(UIColor(hex: "754E00")!, for: .normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        
        let contentView = UIView.withBackgounrdColor(.clear)
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(60)
        }
        
        contentView.addSubview(valueIv)
        valueIv.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        
        valueLb.textColor = .black
        contentView.addSubview(valueLb)
        valueLb.snp.makeConstraints { make in
            make.left.equalTo(valueIv.snp.right).offset(2)
            make.centerY.equalToSuperview()
        }
        
        exchangeView.layer.cornerRadius = 8
        contentView.addSubview(exchangeView)
        exchangeView.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalToSuperview()
            make.width.equalTo(Constants.kScreenWidth-24)
            make.height.equalTo(44)
        }

        exchangeView.addSubview(exchangeButton)
        exchangeButton.snp.makeConstraints { make in
            make.top.left.equalTo(4)
            make.right.bottom.equalTo(-4)
        }
    }
    
    /// 改变兑换状态
    func changeState(_ isChange: Bool) {
        valueIv.isHidden = !isChange
        valueLb.isHidden = !isChange
        let width = isChange ? 176 : (Constants.kScreenWidth-24)
        exchangeView.snp.updateConstraints { make in
            make.width.equalTo(width)
        }
    }
    
    func config(worth: String) {
        valueLb.text = worth
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
