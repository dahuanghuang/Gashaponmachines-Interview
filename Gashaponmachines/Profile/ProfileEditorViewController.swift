import UIKit

class ProfileEditorViewController: BaseViewController {

    var circleImageView: UIImageView = {
       	let iv = UIImageView()
        iv.layer.cornerRadius = 30
        iv.layer.masksToBounds = true
        iv.backgroundColor = UIColor.UIColorFromRGB(0xd6d6d6)
        return iv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "个人资料"

        self.view.addSubview(circleImageView)
        circleImageView.snp.makeConstraints { make in
            make.size.equalTo(60)
            make.top.equalTo(self.view).offset(30)
            make.centerX.equalTo(self.view)
        }

        let label = UILabel.with(textColor: UIColor.qu_lightGray, fontSize: 26, defaultText: "上传头像")
        self.view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(circleImageView.snp.bottom).offset(15)
            make.centerX.equalTo(self.view)
        }

        let line = UIView.seperatorLine()
        self.view.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalTo(self.view).offset(15)
            make.right.equalTo(self.view).offset(-15)
            make.height.equalTo(0.5)
            make.top.equalTo(label.snp.bottom).offset(30)
        }
    }
}
