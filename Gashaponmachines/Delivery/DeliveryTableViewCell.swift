import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: DeliveryTableViewCell {
    var isSelected: Binder<Bool> {
        return Binder(self.base) { (view, isSelected) -> Void in
            view.isSelected = isSelected
            view.selectedIcon.image = isSelected ? UIImage(named: "login_selected") : UIImage(named: "login_unselect")
        }
    }
}

class DeliveryTableViewCell: BaseTableViewCell {
    /// 白色圆角背景
    lazy var whiteBgView: UIView = {
        let view = UIView.withBackgounrdColor(.white)
        view.layer.cornerRadius = 12
        return view
    }()
    /// 商品图
    let iv: UIImageView = UIImageView()
    /// 蛋颜色
    let icon: UIImageView = UIImageView()
    /// 商品名称
    let titleLabel: UILabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)
    /// 过期时间
    let expireLabel: UILabel = UILabel.with(textColor: .qu_lightGray, fontSize: 20)
    /// 价值
    lazy var valueLabel: UILabel = {
        let lb = UILabel.numberFont(size: 20)
        lb.textColor = .new_orange
        return lb
    }()
    /// 选中icon
    let selectedIcon: UIImageView = UIImageView()

    func bind(to state: Driver<Set<EggProduct>>, as item: EggProduct) {
        state.map { $0.contains(item) }
        .drive(self.rx.isSelected)
        .disposed(by: rx.reuseBag)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .new_backgroundColor
        
        contentView.addSubview(whiteBgView)
        whiteBgView.snp.makeConstraints { make in
            make.top.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalToSuperview()
        }

        whiteBgView.addSubview(selectedIcon)
        selectedIcon.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.size.equalTo(25)
            make.centerY.equalToSuperview()
        }

        iv.layer.cornerRadius = 8
        iv.layer.masksToBounds = true
        whiteBgView.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.left.equalTo(selectedIcon.snp.right).offset(12)
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
            make.width.equalTo(iv.snp.height)
        }

        iv.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.bottom.left.equalTo(iv)
            make.size.equalTo(20)
        }

        whiteBgView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iv).offset(4)
            make.left.equalTo(iv.snp.right).offset(8)
            make.right.equalTo(-12)
        }
        
        whiteBgView.addSubview(expireLabel)
        expireLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        whiteBgView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.bottom.equalTo(iv)
        }
        
        let dankeLabel = UILabel.with(textColor: .new_middleGray, fontSize: 28, defaultText: "蛋壳")
        whiteBgView.addSubview(dankeLabel)
        dankeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(valueLabel)
            make.left.equalTo(valueLabel.snp.right).offset(2)
        }
    }

    func configureWith(product: EggProduct) {
        titleLabel.text = product.title
        iv.gas_setImageWithURL(product.image)
        if let iconURLStr = product.icon {
            self.icon.gas_setImageWithURL(iconURLStr)
        }

        if let worth = product.worth {
            valueLabel.text = "\(worth)"
        }
        if var tips = product.tips {
            expireLabel.attributedText = tips.getEggExpiredAttrString()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iv.cancelNetworkImageDownloadTask()
        icon.cancelNetworkImageDownloadTask()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
