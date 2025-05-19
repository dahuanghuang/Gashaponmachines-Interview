import RxSwift
import RxCocoa
import UIKit
import RxSwiftExt

private typealias ExchangeCollectionViewCellSelectionState = (isSelected: Bool, selectedCount: Int)

fileprivate extension Reactive where Base: ExchangeCollectionViewCell {
    var selectedState: Binder<ExchangeCollectionViewCellSelectionState> {
        return Binder(self.base) { (view, state) -> Void in
            view.button.isHidden = !state.isSelected
            view.selectedMask.isHidden = !state.isSelected
            let allStr = "共 \(state.selectedCount) 个"
            let string = NSMutableAttributedString(string: allStr)
            string.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.qu_orange], range: (allStr as NSString).range(of: "\(state.selectedCount)"))
            if state.isSelected {
                view.countLabel.attributedText = string
            } else {
                view.countLabel.text = "待选中"
            }
        }
    }
}

class ExchangeCollectionViewCell: UICollectionViewCell {

    let icon = UIImageView()
    let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)
    let countLabel = UILabel.with(textColor: .qu_black, fontSize: 20)
    var egg: Egg?

    lazy var selectedMask: UIView = {
       	let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor(hex: "FFF7C6")
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.new_yellow.cgColor
        view.layer.borderWidth = 1
        view.isUserInteractionEnabled = true
        return view
    }()

    lazy var button: UIButton = {
       	let button = UIButton.with(title: "详情", titleColor: .black, boldFontSize: 24)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.backgroundColor = .new_yellow
        button.isHidden = true
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let containerView = RoundedCornerView(corners: .allCorners, radius: 12)
        self.contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.top.right.equalTo(self.contentView)
            make.bottom.equalTo(-12)
        }

        containerView.addSubview(selectedMask)
        selectedMask.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(8)
            make.centerX.equalTo(containerView)
        }
        
        containerView.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.centerX.equalTo(containerView)
        }

        containerView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(12)
            make.centerX.equalTo(containerView)
            make.size.equalTo(64)
        }
        
        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.centerX.equalTo(selectedMask)
            make.width.equalTo(80)
            make.height.equalTo(28)
            make.centerY.equalTo(selectedMask.snp.bottom)
        }
    }

    func configureWith(egg: Egg) {
        self.egg = egg
        self.icon.gas_setImageWithURL(egg.icon)
        self.titleLabel.text = egg.title
		self.countLabel.text = "待选中"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.icon.cancelNetworkImageDownloadTask()
    }

    /// 设置蛋选中的状态
    ///
    /// - Parameters:
    ///   - state: 展示蛋的状态(是否需要被选中)
    func bind(to state: Observable<[[EggProduct]?]>, as item: Egg, indexPath: IndexPath) {
        state
            .filter { $0.count > indexPath.row }
            .map {
                if let eggs = $0[indexPath.row] {
                    return (isSelected: true, selectedCount: eggs.count)
                } else {
                    return (isSelected: false, selectedCount: 0)
                }
            }
            .bind(to: self.rx.selectedState)
            .disposed(by: self.rx.reuseBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
