import UIKit
import Kingfisher

class HomeLoadingView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        let contentView = UIView.withBackgounrdColor(.white)
        self.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        let loadingIv = UIImageView()
        let path = Bundle.main.path(forResource: "home_loading", ofType: "gif")
//        loadingIv.kf.setImage(with: ImageResource(downloadURL: URL(fileURLWithPath: path!)))
        self.addSubview(loadingIv)
        loadingIv.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(80)
        }
    }
}
