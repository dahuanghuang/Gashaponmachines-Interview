import UIKit

let YiFanShangMagicCellId = "YiFanShangMagicCellId"

class YiFanShangMagicCell: UICollectionViewCell {

    let bgIv = UIImageView()

    
    lazy var numberLb: UILabel = {
        let lb = UILabel.numberFont(size: 20)
        lb.textColor = .new_lightGray
        return lb
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .white

        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.new_backgroundColor.cgColor

        contentView.addSubview(bgIv)
        bgIv.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        contentView.addSubview(numberLb)
        numberLb.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }

    func config(number: String, canBuy: Bool, isSelect: Bool) {

        clean()

        if canBuy {
            if isSelect {
                bgIv.image = UIImage(named: "yfs_magic_select")
                self.layer.borderWidth = 0
                numberLb.textColor = .white
            } else {
                bgIv.image = nil
                self.layer.borderWidth = 2
                numberLb.textColor = .new_lightGray
            }
        } else {
            bgIv.image = UIImage(named: "yfs_magic_unable")
            self.layer.borderWidth = 0
            numberLb.textColor = .new_middleGray
        }

        numberLb.text = number
    }

    func clean() {
        bgIv.image = nil
        numberLb.text = ""
        numberLb.textColor = .new_lightGray
        self.layer.borderWidth = 2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
