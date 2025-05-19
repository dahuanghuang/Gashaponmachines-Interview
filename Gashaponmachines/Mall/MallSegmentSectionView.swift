import UIKit

class MallSegmentSectionView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
		self.backgroundColor = .qu_red
        let header = RoundedCornerView(corners: [.topLeft, .topRight], radius: 8)
        self.addSubview(header)
        header.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        let indicator = UIView.withBackgounrdColor(.qu_red)
        header.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.left.equalTo(12)
            make.width.equalTo(4)
            make.bottom.equalTo(-16)
        }

        let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: "蛋壳兑换")
        header.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(indicator)
            make.left.equalTo(indicator.snp.right).offset(8)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
