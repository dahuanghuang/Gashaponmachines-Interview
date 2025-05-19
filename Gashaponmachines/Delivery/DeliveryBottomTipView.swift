import RxSwift
import RxCocoa

extension Reactive where Base: DeliveryBottomTipView {

    var shipInfo: Binder<(money: Int, shipInfo: EggProductListEnvelope.ShipInfo?)> {
        return Binder(self.base) { (view, pair) -> Void in
            if let freeShipPrice = pair.shipInfo?.freeShipPrice, let freeShipTitle = pair.shipInfo?.freeShipTitle, let chargeShipTitle = pair.shipInfo?.chargeShipTitle {
                if pair.money <= freeShipPrice {
                    view.backgroundColor = .qu_lightYellow
                    view.label.text = chargeShipTitle
                } else {
                    view.backgroundColor = .white
                    view.label.text = freeShipTitle
                }
            }
        }
    }
}

class DeliveryBottomTipView: UIView {

    let label: UILabel = {
        let label = UILabel .with(textColor: .qu_orange, fontSize: 24)
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)

        self.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
