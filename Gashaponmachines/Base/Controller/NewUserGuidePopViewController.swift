import UIKit

let NewUserGuideHomeDetailKey = "NewUserGuideHomeDetailKey"
let NewUserGuideOnepieceKey = "NewUserGuideOnepieceKey"
let NewUserGuideMachineKey = "NewUserGuideMachineKey"
let NewUserGuideMallKey = "NewUserGuideMallKey"
let NewUserGuideOnepieceDetailKey = "NewUserGuideOnepieceDetailKey"

enum UserGuideType: String {
    case home
    case onepiece
    case machine
    case mall
    case onepieceDetail

    var imageNames: [String] {
        switch self {
        case .home:
            return self.getImageNames(count: 2)
        case .onepiece:
            return self.getImageNames(count: 3)
        case .machine:
            return self.getImageNames(count: 2)
        case .mall:
            return self.getImageNames(count: 2)
        case .onepieceDetail:
            return [String]()
        }
    }

    var endTitle: String {
        switch self {
        case .onepiece:
            return "立即体验"
        case .home, .machine, .mall:
            return "了解啦!"
        case .onepieceDetail:
            return ""
        }
    }

    func getImageNames(count: Int) -> [String] {
        var imageNames = [String]()
        for index in 0..<count {
            imageNames.append("guide_\(self.rawValue)_\(index)")
        }
        return imageNames
    }

    func archiveRecord() {
        switch self {
        case .home:
            UserDefaults.standard.setValue(Date(), forKey: NewUserGuideHomeDetailKey)
            UserDefaults.standard.synchronize()
        case .onepiece:
            UserDefaults.standard.setValue(Date(), forKey: NewUserGuideOnepieceKey)
            UserDefaults.standard.synchronize()
        case .machine:
            UserDefaults.standard.setValue(Date(), forKey: NewUserGuideMachineKey)
            UserDefaults.standard.synchronize()
        case .mall:
            UserDefaults.standard.setValue(Date(), forKey: NewUserGuideMallKey)
            UserDefaults.standard.synchronize()
        case .onepieceDetail:
            UserDefaults.standard.setValue(Date(), forKey: NewUserGuideOnepieceDetailKey)
            UserDefaults.standard.synchronize()
        }
    }
}

class NewUserGuidePopViewController: UIViewController {

    weak var timer: Timer?

    /// 点击了解了
    var didConfirmButtonClick: (() -> Void)?

    // 弹窗类型
    var guideType: UserGuideType!

    // 主图
    let imageIv = UIImageView()
    // 下一步按钮
    let nextButton = UIButton()
    // 倒计时文字
    let timeLb = UILabel.with(textColor: UIColor(hex: "8a8a8a")!, fontSize: 28)

    // 用于一番赏详情的图片
    let detailIv1 = UIImageView()
    let detailIv2 = UIImageView()

    var currentIndex = 0

    // 倒计时
    var count: Int = 2

    init(guideType: UserGuideType) {
        super.init(nibName: nil, bundle: nil)

        self.guideType = guideType
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let blackView = UIView()
        if self.guideType == .onepieceDetail {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
            blackView.addGestureRecognizer(gesture)
        }
        blackView.backgroundColor = .qu_popBackgroundColor
        view.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        if self.guideType == .onepieceDetail {
            detailIv1.image = UIImage(named: "guide_detail_0")
            detailIv1.isUserInteractionEnabled = true
            blackView.addSubview(detailIv1)
            detailIv1.snp.makeConstraints { (make) in
                make.top.equalTo(204)
                make.centerX.equalToSuperview()
            }

            detailIv2.isHidden = true
            detailIv2.image = UIImage(named: "guide_detail_1")
            detailIv2.isUserInteractionEnabled = true
            blackView.addSubview(detailIv2)
            detailIv2.snp.makeConstraints { (make) in
                make.width.equalTo(285)
                make.height.equalTo(102)
                make.top.equalToSuperview().offset(36 + Constants.kNavHeight + Constants.kStatusBarHeight)
                make.right.equalToSuperview()
            }
        } else {
            imageIv.image = UIImage(named: guideType.imageNames[currentIndex])
            blackView.addSubview(imageIv)
            imageIv.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }

            nextButton.isEnabled = false
            nextButton.setTitle("下一步", for: .normal)
            nextButton.backgroundColor = UIColor(hex: "ffd712")
            nextButton.layer.cornerRadius = 23.5
            nextButton.setTitleColor(.qu_black, for: .normal)
            nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
            nextButton.addTarget(self, action: #selector(nextStep), for: .touchUpInside)
            blackView.addSubview(nextButton)
            nextButton.snp.makeConstraints { make in
                make.centerY.equalTo(imageIv.snp.bottom)
                make.centerX.equalToSuperview()
                make.width.equalTo(152)
                make.height.equalTo(47)
            }

            timeLb.text = "2s"
            timeLb.textAlignment = .center
            blackView.addSubview(timeLb)
            timeLb.snp.makeConstraints { (make) in
                make.top.equalTo(nextButton.snp.bottom)
                make.centerX.equalTo(nextButton)
            }

            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
            RunLoop.current.add(self.timer!, forMode: .common)
        }
    }

    @objc func countDown() {

        if count == 0 { return }

        count -= 1
        if count == 0 {
            self.setNextButton(enable: true)
        } else {
            self.setNextButton(enable: false)
        }
    }

    func setNextButton(enable: Bool) {
        if enable {
            nextButton.isEnabled = true
            timeLb.isHidden = true
        } else {
            nextButton.isEnabled = false
            timeLb.isHidden = false
            timeLb.text = "\(count)s"
        }
        if currentIndex == guideType.imageNames.count - 1 { // 最后一个
            nextButton.setTitle(guideType.endTitle, for: .normal)
        } else {
            nextButton.setTitle("下一步", for: .normal)
        }
    }

    @objc func nextStep() {

        count = 2

        currentIndex += 1

        if currentIndex >= guideType.imageNames.count || currentIndex < 0 {
            self.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                self.stopTimer()
                self.guideType.archiveRecord()
                if let handle = self.didConfirmButtonClick {
                    handle()
                }
            }
            return
        }

        self.setNextButton(enable: false)

        imageIv.image = UIImage(named: guideType.imageNames[currentIndex])
    }

    @objc func dismissVC() {
        if detailIv2.isHidden {
            detailIv1.isHidden = true
            detailIv2.isHidden = false
        } else {
            self.dismiss(animated: true) {
                if self.guideType == .onepieceDetail {
                    self.guideType.archiveRecord()
                }
            }
        }
    }

    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}
