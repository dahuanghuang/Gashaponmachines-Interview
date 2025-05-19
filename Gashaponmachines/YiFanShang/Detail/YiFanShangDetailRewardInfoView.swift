/import UIKit

class YiFanShangDetailRewardInfoView: UIView {

    init(awardInfos: [AwardInfo], totalCount: String) {
        super.init(frame: .zero)

        let count = awardInfos.count

        // 头部
        let icon = UIImageView.with(imageName: "yfs_reward_logo")
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.centerX.width.equalToSuperview()
            make.height.equalTo(55)
            make.width.equalTo(78)
        }

        // 赏
        let container = UIView.withBackgounrdColor(.clear)
        container.layer.cornerRadius = 8
        container.layer.masksToBounds = true
        addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(-14)
            make.left.bottom.right.equalToSuperview()
        }

        for idx in 0..<count {
            let awardInfo = awardInfos[idx]
            let imgName = idx == 0 ? "yfs_detail_reward_first_bg" : "yfs_detail_reward_not_first_bg"
            
            let bgIv = UIImageView(image: UIImage(named: imgName))
            container.addSubview(bgIv)
            bgIv.snp.makeConstraints { make in
                make.top.equalTo(idx * 28)
                make.height.equalTo(28)
                make.left.right.equalToSuperview()
            }
            
            let eggIcon = UIImageView()
            eggIcon.gas_setImageWithURL(awardInfo.eggIcon)
            bgIv.addSubview(eggIcon)
            eggIcon.snp.makeConstraints { make in
                make.left.equalTo(3)
                make.centerY.equalToSuperview()
                make.size.equalTo(24)
            }
            
            let totalLb = UILabel.numberFont(size: 12)
            totalLb.textColor = .new_yellow.alpha(0.4)
            totalLb.text = "/\(totalCount)"
            bgIv.addSubview(totalLb)
            totalLb.snp.makeConstraints { make in
                make.right.equalTo(-14)
                make.bottom.equalTo(-5)
            }

            let countLb = UILabel.numberFont(size: 20)
            countLb.textColor = .new_yellow
            countLb.text = awardInfo.eggCount
            bgIv.addSubview(countLb)
            countLb.snp.makeConstraints { make in
                make.right.equalTo(totalLb.snp.left)
                make.bottom.equalTo(-2)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
