import UIKit

class DeliveryRecordDetailAddressView: UIView {

    let iv = UIImageView(image: UIImage(named: "address_location"))
    let nameLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)
    let phoneLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)
    lazy var addressLabel: UILabel = {
           let label = UILabel.with(textColor: .new_gray, fontSize: 26)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        self.addSubview(iv)
        self.addSubview(nameLabel)
        self.addSubview(phoneLabel)
        self.addSubview(addressLabel)
    }
    
    func config(address: ShipDetailEnvelope.ShipDetailAddress) {
        nameLabel.text = address.name
        phoneLabel.text = address.phone
        addressLabel.text = address.address
        addressLabel.setLineSpacing(lineHeightMultiple: 1.5)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.roundCorners([.bottomLeft, .bottomRight], radius: 12)
        
        iv.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.top.equalTo(12)
            make.size.equalTo(20)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.left.equalTo(iv.snp.right).offset(8)
        }
        phoneLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.left.equalTo(nameLabel.snp.right).offset(8)
            make.right.equalTo(-12)
        }
        addressLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.right.equalTo(phoneLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.bottom.equalTo(-12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
