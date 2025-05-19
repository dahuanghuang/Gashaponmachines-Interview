import UIKit
import SnapKit
import RxCocoa
import RxSwift

class ExchangeDetailTableHeaderView: UIView {

    let titleLabel = UILabel.with(textColor: .black, boldFontSize: 32)

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        roundCorners([.topLeft, .topRight], radius: 12)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .new_backgroundColor
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func updateTitle(title: String) {
        titleLabel.text = title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
