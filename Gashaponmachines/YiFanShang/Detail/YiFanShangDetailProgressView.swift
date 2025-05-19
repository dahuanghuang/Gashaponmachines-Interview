import UIKit

class YiFanShangDetailProgressView: UIView {
    
    // 进度值
    private lazy var progressLabel: UILabel = {
        let lb = UILabel.numberFont(size: 14)
        lb.textColor = .black
        return lb
    }()
    
    let progressView = CustomProgressView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(hex: "FFFDE8")
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        
        self.addSubview(progressLabel)
        progressLabel.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.centerY.equalToSuperview()
        }
        
        self.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.equalTo(4)
            make.centerY.equalToSuperview()
            make.height.equalTo(12)
            make.right.equalTo(-56)
        }
    }
    
    func setProgress(progress: CGFloat, progressText: String) {
        self.progressLabel.text = progressText
        self.progressView.progress = progress
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class CustomProgressView: UIView {
    
    /// 进度值
    public var progress: CGFloat = 0.0 {
        didSet {
            dynamicView.snp.remakeConstraints { make in
                make.top.bottom.width.equalToSuperview()
                make.right.equalTo(self.snp.left).offset(self.width * progress)
            }
        }
    }
    
    /// 底部图片
    private let staticIv = UIImageView(image: UIImage(named: "yfs_detail_progress_static"))
    
    /// 顶部图片
    private let dynamicView = UIView.withBackgounrdColor(.new_yellow)
    
    /// 顶部进度条
    private let dynamicIv = UIImageView(image: UIImage(named: "yfs_detail_progress_dynamic"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .new_backgroundColor
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
        
        self.addSubview(staticIv)
        staticIv.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
        }
        
        self.addSubview(dynamicView)
        dynamicView.snp.makeConstraints { make in
            make.top.bottom.width.equalToSuperview()
            make.right.equalTo(self.snp.left)
        }
        
        dynamicView.addSubview(dynamicIv)
        dynamicIv.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
