import UIKit

class GameNewTipView: UIView {

    let tipLb = UILabel.with(textColor: .qu_darkGray, fontSize: 24)

    override init(frame: CGRect) {
        super.init(frame: .zero)

        self.isHidden = true

        self.layer.cornerRadius = 10
        self.backgroundColor = .white

        let tipIv = UIImageView(image: UIImage(named: "game_bubble"))
        addSubview(tipIv)
        tipIv.snp.makeConstraints { (make) in
            make.left.top.equalTo(10)
            make.size.equalTo(14)
        }

        let tipDescLb = UILabel.with(textColor: .qu_black, boldFontSize: 24, defaultText: "元气充能站")
        addSubview(tipDescLb)
        tipDescLb.snp.makeConstraints { (make) in
            make.left.equalTo(tipIv.snp.right).offset(6)
            make.centerY.equalTo(tipIv)
        }

        tipLb.numberOfLines = 0
        addSubview(tipLb)
        tipLb.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(tipIv.snp.bottom).offset(8)
            make.bottom.equalTo(-10)
        }

        let whiteView = UIView.withBackgounrdColor(.white)
        addSubview(whiteView)
        whiteView.snp.makeConstraints { (make) in
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(10)
        }
    }

    func updateText(_ text: String?) {
        if let t = text, t != "" {
            self.isHidden = false
            tipLb.text = text
            self.layoutIfNeeded()
        } else {
            self.isHidden = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
