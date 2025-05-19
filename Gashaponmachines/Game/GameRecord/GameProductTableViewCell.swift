import UIKit

private let GameProductCollectionViewCellReuseIdentifier = "GameProductCollectionViewCellReuseIdentifier"
let GameProductCollectionViewCellSize: CGFloat = 152 / 2

protocol GameProductTableViewCellDelegate: class {
    func didTappedProduct(product: Product)
}

class GameProductTableViewCell: BaseTableViewCell {
    func didSelectedImage() {
        if let product = self.product {
            self.delegate?.didTappedProduct(product: product)
        }
    }

    var images: [String] = [] {
        didSet {
            if images.isEmpty { return }
            
            cvContentWidth = CGFloat(16 + images.count * 100)
            yellowLine.snp.remakeConstraints { make in
                make.top.left.bottom.equalToSuperview()
                make.width.equalTo(yellowLineWidth)
            }
            self.collectionView.reloadData()
        }
    }

    var product: Product?

    weak var delegate: GameProductTableViewCellDelegate?

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 92, height: 92)
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 8, left: 12, bottom: 12, right: 12)
       	let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.bounces = false
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.register(GameProductCollectionViewCell.self, forCellWithReuseIdentifier: GameProductCollectionViewCellReuseIdentifier)
        return cv
    }()

    let icon = UIImageView()

    let titleLabel = UILabel.with(textColor: UIColor(hex: "9A4312")!, boldFontSize: 24)
    
    lazy var countLabel: UILabel = {
        let lb = UILabel.numberFont(size: 12)
        lb.textColor = UIColor(hex: "9A4312")!.alpha(0.78)
        return lb
    }()

    let subTitleLabel = UILabel.with(textColor: .new_middleGray, fontSize: 24)
    
    let yellowLine = UIView.withBackgounrdColor(.new_yellow)
    
    /// 灰色条宽度
    private let grayLineWidth = Constants.kScreenWidth - 48
    /// collectionView宽度
    private let cvWidth = Constants.kScreenWidth - 24
    /// collectionView总内容宽度
    private var cvContentWidth: CGFloat = 0
    /// 黄色条宽度
    private lazy var yellowLineWidth: CGFloat = {
        return (cvWidth/cvContentWidth) * grayLineWidth
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = .white
        contentView.backgroundColor = .white
        
        let containerView = RoundedCornerView(corners: .allCorners, radius: 12, backgroundColor: .new_backgroundColor.alpha(0.4))
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalToSuperview()
        }
        
        let topContainer = UIView.withBackgounrdColor(.clear)
        containerView.addSubview(topContainer)
        topContainer.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(52)
        }
        
        let circleView = RoundedCornerView(corners: .allCorners, radius: 16, backgroundColor: .new_yellow)
        topContainer.addSubview(circleView)
        circleView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(12)
            make.size.equalTo(32)
        }
        
        circleView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(28)
        }

        topContainer.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(icon.snp.right).offset(4)
        }
        
        topContainer.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right).offset(6)
        }
        
        let rectangleView = UIView.withBackgounrdColor(.new_yellow)
        topContainer.insertSubview(rectangleView, belowSubview: circleView)
        rectangleView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(circleView.snp.centerX)
            make.height.equalTo(24)
            make.right.equalTo(countLabel.snp.right).offset(1)
        }
        
        let tailIv = UIImageView(image: UIImage(named: "game_n_detail_tail"))
        topContainer.addSubview(tailIv)
        tailIv.snp.makeConstraints { make in
            make.left.equalTo(rectangleView.snp.right)
            make.centerY.equalToSuperview()
        }

        let indicatorIv = UIImageView(image: UIImage(named: "game_n_indicator"))
        topContainer.addSubview(indicatorIv)
        indicatorIv.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-12)
            make.size.equalTo(16)
        }
        
        topContainer.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(indicatorIv.snp.left).offset(-8)
        }
        
        let grayLine = UIView.withBackgounrdColor(.new_backgroundColor)
        topContainer.addSubview(grayLine)
        grayLine.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalToSuperview()
            make.height.equalTo(2)
        }
        
        grayLine.addSubview(yellowLine)

        containerView.addSubview(collectionView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        collectionView.addGestureRecognizer(tap)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(topContainer.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
    }

    func configureWith(product: Product) {
        
        clean()
        
        self.product = product
    	self.titleLabel.text = product.title
        self.countLabel.text = product.eggAmountTitle
        self.images = product.images ?? []
        self.icon.qu_setImageWithURL(URL(string: product.icon ?? "")!)
        self.subTitleLabel.text = product.subTitle
    }
    
    func clean() {
        titleLabel.text = ""
        images.removeAll()
        icon.image = nil
        subTitleLabel.text = ""
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.icon.cancelNetworkImageDownloadTask()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func tapGesture() {
        if let product = self.product {
            self.delegate?.didTappedProduct(product: product)
        }
    }
}

extension GameProductTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GameProductCollectionViewCellReuseIdentifier, for: indexPath) as! GameProductCollectionViewCell
        cell.imageKey = self.images[indexPath.row]
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x
        // 实际黄条移动值
        let realX = (contentOffsetX / (cvContentWidth - cvWidth)) * (grayLineWidth - yellowLineWidth)
        yellowLine.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(yellowLineWidth)
            make.left.equalTo(realX)
        }
    }
}

class GameProductCollectionViewCell: UICollectionViewCell {

    var imageKey: String? {
        didSet {
            if let key = imageKey {
                self.imageView.qu_setImageWithURL(URL(string: key)!)
            }
        }
    }

    var imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        self.contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.cancelNetworkImageDownloadTask()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
