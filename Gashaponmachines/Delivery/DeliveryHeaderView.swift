import UIKit
import SnapKit
import RxCocoa
import RxSwift

extension Reactive where Base: DeliveryHeaderView {
    var dropdownTap: ControlEvent<Void> {
        return self.base.button.rx.controlEvent(.touchUpInside)
    }
}

class DeliveryHeaderView: UIView {

    let button = UIButton.with(title: "全部", titleColor: .qu_black, fontSize: 28)

    var isShowDropView = false {
        didSet {
            self.arrow.image = self.isShowDropView ? UIImage(named: "gamerecord_arrow_down") : UIImage(named: "gamerecord_arrow_up")
        }
    }

    var arrow = UIImageView(image: UIImage(named: "gamerecord_arrow_up"))

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        roundCorners(.allCorners, radius: 4)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

		self.backgroundColor = .white
        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        addSubview(arrow)
        arrow.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.size.equalTo(15)
            make.centerX.equalTo(button.snp.centerX).offset(25)
        }
    }

    func updateTitle(title: String? = "全部") {
        button.setTitle(title, for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
