import UIKit


class HomeRecommendNewView: UIView {
    
    /// 查看更多点击回调
    var moreButtonClickHandle: (() -> Void)?
    
    var styleInfos: [HomeStyleInfo]? {
        didSet {
            if let styleInfos = self.styleInfos {
                for styleInfo in styleInfos {
                    if let machines = styleInfo.machineList, !machines.isEmpty {
                        // D类型由于改版, 暂时用不到
                        if styleInfo.style == .a {
                            self.leftView.machines = machines
                        }else if styleInfo.style == .b {
                            self.rightTopView.machine = machines[0]
                        }else if styleInfo.style == .c {
                            self.rightBottomView.machine = machines[0]
                        }
                    }
                }
            }
        }
    }
    
    /// 橘红色渐变背景
    lazy var bgView: UIView = {
        let view = UIView.withBackgounrdColor(.clear)
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var bgGradientLayer: CAGradientLayer = {
        let ly = CAGradientLayer()
        ly.colors = [UIColor(hex: "FF602E")!.cgColor, UIColor(hex: "FFC4B1")!.cgColor]
        ly.startPoint = CGPoint(x: 0.5, y: 0)
        ly.endPoint = CGPoint(x: 0.5, y: 1)
        ly.cornerRadius = 12
        return ly
    }()
    
    /// 顶部标题背景
    let topView = UIView.withBackgounrdColor(.clear)
    
    /// 标题图片
    let titleIv = UIImageView(image: UIImage(named: "home_recommend_title"))
    
    /// 查看更多图片
    let seeMoreIv = UIImageView(image: UIImage(named: "home_recommend_seemore"))
    
    /// 查看更多按钮
    lazy var seeMoreButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(moreButtonClick), for: .touchUpInside)
        return btn
    }()
    
    /// 左商品
    lazy var leftView: HomeNewLeftView = {
        let view = HomeNewLeftView()
        view.buttonClickHandle = { [weak self] machine in
            self?.jumpToGameVc(machine: machine)
        }
        return view
    }()
    
    /// 右上商品
    lazy var rightTopView: HomeNewRightView = {
        let view = HomeNewRightView()
        view.buttonClickHandle = { [weak self] machine in
            self?.jumpToGameVc(machine: machine)
        }
        return view
    }()
    
    /// 右下商品
    lazy var rightBottomView: HomeNewRightView = {
        let view = HomeNewRightView()
        view.buttonClickHandle = { [weak self] machine in
            self?.jumpToGameVc(machine: machine)
        }
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear

        self.addSubview(bgView)
        bgView.layer.addSublayer(bgGradientLayer)

        self.addSubview(topView)
        topView.addSubview(titleIv)
        topView.addSubview(seeMoreIv)
        topView.addSubview(seeMoreButton)

        self.addSubview(leftView)
        self.addSubview(rightTopView)
        self.addSubview(rightBottomView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgView.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.right.bottom.equalToSuperview()
        }

        bgGradientLayer.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height-10)

        topView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }

        titleIv.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
        }

        seeMoreIv.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
        }

        seeMoreButton.snp.makeConstraints { make in
            make.edges.equalTo(seeMoreIv)
        }

        leftView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(4)
            make.left.equalTo(12)
            make.bottom.equalTo(-12)
        }

        rightTopView.snp.makeConstraints { make in
            make.top.equalTo(leftView)
            make.left.equalTo(leftView.snp.right).offset(8)
            make.right.equalTo(-12)
            make.width.equalTo(leftView)
        }

        rightBottomView.snp.makeConstraints { make in
            make.top.equalTo(rightTopView.snp.bottom).offset(8)
            make.bottom.equalTo(leftView)
            make.left.right.width.height.equalTo(rightTopView)
        }
    }
    
    @IBAction func moreButtonClick() {
        if let handle = moreButtonClickHandle {
            handle()
        }
    }
    
    private func jumpToGameVc(machine: HomeMachine) {
        if let type = MachineColorType(rawValue: machine.type.rawValue) {
            if let root = UIApplication.shared.keyWindow?.rootViewController as? MainViewController {
                guard AppEnvironment.current.apiService.accessToken != nil else {
                    let vc = LoginViewController.controller
                    vc.modalPresentationStyle = .fullScreen
                    root.present(vc, animated: true, completion: nil)
                    return
                }

                let vc = NavigationController(rootViewController: GameNewViewController(physicId: machine.physicId, type: type))
                vc.modalPresentationStyle = .fullScreen
                root.present(vc, animated: true, completion: nil)
            }
        } else {
            HUD.showError(second: 1.0, text: "机台类型出错", completion: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HomeNewLeftView: UIView {
    
    var buttonClickHandle: ((HomeMachine) -> Void)?

    var machines = [HomeMachine]() {
        didSet {
            self.removeTimer()
            self.addTimer()
        }
    }
    
    // 正在展示的商品
    var currentMachine: HomeMachine?
    
    /// 正在展示商品的Index
    var currentIndex: Int = 0
    
    /// 定时器
    var timer: Timer?
    
    /// 商品图
    let productIv = UIImageView()
    
    /// 状态视图
    let statusView = HomeNewStatusView()
    
    /// 浅黄色底部背景
    let bottomView = UIView.withBackgounrdColor(UIColor(hex: "FFFDE8")!)
    
    /// 机台类型图
    let typeIv = UIImageView()
    
    /// 分割线
    let separateLine = UIView.withBackgounrdColor(.new_bgYellow)
    
    /// 商品价格
    let valueLb = UILabel.numberFont(size: 20)
    
    /// 展示顺序
    lazy var indexLb: UILabel = {
        let lb = UILabel.numberFont(size: 10)
        lb.textColor = UIColor(hex: "A67514")
        lb.textAlignment = .right
        return lb
    }()
    
    /// 商品名称
    lazy var nameLb: UILabel = {
        let lb = UILabel.with(textColor: UIColor(hex: "754E00")!, boldFontSize: 28)
        lb.textAlignment = .left
        lb.numberOfLines = 2
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    
        self.addSubview(productIv)
        self.addSubview(statusView)
        self.addSubview(bottomView)
        bottomView.addSubview(typeIv)
        bottomView.addSubview(separateLine)
        bottomView.addSubview(valueLb)
        bottomView.addSubview(indexLb)
        bottomView.addSubview(nameLb)
        
        let actionButton = UIButton()
        actionButton.addTarget(self, action: #selector(actionButtonClick), for: .touchUpInside)
        self.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 添加定时器
    private func addTimer() {
        if machines.isEmpty { return }

        self.currentIndex = 0

        updateTopMachine(machine: machines[0])

        let timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(nextMachine), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        self.timer = timer
    }
    
    /// 移除定时器
    private func removeTimer() {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    // 更新机台显示
    func updateTopMachine(machine: HomeMachine) {
        self.currentMachine = machine

        productIv.gas_setImageWithURL(machine.image)
        nameLb.text = machine.title
        typeIv.image = UIImage(named: machine.type.image)
        valueLb.text = machine.priceStr
        indexLb.text = "\(currentIndex+1)/\(machines.count)"

        if currentIndex == machines.count-1 {// 最后一个
            currentIndex = 0
        } else {
            currentIndex += 1
        }
    }
    
    @objc func nextMachine() {
        if currentIndex >= 0 && currentIndex < machines.count { // 合理范围
            self.updateTopMachine(machine: machines[currentIndex])
        }
    }
    
    @objc func actionButtonClick() {
        if let handle = self.buttonClickHandle, let machine = currentMachine {
            handle(machine)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        productIv.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(productIv.snp.width)
        }
        
        statusView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalTo(56)
            make.height.equalTo(22)
        }
        
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(productIv.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
        
        typeIv.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.equalTo(8)
            make.size.equalTo(20)
        }
        
        separateLine.snp.makeConstraints { make in
            make.centerY.equalTo(typeIv)
            make.left.equalTo(typeIv.snp.right).offset(4)
            make.width.equalTo(1)
            make.height.equalTo(8)
        }
        
        valueLb.snp.makeConstraints { make in
            make.centerY.equalTo(separateLine)
            make.left.equalTo(separateLine.snp.right).offset(4)
        }
        
        indexLb.snp.makeConstraints { make in
            make.centerY.equalTo(separateLine)
            make.right.equalToSuperview().offset(-8)
        }
        
        nameLb.snp.makeConstraints { make in
            make.top.equalTo(typeIv.snp.bottom).offset(8)
            make.left.equalTo(typeIv)
            make.right.equalTo(indexLb)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HomeNewRightView: UIView {
    
    var buttonClickHandle: ((HomeMachine) -> Void)?
    
    var machine: HomeMachine? {
        didSet {
            if let m = machine {
                productIv.gas_setImageWithURL(m.image)
                typeIv.image = UIImage(named: m.type.image)
                valueLb.text = m.priceStr
                nameLb.text = m.title
            }
        }
    }
    
    /// 商品图
    let productIv = UIImageView()
    /// 阴影遮罩
    lazy var maskLayer: CAGradientLayer = {
        let ly = CAGradientLayer()
        ly.colors = [UIColor.white.cgColor, UIColor.white.alpha(0).cgColor]
        ly.startPoint = CGPoint(x: 0, y: 0.5)
        ly.endPoint = CGPoint(x: 1, y: 0.5)
        return ly
    }()
    /// 状态视图
    let statusView = HomeNewStatusView()
    /// 机台类型图
    let typeIv = UIImageView()
    /// 商品价格
    let valueLb = UILabel.numberFont(size: 16)
    /// 商品名称
    lazy var nameLb: UILabel = {
        let lb = UILabel.with(textColor: .black, boldFontSize: 20)
        lb.textAlignment = .left
        lb.numberOfLines = 2
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        self.addSubview(productIv)
        productIv.layer.addSublayer(maskLayer)
        self.addSubview(statusView)
        self.addSubview(typeIv)
        self.addSubview(valueLb)
        self.addSubview(nameLb)
        
        let actionButton = UIButton()
        actionButton.addTarget(self, action: #selector(actionButtonClick), for: .touchUpInside)
        self.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func actionButtonClick() {
        if let handle = self.buttonClickHandle, let m = machine {
            handle(m)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        statusView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalTo(56)
            make.height.equalTo(22)
        }
        
        productIv.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.right.bottom.equalTo(-8)
            make.width.equalTo(productIv.snp.height)
        }
        
        maskLayer.frame = CGRectMake(0, 0, productIv.width * 0.3, productIv.height)
        
        typeIv.snp.makeConstraints { make in
            make.left.equalTo(4)
            make.bottom.equalTo(-8)
            make.size.equalTo(20)
        }
        
        valueLb.snp.makeConstraints { make in
            make.centerY.equalTo(typeIv)
            make.left.equalTo(typeIv.snp.right).offset(4)
        }
        
        nameLb.snp.makeConstraints { make in
            make.left.equalTo(typeIv)
            make.right.equalTo(productIv.snp.left).offset(14)
            make.bottom.equalTo(typeIv.snp.top).offset(-6)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HomeNewStatusView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(hex: "FFF2BD")
        
        let dot = UIImageView(image: UIImage(named: "home_recommend_status"))
        self.addSubview(dot)
        dot.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.centerY.equalToSuperview()
            make.size.equalTo(6)
        }
        
        let statusLb = UILabel.with(textColor: UIColor(hex: "A67514")!, fontSize: 20, defaultText: "空闲中")
        self.addSubview(statusLb)
        statusLb.snp.makeConstraints { make in
            make.centerY.equalTo(dot)
            make.left.equalTo(dot.snp.right).offset(4)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.roundCorners([.bottomRight], radius: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//class HomeRecommendNewView: UIView {
//    func setupRightTopView(styleInfo: HomeStyleInfo) {
//        if let machines = styleInfo.machineList, !machines.isEmpty {
//            let machine = machines[0]
//            self.rightTopMachine = machine
//            rightTopProductIv.gas_setImageWithURL(machine
//                .image, targetSize: CGSize(width: largeImageWH, height: largeImageWH))
//            rightTopNameLabel.text = machine.title
//            rightTopMachineIv.image = UIImage(named: machine.type.image)
//            rightTopValueLabel.text = machine.priceStr
//        }
//    }
//
//    @IBAction func pushToGameVc(_ sender: UIButton) {
//        var selectMachine: HomeMachine?
//        switch sender.tag {
//        case 1:
//            selectMachine = topMachine
//        case 2:
//            selectMachine = rightTopMachine
//        case 3:
//            selectMachine = rightBottomMachine
//        case 4:
//            selectMachine = leftMachine
//        default:
//            QLog.error("机台跳转失败")
//        }
//
//        guard let machine = selectMachine else { return }
//
//        if let type = MachineColorType(rawValue: machine.type.rawValue) {
//            if let root = UIApplication.shared.keyWindow?.rootViewController as? MainViewController {
//
//                guard AppEnvironment.current.apiService.accessToken != nil else {
//                    let vc = LoginViewController.controller
//                    vc.modalPresentationStyle = .fullScreen
//                    root.present(vc, animated: true, completion: nil)
//                    return
//                }
//
//                let vc = NavigationController(rootViewController: GameNewViewController(physicId: machine.physicId, type: type))
//                vc.modalPresentationStyle = .fullScreen
//                root.present(vc, animated: true, completion: nil)
//            }
//        } else {
//            HUD.showError(second: 1.0, text: "机台类型出错", completion: nil)
//        }
//    }
//}
