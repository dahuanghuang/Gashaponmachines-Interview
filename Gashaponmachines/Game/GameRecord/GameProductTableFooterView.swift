/// 顶部标题背景图宽高
let GameProductTableFooterViewTitleBgIvW: CGFloat = Constants.kScreenWidth
let GameProductTableFooterViewTitleBgIvH: CGFloat = GameProductTableFooterViewTitleBgIvW*0.37

class GameProductTableFooterView: UIView {

    let titleBgIv = UIImageView(image: UIImage(named: "game_n_title_bg"))
    
    lazy var countLabel: UILabel = {
        let lb = UILabel.numberFont(size: 16)
        lb.textColor = UIColor(hex: "9A4312")!.alpha(0.7)
        return lb
    }()
    
    lazy var subTitleLabel: UILabel = {
        let lb = UILabel.with(textColor: UIColor(hex: "9A4312")!, boldFontSize: 26)
        lb.textAlignment = .right
        return lb
    }()
    
    lazy var titleLabel: UILabel = {
        let lb = UILabel.with(textColor: .qu_black, boldFontSize: 28)
        lb.numberOfLines = 0
        lb.textAlignment = .center
        return lb
    }()

    init(luckyProduct: Product, images: [UIImage]) {

        super.init(frame: .zero)
        
		self.backgroundColor = .new_yellow
        
        self.addSubview(titleBgIv)
        titleBgIv.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(GameProductTableFooterViewTitleBgIvH)
        }
        
        countLabel.text = luckyProduct.eggAmountTitle
        titleBgIv.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.left.equalTo(GameProductTableFooterViewTitleBgIvW*0.35)
            make.top.equalTo(GameProductTableFooterViewTitleBgIvH*0.15)
        }
        
        let countIv = UIImageView(image: UIImage(named: "game_n_detail_count"))
        titleBgIv.addSubview(countIv)
        countIv.snp.makeConstraints { make in
            make.centerY.equalTo(countLabel)
            make.left.equalTo(countLabel.snp.right)
        }
        
        subTitleLabel.text = luckyProduct.subTitle
        titleBgIv.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(countLabel)
            make.right.equalTo(-GameProductTableFooterViewTitleBgIvW*0.04)
        }
        
        titleLabel.text = luckyProduct.luckyProductTitle
        titleBgIv.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-GameProductTableFooterViewTitleBgIvH*0.14)
            make.width.equalTo(GameProductTableFooterViewTitleBgIvW*0.8)
            make.height.equalTo(GameProductTableFooterViewTitleBgIvH*0.26)
        }

        var lastView: UIView = titleBgIv
        for image in images {
            let width = Constants.kScreenWidth - 24
            let height = width/(image.size.width/image.size.height)
            
            let iv = UIImageView()
            iv.image = image
            self.insertSubview(iv, belowSubview: lastView)
            
            iv.snp.makeConstraints { make in
                make.width.equalTo(width)
                make.height.equalTo(height)
                make.centerX.equalToSuperview()
                make.top.equalTo(lastView.snp.bottom)
            }
            lastView = iv
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
