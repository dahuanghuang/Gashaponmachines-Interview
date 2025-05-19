import UIKit

class ConfirmDeliveryAddressFooterView: UIView {

    func calculateHeight() -> CGFloat {
        return 12 + 44 * 3
    }

    /// 价格
    let priceLabel = UILabel.with(textColor: UIColor.qu_black, boldFontSize: 24)

    /// 商品个数
    let itemCountLabel = UILabel.with(textColor: UIColor.qu_black, boldFontSize: 24)

    /// 可用优惠券
    let couponValueLabel = UILabel.with(textColor: UIColor.qu_black, fontSize: 24)

    let couponButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .clear
        
        let contentView = UIView.withBackgounrdColor(.white)
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.top.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalToSuperview()
        }

        // 价格区域
        let priceArea = UIView.withBackgounrdColor(.clear)
        contentView.addSubview(priceArea)
        priceArea.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }

        let priceDesLabel = UILabel.with(textColor: .black, fontSize: 28, defaultText: "运费")
        priceArea.addSubview(priceDesLabel)
        priceDesLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(8)
        }

        priceArea.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-8)
        }

        // 商品个数区域
        let countArea = UIView.withBackgounrdColor(.clear)
        contentView.addSubview(countArea)
        countArea.snp.makeConstraints { make in
            make.top.equalTo(priceArea.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }

        let itemLabel = UILabel.with(textColor: .black, fontSize: 28, defaultText: "商品")
        countArea.addSubview(itemLabel)
        itemLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(8)
        }

        countArea.addSubview(itemCountLabel)
        itemCountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-8)
        }

        // 优惠券
        let couponArea = UIView.withBackgounrdColor(.white)
        contentView.addSubview(couponArea)
        couponArea.snp.makeConstraints { make in
            make.top.equalTo(countArea.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }

        let couponLabel = UILabel.with(textColor: .black, fontSize: 28, defaultText: "优惠券")
        couponArea.addSubview(couponLabel)
        couponLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(8)
        }

        let arrowIv = UIImageView(image: UIImage(named: "delivery_arrow"))
        couponArea.addSubview(arrowIv)
        arrowIv.snp.makeConstraints { make in
            make.centerY.equalTo(couponLabel)
            make.right.equalToSuperview().offset(-8)
        }

        couponArea.addSubview(couponValueLabel)
        couponValueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(couponLabel)
            make.right.equalTo(arrowIv.snp.left).offset(-4)
        }

        couponArea.addSubview(couponButton)
        couponButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func configure(env: ShipInfoEnvelope, style: ConfirmDeliveryStyle, count: Int) {
        self.priceLabel.text = env.expressFee
        if style == .eggProduct {
            self.itemCountLabel.text = "共 \(env.products.count) 件"
        } else {
            self.itemCountLabel.text = "共 \(count) 件"
        }

    }

    /// 改变优惠券值
    /// - Parameters:
    ///   - coupon: 当前使用的优惠券
    ///   - couponCount: 可用优惠券个数
    func changeCouponValue(coupon: Coupon?, couponCount: Int) {

        couponButton.isEnabled = couponCount == 0 ? false : true

        couponValueLabel.text = couponCount == 0 ? "无可用优惠券" : "\(couponCount)张可用"

        couponValueLabel.textColor = couponCount == 0 ? .qu_black : UIColor(hex: "fd4152")

        if let selectCoupon = coupon {
            let type = selectCoupon.type == "DK" ? "蛋壳" : "元气"
            couponValueLabel.text = "-\(selectCoupon.amount)\(type)"
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
