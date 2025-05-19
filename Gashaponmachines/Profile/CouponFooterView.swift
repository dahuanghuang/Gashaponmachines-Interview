import UIKit

class CouponFooterView: UIView {
   override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .clear

        let titleLabel = UILabel.with(textColor: .qu_lightGray, fontSize: 24, defaultText: "仅显示最近半年数据")
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
   }

   required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
}
