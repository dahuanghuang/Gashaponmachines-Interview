import UIKit
import Kingfisher

class OccupyRechargeQueryViewController: UIViewController {

    /// 倒计时结束回调
    var timeOverHandle: (() -> Void)?

    var timer: Timer?

    /// 倒计时
    var traceTime: Int = 15

    let queryTimeLb = UILabel.with(textColor: .qu_black, fontSize: 24, defaultText: "在(15秒)持续查询结果中")

    init(traceTime: Int) {
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen

        if traceTime < 15 {
            self.traceTime = traceTime
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()

        addTimer()
    }

    fileprivate func setupView() {
        self.view.backgroundColor = .clear

        let blackView = UIView()
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
        contentView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(280)
        }

        let queryIv = UIImageView()
        let path = Bundle.main.path(forResource: "query_result", ofType: "gif")
        queryIv.kf.setImage(with: URL(fileURLWithPath: path!))
        contentView.addSubview(queryIv)
        queryIv.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(50)
        }

        let queryResultLb = UILabel.with(textColor: .qu_black, boldFontSize: 32, defaultText: "查询结果中...")
        contentView.addSubview(queryResultLb)
        queryResultLb.snp.makeConstraints { (make) in
            make.top.equalTo(queryIv.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        contentView.addSubview(queryTimeLb)
        queryTimeLb.snp.makeConstraints { (make) in
            make.top.equalTo(queryResultLb.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    private func addTimer() {

        removeTimer()

        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        self.timer = timer
    }

    private func removeTimer() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }

    func dismissVc() {

        removeTimer()

        self.dismiss(animated: true) {
            if let handle = self.timeOverHandle {
                handle()
            }
        }
    }

    @objc func countDown() {
        if self.traceTime <= 1 {
            self.dismissVc()
            return
        }
        self.traceTime -= 1
        self.queryTimeLb.text = "在(\(self.traceTime)秒)持续查询结果中"
    }
}
