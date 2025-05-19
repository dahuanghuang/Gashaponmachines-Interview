import Foundation

class YiFanShangRuleCell: BaseTableViewCell {

    lazy var iv = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.backgroundColor = .white
        contentView.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo((Constants.kScreenWidth - 40) * 0.6)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWith(imageURL: String) {
        iv.gas_setImageWithURL(imageURL)
    }
}
