import UIKit

let YiFanShangDetailRewardInfoCellId = "YiFanShangDetailRewardInfoCellId"

class YiFanShangDetailRewardInfoCell: UICollectionViewCell {

    let productIv = UIImageView()
    
    let awardIv = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .new_backgroundColor
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        productIv.layer.cornerRadius = 6
        productIv.layer.masksToBounds = true
        self.addSubview(productIv)
        productIv.snp.makeConstraints { make in
            make.top.left.equalTo(2)
            make.right.bottom.equalTo(-2)
        }
        
        productIv.addSubview(awardIv)
        awardIv.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.size.equalTo(24)
        }
    }

    func config(awardInfo: AwardInfo, isSelect: Bool) {
        clean()
        
        productIv.gas_setImageWithURL(awardInfo.productImage)
        awardIv.gas_setImageWithURL(awardInfo.eggIcon)
        
        self.backgroundColor = isSelect ? .new_yellow : .new_backgroundColor
    }

    func clean() {
        self.backgroundColor = .new_backgroundColor
        self.productIv.image = nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
