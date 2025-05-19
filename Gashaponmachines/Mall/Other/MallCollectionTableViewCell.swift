extension MallCollectionTableViewCell {
    static let Width = (Constants.kScreenWidth - 16) / 2
    static let Height = Width + 12 + UIFont.heightOfPixel(28) + 8 + 15 + 16
}

enum CellPosition {
    case left
    case right
}

class MallCollectionTableViewCell: BaseTableViewCell {

    let leftView = MallTableViewCellView(position: .left)

    let rightView = MallTableViewCellView(position: .right)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(leftView)

        self.contentView.addSubview(rightView)

        leftView.snp.makeConstraints { make in
            make.top.left.bottom.equalTo(self.contentView)
            make.width.equalTo(MallCollectionTableViewCell.Width)
        }

        rightView.snp.makeConstraints { make in
            make.top.right.bottom.equalTo(self.contentView)
            make.width.equalTo(MallCollectionTableViewCell.Width)
        }
    }

    func configureWith(products: [MallProduct]) {
        if products.count == 1, let first = products.first {
            self.leftView.configureWith(product: first)
            self.rightView.configureWith(product: nil)
        } else if products.count == 2, let first = products.first, let last = products.last {
            self.leftView.configureWith(product: first)
            self.rightView.configureWith(product: last)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.leftView.reset()
        self.rightView.reset()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol MallTableViewCellViewDelegate: class {
    func switchToMallProductDetail(productId: String)
}

class MallTableViewCellView: UIView {

    weak var delegate: MallTableViewCellViewDelegate?

    private lazy var icon: UIImageView = UIImageView()

    private lazy var machineIcon = UIImageView()

    private lazy var titleLabel = UILabel.with(textColor: .qu_black, fontSize: 28)

    private lazy var statusIcon = UIImageView()

    private lazy var prizeLabel = UILabel.with(textColor: .qu_orange, boldFontSize: 24)

    private lazy var originPrizeLabel = UILabel.with(textColor: .qu_lightGray, fontSize: 20)

    private lazy var container = UIView.withBackgounrdColor(.white)

    private var product: MallProduct?

    private let shadowView = UIView.withBackgounrdColor(.clear)

    init(position: CellPosition) {
        super.init(frame: .zero)

        self.backgroundColor = .white

        self.addSubview(shadowView)
        shadowView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(position == .left ? 12 : 6)
            make.top.equalTo(self).offset(2)
            make.right.equalToSuperview().offset(position == .left ? -6 : -12)
            make.size.equalTo(MallCollectionTableViewCell.Width - 24)
        }

        container.layer.cornerRadius = 4
        container.layer.masksToBounds = true
        shadowView.addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        icon.clipsToBounds = true
        container.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.edges.equalTo(container)
        }

        icon.addSubview(machineIcon)
        machineIcon.snp.makeConstraints { make in
            make.left.bottom.equalTo(icon)
        }

        titleLabel.numberOfLines = 1
        titleLabel.preferredMaxLayoutWidth = MallCollectionTableViewCell.Width - 24
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(icon).offset(4)
            make.right.equalTo(icon).offset(-4)
            make.top.equalTo(icon.snp.bottom).offset(12)
            make.height.equalTo(UIFont.heightOfPixel(28))
        }

        self.addSubview(statusIcon)
        statusIcon.snp.makeConstraints { make in
            make.left.equalTo(titleLabel).offset(4)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.size.equalTo(15)
            make.bottom.equalTo(self).offset(-16)
        }

        self.addSubview(prizeLabel)
        prizeLabel.snp.makeConstraints { make in
            make.left.equalTo(statusIcon.snp.right).offset(4)
            make.centerY.equalTo(statusIcon)
        }

        container.addSubview(originPrizeLabel)
        originPrizeLabel.snp.makeConstraints { make in
            make.left.equalTo(prizeLabel.snp.right).offset(5)
            make.centerY.equalTo(prizeLabel)
            make.right.equalTo(titleLabel)
        }

        let button = UIButton()
        self.addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        button.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reset() {
        icon.cancelNetworkImageDownloadTask()
        machineIcon.image = nil
        prizeLabel.textColor = .qu_orange
        originPrizeLabel.text = nil

    }

    @objc func tapButton() {
        if let product = self.product, let id = product.productId {
            self.delegate?.switchToMallProductDetail(productId: id)
        }
    }

    func configureWith(product: MallProduct?) {
        self.product = product
        if let product = self.product {
            self.titleLabel.text = product.title
            self.prizeLabel.text = "蛋壳x\(product.worth)"
            self.icon.qu_setImageWithURL(URL(string: product.image)!)
            shadowView.addShadow(offset: CGSize(width: 0, height: 3), color: .black, radius: 4, opacity: 0.12)
            if let isOnDiscount = product.isOnDiscount, isOnDiscount == "1" {
                self.originPrizeLabel.addStrikeThroughLine(with: product.originalWorth)
                self.prizeLabel.textColor = .qu_red
                self.statusIcon.image = UIImage(named: "mall_onsale_egg")
                self.machineIcon.image = UIImage(named: "mall_onsale")
            } else {
                self.statusIcon.image = UIImage(named: "mall_egg")
            }
        } else {
            titleLabel.text = nil
            machineIcon.image = nil
            prizeLabel.text = nil
            statusIcon.image = nil
            shadowView.layer.shadowOpacity = 0
        }
    }
}
