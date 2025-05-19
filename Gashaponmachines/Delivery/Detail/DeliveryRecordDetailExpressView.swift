import UIKit

class DeliveryRecordDetailExpressView: UIView {

    let iv = UIImageView(image: UIImage(named: "delivery_express"))
    lazy var expressNumLabel = UILabel.with(textColor: .black, boldFontSize: 28)
    lazy var copyButton: UIButton = {
        let button = UIButton.whiteBackgroundYellowRoundedButton(title: "复制", boldFontSize: 20, titleColor: .UIColorFromRGB(0xD29F26))
        button.addTarget(self, action: #selector(copyDeliveryOrder), for: .touchUpInside)
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1
        return button
    }()
    /// 快递编号
    var expressNumber: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        self.addSubview(iv)
        self.addSubview(expressNumLabel)
        self.addSubview(copyButton)
    }
    
    func config(envelope: ShipDetailEnvelope) {
        expressNumber = envelope.expressNumber ?? ""
        expressNumLabel.text = envelope.shipmentSubtitle
        
        if envelope.status == .delivered || envelope.status == .received {
            copyButton.isHidden = false
        } else {
            copyButton.isHidden = true
        }
    }
    
    @objc func copyDeliveryOrder() {
        UIPasteboard.general.string = self.expressNumber
        let center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2)
        self.getViewController()?.view.makeToast("复制成功", point: center, title: nil, image: nil, completion: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.roundCorners([.topLeft, .topRight], radius: 12)
        
        iv.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }

        expressNumLabel.snp.makeConstraints { make in
            make.left.equalTo(iv.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        
        copyButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-12)
            make.size.equalTo(CGSize(width: 44, height: 18))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
