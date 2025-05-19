import AudioToolbox

class YiFanShangLivestreamInfoPlayingView: UIView {

    /// 第几回合
    lazy var roundLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)
    /// 头像
    lazy var avatar = UIImageView()
    /// 头像框
    lazy var avatarFrame = UIImageView()
    /// 昵称
    lazy var nameLabel = UILabel.with(textColor: .qu_black, fontSize: 28)
    /// 赏图片(默认是?)
    lazy var numberImageView = UIImageView()

    // 是否动画结束了
    var isAnimationEnd: Bool = true

    var record: YiFanShangLiveStreamRecord? {
        didSet {
            nameLabel.text = record?.nickname ?? ""

            avatar.gas_setImageWithURL(record?.avatar)

            avatarFrame.gas_setImageWithURL(record?.avatarFrame)

            if let num = record?.number {
                roundLabel.text = "第\(num)回"
            }

            numberImageView.image = UIImage(named: "yfs_reward_0_outline")
        }
    }

    /// 隐藏回调
    var hideCallback: (() -> Void)?

    /// 更新开赏视图
    func updateInfoPlayingView(centerNotice: YiFanShangLivestreamInfo.CenterNotice?, awardImageUrl: String?) {
        if !self.isAnimationEnd { return }
        self.isAnimationEnd = false
        UIView.animate(withDuration: 0.15, animations: { // 缩小动画
            self.numberImageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }, completion: { finished in // 放大
            self.setupModel(centerNotice: centerNotice, awardImageUrl: awardImageUrl)
            self.scaleAnimation()
        })
    }

    /// 设置数据
    func setupModel(centerNotice: YiFanShangLivestreamInfo.CenterNotice?, awardImageUrl: String?) {
        nameLabel.text = centerNotice?.nickname ?? ""
        avatar.gas_setImageWithURL(centerNotice?.avatar)
        if let num = centerNotice?.number {
            roundLabel.text = "第\(num)回"
        }

        if let imageUrl = awardImageUrl { // 更新赏图片
            numberImageView.gas_setImageWithURL(imageUrl)
        } else { // 未开赏, 显示?号
            numberImageView.image = UIImage(named: "yfs_reward_0")
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .clear

        let contentView = RoundedCornerView(corners: [.topLeft, .topRight], radius: 12, backgroundColor: .white)
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.left.equalTo(4)
            make.right.bottom.equalToSuperview()
        }

        let yellowBg = RoundedCornerView(corners: [.bottomRight, .topRight], radius: 14, backgroundColor: .qu_yellow)
        self.addSubview(yellowBg)
        yellowBg.snp.makeConstraints { make in
            make.height.equalTo(28)
            make.width.equalTo(73)
            make.centerY.equalTo(contentView)
            make.left.equalToSuperview()
        }

        yellowBg.addSubview(roundLabel)
        roundLabel.textAlignment = .left
        roundLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(18)
        }

        avatar.layer.cornerRadius = 16
        avatar.layer.masksToBounds = true
        contentView.addSubview(avatar)
        avatar.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.centerY.equalToSuperview()
            make.left.equalTo(yellowBg.snp.right).offset(12)
        }

        contentView.addSubview(avatarFrame)
        avatarFrame.snp.makeConstraints { make in
            make.edges.equalTo(avatar)
        }

        addSubview(numberImageView)
        numberImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.width.equalTo(60)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-8)
        }

        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(avatar.snp.right).offset(8)
            make.right.equalTo(numberImageView.snp.left).offset(-24)
        }

        let view = UIView.seperatorLine()
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.height.equalTo(28)
            make.width.equalTo(0.5)
            make.centerY.equalToSuperview()
            make.right.equalTo(numberImageView.snp.left).offset(-12)
        }
    }

    /// 缩放动画
    func scaleAnimation() {
        UIView.animate(withDuration: 0.15, animations: {
            self.numberImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { [weak self] finished in

            UIView.animate(withDuration: 0.07, animations: {
                self?.numberImageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { finished in
                UIView.animate(withDuration: 0.07, animations: {
                    self?.numberImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }, completion: { finished in
                    UIView.animate(withDuration: 0.07, animations: {
                        self?.numberImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }, completion: { finished in
                        self?.isAnimationEnd = true
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.9, execute: {
                            // 动画结束回调
                            if let callback = self?.hideCallback {
                                callback()
                            }
                        })

                    })
                })
            })

        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
