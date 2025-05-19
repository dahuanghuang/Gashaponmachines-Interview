import RxSwift
import RxCocoa

extension Reactive where Base: CollectionSelectionCell {
    var isSelected: Binder<Bool> {
        return Binder(self.base) { (view, isSelected) -> Void in
            view.isSelected = isSelected
            view.label.textColor = isSelected ? UIColor.qu_black : UIColor.UIColorFromRGB(0x3a3a3a, alpha: 0.4)
            view.selectedIndicator.image = isSelected ? UIImage(named: "login_selected") : UIImage(named: "login_unselect")
        }
    }
}

class CollectionSelectionCell: BaseTableViewCell {

    let label = UILabel.with(textColor: UIColor.UIColorFromRGB(0x3a3a3a, alpha: 0.4), fontSize: 28)

    let selectedIndicator = UIImageView(image: UIImage(named: "login_unselect"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(selectedIndicator)
        selectedIndicator.snp.makeConstraints { make in
            make.centerY.equalTo(self.contentView)
            make.size.equalTo(25)
            make.right.equalTo(self.contentView).offset(-12)
        }

        self.contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(12)
            make.right.equalTo(selectedIndicator.snp.left).offset(-24)
        }

        self.contentView.addBottomSeperatorLine()
    }

    func bind(to state: Driver<Set<EggProduct.Collection>>, as item: EggProduct.Collection) {
        state.map { $0.contains(item) }
            .drive(self.rx.isSelected)
            .disposed(by: rx.reuseBag)
    }

    func configureWith(collection: EggProduct.Collection) {
        self.label.text = collection.title
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
