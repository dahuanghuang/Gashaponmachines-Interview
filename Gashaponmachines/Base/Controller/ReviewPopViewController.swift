import UIKit

//  审核弹窗
class ReviewPopViewController: BaseViewController {

    fileprivate func setupView() {
        self.view.backgroundColor = .clear

        let blackView = UIView()
        blackView.backgroundColor = .qu_popBackgroundColor
        blackView.tag = 440
        self.view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        let image = UIImage(named: "review_description")!
        let height = ((Constants.kScreenWidth - 64) * image.size.height) / image.size.width
        let imageView = UIImageView(image: image)
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        blackView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.left.equalTo(32)
            make.right.equalTo(-32)
            make.centerY.equalToSuperview()
            make.height.equalTo(height)
        }

        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(normalDismiss), for: .touchUpInside)
        imageView.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(0.15)
            make.width.equalToSuperview().multipliedBy(0.6)
            make.bottom.centerX.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    @objc func normalDismiss() {
        self.dismiss(animated: true, completion: nil)
    }

}
