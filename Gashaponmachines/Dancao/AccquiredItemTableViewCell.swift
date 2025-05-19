import UIKit

let AccquiredItemCollectionViewCellId = "AccquiredItemCollectionViewCellId"

class AccquiredItemCollectionViewCell: UICollectionViewCell {
    
    /// 向下取整, 防止Pro Max屏幕宽度除不尽, 导致只显示两个
    static let cellWH = floor((Constants.kScreenWidth - 48)/3)
    
    /// 商品图
    lazy var productIv: UIImageView = {
        let iv = UIImageView()
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 6
        return iv
    }()
    
    /// 提示视图
    lazy var remainView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "fd4152", alpha: 0.8)
        view.isHidden = true
        return view
    }()
    
    /// 提示文字
    lazy var remainLb: UILabel = {
        let lb = UILabel.with(textColor: .white, fontSize: 20)
        lb.textAlignment = .center
        return lb
    }()
    
    /// 锁视图
    lazy var lockView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "e8b600", alpha: 0.8)
        view.isHidden = true
        return view
    }()
    
    /// 锁
    lazy var lockIv: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "egg_lock"))
        iv.isHidden = true
        return iv
    }()
    
    /// 蛋背景
    let eggBgView = RoundedCornerView(corners: [.topLeft, .bottomRight], radius: 5, backgroundColor: .white)
    
    /// 蛋
    let icon = UIImageView()
    
    /// 集集乐商品个数小红点
    lazy var badgeLabel: UILabel = {
        let lb = UILabel.with(textColor: .white, boldFontSize: 24)
        lb.textAlignment = .center
        lb.backgroundColor = .red
        lb.clipsToBounds = true
        lb.layer.cornerRadius = 11
        lb.isHidden = true
        lb.layer.borderColor = UIColor(hex: "e8b600")?.cgColor
        lb.layer.borderWidth = 2
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(productIv)
        productIv.snp.makeConstraints { make in
            make.top.left.equalTo(2)
            make.right.bottom.equalTo(-2)
        }

        productIv.addSubview(remainView)
        remainView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(20)
        }
        
        remainView.addSubview(remainLb)
        remainLb.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        productIv.addSubview(lockView)
        lockView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        lockView.addSubview(lockIv)
        lockIv.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(58)
            make.height.equalTo(15)
        }
        
        productIv.addSubview(eggBgView)
        eggBgView.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.size.equalTo(26)
        }
        
        eggBgView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.size.equalTo(15)
            make.center.equalToSuperview()
        }

        self.addSubview(badgeLabel)
        badgeLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(productIv.snp.right)
            make.centerY.equalTo(productIv.snp.top)
            make.width.equalTo(0)
            make.height.equalTo(22)
        }
    }
    
    func configureWith(product: EggProduct, type: EggProductType, selectProduct: EggProduct?) {
        
        cleanData()
        
        productIv.gas_setImageWithURL(product.image)
        
        if let needWarning = product.needWarning {
            remainView.isHidden = !needWarning
            remainLb.text = product.bottomTips
            
            if let isLock = product.isLocked,  isLock != "0" { // 元气赏锁定时, 不显示提示
                remainView.isHidden  = true
            }
        }
        
        if let isLock = product.isLocked {
            lockView.isHidden = (isLock == "0")
            lockIv.isHidden =  (isLock == "0")
        }
        
        icon.gas_setImageWithURL(product.icon)
        
        if let sProduct = selectProduct, sProduct.randomId == product.randomId {
            eggBgView.backgroundColor = .new_green
            contentView.backgroundColor = .new_green
        }else {
            eggBgView.backgroundColor = .white
            contentView.backgroundColor = .white
        }
        
        if type == .pieceEgg {
            if let count = product.productCount {
                badgeLabel.isHidden = false
                let textWidth = String(count).widthOfString(usingFont: UIFont.boldSystemFont(ofSize: 12))
                let width = count < 10 ? 22 : textWidth + 22
                badgeLabel.text = String(count)
                badgeLabel.snp.updateConstraints { (make) in
                    make.width.equalTo(width)
                }
            }
        } else {
            badgeLabel.isHidden = true
        }
    }
    
    private func cleanData() {
        productIv.image = nil
        remainView.isHidden = true
        remainLb.text = ""
        lockView.isHidden = true
        lockIv.isHidden = true
        icon.image = nil
        contentView.backgroundColor = .white
        badgeLabel.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
