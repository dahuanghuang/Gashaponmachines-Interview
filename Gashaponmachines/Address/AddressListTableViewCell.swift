import UIKit
import RxCocoa
import RxSwift

class AddressListTableViewCell: BaseTableViewCell {

    var nicknameLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32)

    var phoneLabel = UILabel.with(textColor: .new_gray, fontSize: 28)

    var addressLabel = UILabel.with(textColor: .qu_black, fontSize: 28)

    let defaultButton = AddressListDefaultAddressButton()

    let container = UIView()

    let indicator = UIImageView(image: UIImage(named: "address_right_edit"))

    let editAddressButton = UIButton()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = .new_backgroundColor

        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.masksToBounds = true
        self.contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.left.equalTo(self.contentView).offset(12)
            make.right.equalTo(self.contentView).offset(-12)
            make.bottom.equalTo(self.contentView)
            make.top.equalTo(self.contentView).offset(12)
        }

        container.addSubview(nicknameLabel)
        nicknameLabel.snp.makeConstraints { make in
            make.left.equalTo(container).offset(12)
            make.top.equalTo(container).offset(10)
        }

        container.addSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { make in
            make.left.equalTo(nicknameLabel.snp.right).offset(9)
            make.centerY.equalTo(nicknameLabel)
        }

        indicator.isUserInteractionEnabled = false
        container.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.right.equalTo(container).offset(-12)
            make.centerY.equalTo(self.contentView)
            make.width.equalTo(28)
            make.height.equalTo(28)
        }

        container.addSubview(addressLabel)
        addressLabel.numberOfLines = 0
        addressLabel.preferredMaxLayoutWidth = Constants.kScreenWidth - 56
        addressLabel.snp.makeConstraints { make in
            make.left.equalTo(nicknameLabel)
            make.right.equalTo(indicator.snp.left).offset(-28)
            make.top.equalTo(nicknameLabel.snp.bottom).offset(4)
        }
        
        let line = UIView.withBackgounrdColor(.new_backgroundColor.alpha(0.4))
        container.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalTo(addressLabel)
            make.right.equalTo(indicator)
            make.top.equalTo(addressLabel.snp.bottom).offset(13)
            make.height.equalTo(1)
        }
        
        container.addSubview(defaultButton)
        defaultButton.snp.makeConstraints { make in
            make.left.equalTo(addressLabel)
            make.top.equalTo(line.snp.bottom)
            make.height.equalTo(40)
            make.bottom.equalTo(container)
        }

        container.addSubview(editAddressButton)
        editAddressButton.snp.makeConstraints { (make) in
            make.left.equalTo(addressLabel.snp.right)
            make.top.right.bottom.equalToSuperview()
        }
    }

    func configureWith(address: DeliveryAddress) {
        self.nicknameLabel.text = address.name
        self.phoneLabel.text = address.phone
        self.addressLabel.text = address.address
        self.addressLabel.setLineSpacing(lineHeightMultiple: 1.5)
    	self.defaultButton.isDefault = address.isDefault == "1"
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AddressListDefaultAddressButton: UIButton {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let margin: CGFloat = 5
        let area = self.bounds.insetBy(dx: -margin, dy: -margin)
        return area.contains(point)
    }

    var isDefault: Bool = false {
        didSet {
            self.label.textColor = isDefault ? UIColor.qu_orange : UIColor.lightGray
            self.selectedIcon.image = isDefault ? UIImage(named: "address_default_select") : UIImage(named: "address_default_unselect")
        }
    }

    var selectedIcon = UIImageView(image: UIImage(named: "exchangeDetail_unselect"))
    var label = UILabel.with(textColor: UIColor.lightGray, fontSize: 24, defaultText: "设为默认地址")

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(selectedIcon)
        selectedIcon.snp.makeConstraints { make in
            make.left.centerY.equalTo(self)
            make.size.equalTo(20)
        }

        addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(selectedIcon.snp.right).offset(6)
            make.centerY.right.equalTo(self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
