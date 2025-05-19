import UIKit

let CouponTableViewCellId = "CouponTableViewCellId"

class CouponTableViewCell: UITableViewCell {

    static let cellHeight = (Constants.kScreenWidth/4 - 6) + 24 + 8 + 12

    /// 劵背景
    let bgView = UIView.withBackgounrdColor(.white)
    /// 选中图片
    let selectedIv = UIImageView(image: UIImage(named: "coupon_select"))
    /// 劵背景图
    let bgIv = UIImageView(image: UIImage(named: "coupon_bg_will_expired"))
    /// 标题
    lazy var titleLabel = UILabel.with(textColor: .qu_black, boldFontSize: 28)
    /// 使用条件
    lazy var requirementLabel = UILabel.with(textColor: .qu_black, fontSize: 24)
    /// 使用时间
    lazy var dateLabel = UILabel.with(textColor: .qu_lightGray, fontSize: 20)
    /// 减扣金额
    lazy var amountLabel = UILabel.with(textColor: UIColor(hex: "fd4152")!, boldFontSize: 44)
    /// 金额描述
    lazy var amounttitleLabel = UILabel.with(textColor: UIColor(hex: "fd4152")!, fontSize: 24)
    /// 分割线
    let seperatorLine = UIView.withBackgounrdColor(.viewBackgroundColor)
    // 使用说明背景
    var instructBgView = UIView.withBackgounrdColor(.white)
    /// 使用说明
    lazy var instructLabel = UILabel.with(textColor: .qu_lightGray, fontSize: 24)
    /// 不可使用原因
    lazy var noticeLabel = UILabel.with(textColor: .qu_red, fontSize: 24)
    /// 波浪
    let borderIv = UIImageView(image: UIImage(named: "coupon_cell_border"))
    /// 劵左遮罩
    let maskLeftIv = UIImageView(image: UIImage(named: "coupon_mask_left"))
    /// 劵右遮罩
    let maskRightIv = UIImageView(image: UIImage(named: "coupon_mask_right"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = .clear
        self.selectionStyle = .none

        let bounds = CGRect(x: 0, y: 0, width: Constants.kScreenWidth - 24, height: Constants.kScreenWidth/4 - 6)
        bgView.roundCorners([.topLeft, .topRight], radius: 8, bounds: bounds)
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(Constants.kScreenWidth/4 - 6)
        }

        selectedIv.isHidden = true
        contentView.addSubview(selectedIv)
        selectedIv.snp.makeConstraints { (make) in
            make.right.top.equalTo(bgView)
        }

        bgView.addSubview(bgIv)
        bgIv.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        let amoutArea = UIView.withBackgounrdColor(.clear)
        bgView.addSubview(amoutArea)
        amoutArea.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.equalTo(Constants.kScreenWidth/3 - 8)
            make.height.equalTo(Constants.kScreenWidth/4 - 6)
        }

        amoutArea.addSubview(amountLabel)
        amountLabel.snp.makeConstraints { make in
            make.bottom.equalTo(amoutArea.snp.centerY)
            make.centerX.equalToSuperview()
        }

        amoutArea.addSubview(amounttitleLabel)
        amounttitleLabel.snp.makeConstraints { make in
            make.top.equalTo(amoutArea.snp.centerY)
            make.centerX.equalToSuperview()
        }

        bgView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(25)
            make.left.equalTo(amoutArea.snp.right)
        }

        bgView.addSubview(requirementLabel)
        requirementLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(9)
            make.left.equalTo(titleLabel)
        }

        bgView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(requirementLabel.snp.bottom).offset(2)
            make.left.equalTo(requirementLabel)
        }

        seperatorLine.isHidden = true
        bgView.addSubview(seperatorLine)

        instructLabel.numberOfLines = 0
        instructLabel.isHidden = true
        contentView.addSubview(instructLabel)

        noticeLabel.numberOfLines = 0
        noticeLabel.isHidden = true
        contentView.addSubview(noticeLabel)

        contentView.insertSubview(instructBgView, at: 0)

        contentView.addSubview(borderIv)

        maskLeftIv.isHidden = true
        contentView.addSubview(maskLeftIv)

        maskRightIv.isHidden = true
        contentView.addSubview(maskRightIv)
    }

    func configureWith(coupon: Coupon, isSelect: Bool) {

        selectedIv.isHidden = !isSelect

        titleLabel.text = coupon.title
        requirementLabel.text = coupon.desc
        dateLabel.text = "\(coupon.validAt)-\(coupon.invalidAt)"
        amountLabel.text = coupon.amount
        amounttitleLabel.text = coupon.type == "DK" ? "蛋壳" : "元气"
        bgIv.image = UIImage(named: coupon.status.image)

        changeUI(coupon: coupon)
    }

    private func changeUI(coupon: Coupon) {

        seperatorLine.isHidden = false
        instructLabel.isHidden = false
        noticeLabel.isHidden = false
        maskLeftIv.isHidden = false
        maskRightIv.isHidden = false

        if coupon.notice != nil || coupon.canUseNotice != nil {
            seperatorLine.snp.remakeConstraints { make in
                make.left.bottom.right.equalToSuperview()
                make.height.equalTo(1)
            }

            maskLeftIv.snp.remakeConstraints { make in
                make.left.equalTo(bgView)
                make.centerY.equalTo(seperatorLine.snp.top)
            }

            maskRightIv.snp.remakeConstraints { make in
                make.right.equalTo(bgView)
                make.centerY.equalTo(seperatorLine.snp.top)
            }
        }

        if let notice = coupon.notice {
            instructLabel.text = notice
            instructLabel.snp.remakeConstraints { make in
                make.top.equalTo(bgView.snp.bottom).offset(8)
                make.left.equalTo(bgView).offset(12)
                make.right.equalTo(bgView).offset(-10)
            }
        } else {
            instructLabel.isHidden = true
        }

        if let canUseNotice =  coupon.canUseNotice {
            noticeLabel.text = canUseNotice
            noticeLabel.snp.remakeConstraints { make in
                if let _ = coupon.notice {
                    make.top.equalTo(instructLabel.snp.bottom)
                } else {
                    make.top.equalTo(bgView.snp.bottom).offset(8)
                }
                make.left.equalTo(bgView).offset(12)
                make.right.equalTo(bgView).offset(-10)
            }
        } else {
            noticeLabel.isHidden = true
        }

        borderIv.snp.remakeConstraints { make in
            if let _ = coupon.notice {
                if let _ =  coupon.canUseNotice {
                    make.top.equalTo(noticeLabel.snp.bottom).offset(8)
                } else {
                    make.top.equalTo(instructLabel.snp.bottom).offset(8)
                }
            } else {
                if let _ =  coupon.canUseNotice {
                    make.top.equalTo(noticeLabel.snp.bottom).offset(8)
                } else {
                    make.top.equalTo(bgView.snp.bottom)
                }
            }
            make.left.right.equalTo(bgView)
            make.height.equalTo(8)
            make.bottom.equalToSuperview().offset(-12)
        }

        if coupon.notice == nil && coupon.canUseNotice == nil {
            seperatorLine.isHidden = true
            maskLeftIv.isHidden = true
            maskRightIv.isHidden = true
        }

        instructBgView.snp.makeConstraints { (make) in
            make.top.equalTo(bgView.snp.bottom)
            make.left.right.equalTo(bgView)
            make.bottom.equalTo(borderIv.snp.top)
        }

        // 改状态
        if let canUse = coupon.canUse {
            if canUse == "0" { // 不可用
                notStaredAndUnavail()
            } else { // 可用
                changeStatus(status: coupon.status)
            }
        } else {
            changeStatus(status: coupon.status)
        }
    }

    func layoutNoticeLb(canUseNotice: String) {
        noticeLabel.text = canUseNotice
        noticeLabel.snp.makeConstraints { make in
            make.top.equalTo(instructLabel.snp.bottom)
            make.left.right.equalTo(instructLabel)
        }

        borderIv.snp.remakeConstraints { make in
            make.top.equalTo(noticeLabel.snp.bottom).offset(8)
            make.left.right.equalTo(bgView)
            make.height.equalTo(8)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    private func changeStatus(status: CouponStatus) {
        if status == .userd || status == .expired {
            userdAndExpired()
        } else if status == .notStared {
            notStaredAndUnavail()
        } else if status == .normal || status == .willExpired {
            normalAndWillExpired()
        }
    }

    // 可用/即将过期
    func normalAndWillExpired() {
        titleLabel.textColor = .qu_black
        requirementLabel.textColor = .qu_black
        amountLabel.textColor = UIColor(hex: "fd4152")
        amounttitleLabel.textColor = UIColor(hex: "fd4152")
    }

    // 未开始/不可用
    func notStaredAndUnavail() {
        titleLabel.textColor = .qu_lightGray
        requirementLabel.textColor = .qu_lightGray
        amountLabel.textColor = UIColor(hex: "fd4152", alpha: 0.4)
        amounttitleLabel.textColor = UIColor(hex: "fd4152", alpha: 0.4)
    }

    // 已使用/已过期
    func userdAndExpired() {
        titleLabel.textColor = .qu_lightGray
        requirementLabel.textColor = .qu_lightGray
        amountLabel.textColor = .qu_lightGray
        amounttitleLabel.textColor = .qu_lightGray
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
