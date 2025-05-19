import UIKit

class CustomConfirmButton: UIButton {
    
    init(title: String, fontSize: CGFloat) {
        super.init(frame: .zero)
        
        self.backgroundColor = UIColor(hex: "FFDA60")
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        let cornerView = UIView.withBackgounrdColor(.white.alpha(0.2))
        cornerView.isUserInteractionEnabled = false
        cornerView.layer.cornerRadius = 4
        cornerView.layer.masksToBounds = true
        cornerView.layer.borderWidth = 1
        cornerView.layer.borderColor = UIColor.new_yellow.cgColor
        self.addSubview(cornerView)
        cornerView.snp.makeConstraints { make in
            make.top.left.equalTo(4)
            make.right.bottom.equalTo(-4)
        }
        
        let titleLb = UILabel.with(textColor: UIColor(hex: "754E00")!, boldFontSize: fontSize, defaultText: title)
        self.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
