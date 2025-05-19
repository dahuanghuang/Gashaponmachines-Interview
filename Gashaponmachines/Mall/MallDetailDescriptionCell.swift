
class MallDetailDescriptionCell: BaseTableViewCell {
    
    static let CellW: CGFloat = Constants.kScreenWidth - 24
    static let CellH: CGFloat = CellW * 0.6
    
    let iv = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .new_backgroundColor

        self.addSubview(iv)
    }
    
    func configureWith(image: String) {
        self.iv.image = nil
        self.iv.gas_setImageWithURL(image)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // 此处用snp自动布局, iv和cell之间会出现高度(CellH)计算上的精度差
        iv.frame = CGRect(x: 12, y: 0, width: Self.CellW, height: Self.CellH)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
