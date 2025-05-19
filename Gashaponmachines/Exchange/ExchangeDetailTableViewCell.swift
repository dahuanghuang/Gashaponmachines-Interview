import RxCocoa
import RxSwift

extension Reactive where Base: ExchangeDetailTableViewCell {
    var isSelected: Binder<Bool> {
        return Binder(self.base) { (view, isSelected) -> Void in
            view.isSelected = isSelected
            view.selectedIcon.image = isSelected ? UIImage(named: "login_selected") : UIImage(named: "login_unselect")
        }
    }
}

class ExchangeDetailTableViewCell: BaseTableViewCell {

    /// 商品图
    let productIv: UIImageView = UIImageView()
    /// 商品名称
    let titleLabel: UILabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)
    /// 过期时间
    let expireLabel: UILabel = UILabel.with(textColor: .qu_lightGray, fontSize: 20)
    /// 价值
    lazy var valueLabel: UILabel = {
        let lb = UILabel.numberFont(size: 20)
        lb.textColor = .new_orange
        return lb
    }()
    let selectedIcon: UIImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.backgroundColor = .new_backgroundColor
        
        let container = UIView.withBackgounrdColor(.white)
        container.layer.cornerRadius = 12
        contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(12)
            make.right.bottom.equalTo(-12)
        }
    
        container.addSubview(selectedIcon)
        selectedIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.size.equalTo(28)
        }
        
        container.addSubview(productIv)
        productIv.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(52)
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
            make.width.equalTo(productIv.snp.height)
        }

        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(productIv.snp.right).offset(8)
            make.right.equalTo(-12)
            make.top.equalTo(productIv).offset(4)
        }
        
        container.addSubview(expireLabel)
        expireLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        container.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.bottom.equalTo(productIv)
        }
        
        let dankeLabel = UILabel.with(textColor: .new_middleGray, fontSize: 28, defaultText: "蛋壳")
        container.addSubview(dankeLabel)
        dankeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(valueLabel)
            make.left.equalTo(valueLabel.snp.right).offset(2)
        }
    }

    func bind(to state: Driver<Set<EggProduct>>, as item: EggProduct) {
        state.map { $0.contains(item) }
            .drive(self.rx.isSelected)
            .disposed(by: self.rx.reuseBag)
    }

    func configureWith(eggProduct: EggProduct) {
        self.productIv.gas_setImageWithURL(eggProduct.image)
        self.titleLabel.text = eggProduct.title
        if var tips = eggProduct.tips {
            self.expireLabel.attributedText = tips.getEggExpiredAttrString()
        }
        if let worth = eggProduct.worth {
            self.valueLabel.text = "\(worth)"
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.productIv.cancelNetworkImageDownloadTask()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
