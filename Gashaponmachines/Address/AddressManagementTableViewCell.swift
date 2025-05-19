//class AddressManagementTableViewCell: BaseTableViewCell {
//
//    var nicknameLabel = UILabel.with(textColor: .qu_black, fontSize: 32)
//
//    var phoneLabel = UILabel.with(textColor: .qu_black, fontSize: 32)
//
//    var addressLabel = UILabel.with(textColor: .qu_black, fontSize: 24)
//
//    let defaultButton = UIButton()
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.contentView.backgroundColor = UIColor.viewBackgroundColor
//
//        let container = RoundedCornerView(corners: .allCorners, radius: 4)
//        self.contentView.addSubview(container)
//        container.snp.makeConstraints { make in
//            make.left.equalTo(self.contentView).offset(8)
//            make.right.equalTo(self.contentView).offset(-8)
//            make.bottom.equalTo(self.contentView)
//            make.top.equalTo(self.contentView).offset(12)
//        }
//
//        let view = UIView()
//        container.addSubview(view)
//        view.snp.makeConstraints { make in
//            make.top.equalTo(container).offset(24)
//            make.bottom.equalTo(container).offset(-24)
//            make.left.right.equalToSuperview()
//        }
//
//        view.addSubview(nicknameLabel)
//        nicknameLabel.snp.makeConstraints { make in
//            make.top.equalTo(view)
//            make.left.equalTo(view).offset(12)
//            make.width.equalTo(105)
//        }
//
//        view.addSubview(defaultButton)
//        defaultButton.snp.makeConstraints { make in
//            make.centerY.equalTo(view)
//            make.right.equalTo(view).offset(-12)
//            make.size.equalTo(25)
//        }
//
//        view.addSubview(phoneLabel)
//        phoneLabel.snp.makeConstraints { make in
//            make.centerY.equalTo(nicknameLabel)
//            make.left.equalTo(nicknameLabel.snp.right)
//            make.right.equalTo(defaultButton.snp.left)
//        }
//
//        view.addSubview(addressLabel)
//        addressLabel.numberOfLines = 0
//        addressLabel.preferredMaxLayoutWidth = Constants.kScreenWidth - 56
//        addressLabel.snp.makeConstraints { make in
//            make.bottom.equalTo(view)
//            make.left.equalTo(view).offset(12)
//            make.right.equalTo(defaultButton.snp.left).offset(-12)
//            make.top.equalTo(nicknameLabel.snp.bottom).offset(5)
//        }
//    }
//
//    required public init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func configureWith(address: DeliveryAddress, isSelected: Bool) {
//        self.nicknameLabel.text = address.name
//        self.phoneLabel.text = address.phone
//        self.addressLabel.text = address.address
//        self.addressLabel.setLineSpacing(lineHeightMultiple: 1.5)
//        self.defaultButton.setImage(isSelected ? UIImage(named: "login_selected") : UIImage(named: "login_unselect"), for: .normal)
//    }
//}
