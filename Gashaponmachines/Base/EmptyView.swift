import UIKit

enum EmptyViewType {
    case yfs        // 一番赏
    case myYfs      // 我的一番赏
    case yfsLive    // 一番赏直播页
    case home       // 首页
}

class EmptyView: UIView {

    var type: EmptyViewType {
        didSet {
            self.iv.image = self.getImage(with: type )
            self.titleLabel.text = self.getText(with: type )
        }
    }

    private let iv = UIImageView()
    private let titleLabel = UILabel.with(textColor: .qu_lightGray, fontSize: 28, defaultText: "")

    init(type: EmptyViewType) {
        self.type = type
        super.init(frame: .zero)

        self.backgroundColor = .clear

        iv.image = self.getImage(with: type)
        addSubview(iv)
        iv.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(148)
        }

        titleLabel.text = getText(with: type)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iv.snp.bottom)
        }
    }

    func getImage(with type: EmptyViewType) -> UIImage {
        switch type {
        case .yfsLive:
            return UIImage(named: "emptyState_dancao")!
        case .yfs:
            return UIImage(named: "yfs_list_empty")!
        case .myYfs:
            return UIImage(named: "my_yfs_list_empty")!
        case .home:
            return UIImage(named: "emptyState_home")!
        }
    }

    func getText(with type: EmptyViewType) -> String {
        switch type {
        case .yfsLive:
            return "暂未开始或没有记录哦！"
        case .yfs:
            return "元气赏还没有开始哦"
        case .myYfs:
            return "参与过的元气赏会出现在这里"
        case .home:
            return "没有机台数据哦!"
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
