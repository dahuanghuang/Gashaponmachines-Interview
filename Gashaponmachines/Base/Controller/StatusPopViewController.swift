/import UIKit

class StatusPopViewController: BaseViewController {

    private let iconIv = UIImageView()

    private let titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 32)

    // 描述
    private var tip: String!
    // 图片
    private var imageName: String!

    init(tip: String, imageName: String) {
        super.init(nibName: nil, bundle: nil)

        self.tip = tip
        self.imageName = imageName

        setupView()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupView() {
        self.view.backgroundColor = .clear
        let blackView = UIView()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        blackView.addGestureRecognizer(gesture)
        blackView.backgroundColor = .qu_popBackgroundColor
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.center.equalTo(blackView)
        }

        iconIv.image = UIImage(named: imageName)
        contentView.addSubview(iconIv)
        iconIv.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.size.equalTo(50)
        }

        titleLabel.text = tip
        contentView.addSubview(titleLabel)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconIv.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(contentView.snp.bottom).offset(-20)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delay(3) {
            self.dismissVC()
        }
    }

    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}
