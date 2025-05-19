import UIKit

class HomeViewTitleCell: UICollectionViewCell {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .new_gray
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    let bgIv = UIImageView(image: UIImage(named: "home_title_bg"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        bgIv.isHidden = true
        contentView.addSubview(bgIv)
        bgIv.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.snp.centerY)
            make.width.equalTo(32)
            make.height.equalTo(18)
        }

        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, isSelect: Bool) {
        clean()
        
        label.text = title
        label.textColor = isSelect ? .qu_black : .new_gray
        bgIv.isHidden = !isSelect
    }
    
    func clean() {
        label.text = ""
        bgIv.isHidden = true
    }
}
