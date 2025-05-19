import UIKit
import RxSwift
import RxCocoa
import SnapKit

// 充值视图宽高
let RechargeHeaderViewOptionButtonHeight: CGFloat = 100
let RechargeHeaderViewOptionButtonWidth: CGFloat = (Constants.kScreenWidth - 36) / 2

class RechargeOptionButton: UIImageView {

    var isSelected: Bool = false {
        didSet {
            if isSelected {
                self.backgroundColor = UIColor(hex: "FFDA60")
                self.topContainer.backgroundColor = .new_bgYellow
                self.bottomContainer.backgroundColor = .new_bgYellow
                self.titleLbl.textColor = UIColor(hex: "9A4312")
                self.priceLabel.textColor = .black
            }else {
                self.backgroundColor = UIColor(hex: "FFF7C6")
                self.topContainer.backgroundColor = .white
                self.bottomContainer.backgroundColor = .white.alpha(0.6)
                self.titleLbl.textColor = UIColor(hex: "D29F26")
                self.priceLabel.textColor = UIColor(hex: "9A4312")
            }
        }
    }

    let icon = UIImageView()

    let fakeButton = PassableUIButton()
    
    let topContainer = RoundedCornerView(corners: [.topLeft, .topRight], radius: 6, backgroundColor: .white)
    
    let bottomContainer = RoundedCornerView(corners: [.bottomLeft, .bottomRight], radius: 6, backgroundColor: .white.alpha(0.6))
    
    let titleLbl = UILabel.with(textColor: UIColor(hex: "D29F26")!, boldFontSize: 26)
    
    let priceLabel = UILabel.with(textColor: UIColor(hex: "9A4312")!, boldFontSize: 32)

    init(frame: CGRect, paymentPlan: PaymentPlan) {
        super.init(frame: frame)

        self.isUserInteractionEnabled = true
		self.backgroundColor = UIColor(hex: "FFF7C6")
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true

        self.addSubview(topContainer)
        topContainer.snp.makeConstraints { (make) in
            make.top.left.equalTo(2)
            make.right.equalTo(-2)
            make.height.equalTo(58)
        }

        icon.gas_setImageWithURL(paymentPlan.planIcon)
        topContainer.addSubview(icon)
        icon.contentMode = .scaleAspectFit
        icon.snp.makeConstraints { make in
            make.top.equalTo(4)
            make.left.equalToSuperview()
            make.size.equalTo(50)
        }

        titleLbl.text = paymentPlan.title
        topContainer.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right)
            if paymentPlan.description.isEmpty {
                make.top.equalTo(icon).offset(16)
            }else {
                make.top.equalTo(icon).offset(8)
            }
        }

        let subTitleLbl = UILabel.with(textColor: .qu_lightGray, boldFontSize: 20)
        var attrStr = NSMutableAttributedString(string: "")
        if let data = paymentPlan.description.data(using: .unicode), paymentPlan.description != "" {
            do {
                attrStr = try NSMutableAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
                if attrStr.string.count > 0 {
                    attrStr.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)], range: NSRange(location: 0, length: attrStr.string.count))
                }
                subTitleLbl.attributedText = attrStr
            } catch {
                QLog.error("富文本解析错误: \(error.localizedDescription)")
            }
        }
        topContainer.addSubview(subTitleLbl)
        subTitleLbl.snp.makeConstraints { make in
            make.left.equalTo(titleLbl)
            make.top.equalTo(titleLbl.snp.bottom).offset(4)
        }
        
        if let tipInfo = paymentPlan.tipInfo {
            let titleLabelW = tipInfo.text.sizeOfString(usingFont: UIFont.systemFont(ofSize: 8)).width + 8
            let desLabel = UILabel.with(textColor: .white, fontSize: 16)
            desLabel.frame = CGRect(x: frame.width - titleLabelW, y: 0, width: titleLabelW, height: 12)
            desLabel.textAlignment = .center
            desLabel.backgroundColor = UIColor(hex: tipInfo.color) ?? UIColor(hex: "32cf9d")!
            desLabel.text = tipInfo.text
            desLabel.roundCorners([.bottomLeft], radius: 8)
            self.addSubview(desLabel)
        }

        self.addSubview(bottomContainer)
        bottomContainer.snp.makeConstraints { (make) in
            make.top.equalTo(topContainer.snp.bottom).offset(2)
            make.left.equalTo(2)
            make.right.bottom.equalTo(-2)
        }

        
        priceLabel.text = "¥\(paymentPlan.amount)"
        bottomContainer.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

		fakeButton.params["amount"] = paymentPlan.amount
        self.addSubview(fakeButton)
        fakeButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    deinit {
        self.icon.cancelNetworkImageDownloadTask()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
