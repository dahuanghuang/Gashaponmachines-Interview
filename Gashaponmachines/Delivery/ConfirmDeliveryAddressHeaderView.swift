import UIKit
import RxCocoa
import RxSwift

// extension Reactive where Base: ConfirmDeliveryAddressHeaderView {
//    var envelope: Binder<ShipInfoEnvelope> {
//        return Binder(self.base) { (view, envelope) -> Void in
//            view.itemCountLabel.text = "共 \(envelope.products.count) 件"
//            view.priceLabel.text =  envelope.expressFee
//        }
//    }
// }

class ConfirmDeliveryAddressHeaderView: UIView {
    
    var address: DeliveryAddress?

    func calculateHeight() -> CGFloat {
        if self.address == nil {
            return 64
        }else {
            return 12 + 18 + 6 + self.addressLabel.intrinsicContentSize.height + 14 + 12
        }
    }
    
    let contentView = UIView.withBackgounrdColor(.white)

	let addButton = UIButton()
    
    let addIv = UIImageView(image: UIImage(named: "address_add"))
    
    let addTtitleLb = UILabel.with(textColor: .black, boldFontSize: 32, defaultText: "需要先填写信息哦~")
    
    let addDescLb = UILabel.with(textColor: UIColor(hex: "FF602E")!, fontSize: 26, defaultText: "立刻填写")
    
    let locationIv = UIImageView(image: UIImage(named: "address_location"))
    
    let indicator = UIImageView(image: UIImage(named: "select_indicator"))
    
    let nicknameLabel = UILabel.with(textColor: UIColor.qu_black, boldFontSize: 28, defaultText: "")
    
    let phoneLabel = UILabel.with(textColor: UIColor.qu_black, boldFontSize: 28, defaultText: "")

    let addressLabel = UILabel.with(textColor: UIColor.qu_black, fontSize: 24, defaultText: "")

    override init(frame: CGRect) {
        super.init(frame: frame)
        
		self.backgroundColor = .new_backgroundColor
        
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(-12)
        }
        
        self.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        
        self.addSubview(addIv)
        addIv.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(28)
        }
        
        self.addSubview(addTtitleLb)
        addTtitleLb.snp.makeConstraints { make in
            make.left.equalTo(addIv.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }
        
        self.addSubview(addDescLb)
        addDescLb.snp.makeConstraints { make in
            make.right.equalTo(indicator.snp.left).offset(-1)
            make.centerY.equalToSuperview()
        }

        self.addSubview(locationIv)
        locationIv.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(12)
            make.size.equalTo(28)
        }
        
        nicknameLabel.numberOfLines = 1
        self.addSubview(nicknameLabel)
        nicknameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        nicknameLabel.snp.makeConstraints { make in
            make.left.equalTo(locationIv.snp.right).offset(16)
            make.top.equalTo(12)
            make.height.equalTo(18)
        }
        
        phoneLabel.numberOfLines = 1
        self.addSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nicknameLabel)
            make.left.equalTo(nicknameLabel.snp.right).offset(8)
            make.right.equalTo(indicator.snp.left).offset(-12)
        }

        addressLabel.numberOfLines = 0
        self.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(6)
            make.left.equalTo(nicknameLabel)
            make.right.equalTo(indicator.snp.left).offset(-12)
        }
        
        addButton.isUserInteractionEnabled = true
        self.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(address: DeliveryAddress?) {
        self.address = address
        
        if let address = address {
            nicknameLabel.text = address.name
            nicknameLabel.sizeToFit()
            phoneLabel.text = address.phone
            addressLabel.text = address.address
            addressLabel.sizeToFit()
        }

        // 是否初始化状态
        let isDefault = address == nil
        
        addIv.isHidden = !isDefault
        addTtitleLb.isHidden = !isDefault
        addDescLb.isHidden = !isDefault
        
        phoneLabel.isHidden = isDefault
        addressLabel.isHidden = isDefault
        nicknameLabel.isHidden = isDefault
        locationIv.isHidden = isDefault
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.roundCorners([.bottomLeft, .bottomRight], radius: 12)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
