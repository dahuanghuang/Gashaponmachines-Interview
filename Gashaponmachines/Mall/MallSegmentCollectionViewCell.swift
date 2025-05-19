import Foundation
import RxCocoa
import RxSwift

fileprivate extension Reactive where Base: MallSegmentCollectionViewCell {
    var selectedState: Binder<Bool> {
        return Binder(self.base) { (view, state) -> Void in
            view.label.backgroundColor = state ? .qu_yellow : .qu_red
            view.label.textColor = state ? .qu_black : .white
        }
    }
}

class MallSegmentCollectionViewCell: UICollectionViewCell {

    fileprivate lazy var label: InsetLabel = {
        let label = InsetLabel()
        label.textColor = .white
        label.font = UIFont.withBoldPixel(28)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.backgroundColor = .qu_red
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.height.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(to selectedCollection: Observable<String>, as item: MallCollection) {
        label.text = item.title
        selectedCollection.map { $0 == item.mallCollectionId }
            .bind(to: self.rx.selectedState)
            .disposed(by: self.rx.reuseBag)
    }
}

import UIKit

private class InsetLabel: UILabel {

    var contentInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: contentInsets)
        super.drawText(in: insetRect)
    }

    override var intrinsicContentSize: CGSize {
        return addInsets(to: super.intrinsicContentSize)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return addInsets(to: super.sizeThatFits(size))
    }

    private func addInsets(to size: CGSize) -> CGSize {
        let width = size.width + contentInsets.left + contentInsets.right
        let height = size.height + contentInsets.top + contentInsets.bottom
        return CGSize(width: width, height: height)
    }

}
