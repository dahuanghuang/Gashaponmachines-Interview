import UIKit

class DeliveryRecordDetailCopyAllView: UIView {

    var allPwd: String = ""

    init(cyberInfos: [ShipDetailEnvelope.CyberInfo]) {
        super.init(frame: .zero)
        
        self.backgroundColor = .white

        appendAllpwd(cyberInfos: cyberInfos)
        
        let titleLb = UILabel.with(textColor: .black, boldFontSize: 28, defaultText: "卡号与卡密")
        self.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(12)
        }

        let button = UIButton.with(title: "一键复制全部卡密", titleColor: .black, fontSize: 24)
        button.layer.cornerRadius = 6
        button.backgroundColor = .new_yellow
        button.addTarget(self, action: #selector(copyAll), for: .touchUpInside)
        addSubview(button)
        button.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-12)
            make.width.equalTo(125)
            make.height.equalTo(24)
        }
    }

    /// 拼接所有卡密
    func appendAllpwd(cyberInfos: [ShipDetailEnvelope.CyberInfo]) {
        for info in cyberInfos {
            if let num = info.cardNo {
                allPwd.append(num)
                allPwd.append(",")
            }
            if let pwd = info.cardPw {
                allPwd.append(pwd)
                allPwd.append(",")
            }
            if let code = info.cardCode {
                allPwd.append(code)
                allPwd.append(",")
            }
        }
        allPwd.removeLast()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func copyAll() {
        let paste = UIPasteboard.general
        paste.string = allPwd
        HUD.success(second: 1, text: "复制成功", completion: nil)
    }
}
