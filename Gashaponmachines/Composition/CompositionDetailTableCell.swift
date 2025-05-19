class CompositionDetailTableCell: BaseTableViewCell {

    private let CompositionDetailMaterialCollectionCellIdentifier = "CompositionDetailMaterialCollectionCellIdenti                                  fier"

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 66, height: 66)
        layout.minimumInteritemSpacing = 16
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .white
        cv.showsHorizontalScrollIndicator = false
        cv.register(CompositionDetailMaterialCollectionCell.self, forCellWithReuseIdentifier: CompositionDetailMaterialCollectionCellIdentifier)
        return cv
    }()

    private var materials: [ComposeMaterial?] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    private var detail: ComposeDetail?

    lazy var progressLabel = UILabel.with(textColor: .qu_black, fontSize: 32)

    lazy var titleLabel = UILabel.with(textColor: .qu_black, fontSize: 28, defaultText: "材料：")

    lazy var findMaterialButton = UIButton.orangeTextWhiteBackgroundOrangeRoundedButton(title: "寻找材料", fontSize: 20)

    weak var delegate: CompositionDetailTableCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.backgroundColor = UIColor(hex: "ffe6ac")

        let bg = UIView.withBackgounrdColor(UIColor(hex: "fff5de")!)
        self.contentView.addSubview(bg)
        bg.snp.makeConstraints { make in
            make.top.bottom.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(16)
            make.right.equalTo(self.contentView).offset(-16)
        }

        let content = UIView.withBackgounrdColor(.white)
        content.layer.cornerRadius = 4
        content.layer.masksToBounds = true
        bg.addSubview(content)
        content.snp.makeConstraints { make in
            make.top.bottom.equalTo(bg)
            make.left.equalTo(bg).offset(12)
            make.right.equalTo(bg).offset(-12)
        }

        let logo = UIImageView.with(imageName: "compo_detail_cell_logo")
        content.addSubview(logo)
        logo.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(8)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }

        findMaterialButton.addTarget(self, action: #selector(findMaterial), for: .touchUpInside)
        content.addSubview(findMaterialButton)
        findMaterialButton.snp.makeConstraints { make in
            make.centerY.equalTo(logo)
            make.right.equalToSuperview().offset(-8)
            make.size.equalTo(CGSize(width: 60, height: 20))
        }

        content.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(logo)
            make.left.equalTo(logo.snp.right).offset(4)
            make.right.equalTo(findMaterialButton.snp.left).offset(-4)
        }

        let line = UIView.seperatorLine(.compos_borderColor)
        content.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.equalTo(content)
            make.top.equalTo(logo.snp.bottom).offset(12)
            make.height.equalTo(0.5)
        }

        content.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.right.equalTo(content).offset(-12)
            make.top.equalTo(line.snp.bottom).offset(12)
            make.left.equalTo(content).offset(90)
            make.height.equalTo(70)
        }

        let desView = UIView()
        content.addSubview(desView)
        desView.snp.makeConstraints { make in
            make.centerY.equalTo(collectionView)
            make.left.equalToSuperview()
            make.right.equalTo(collectionView.snp.left)
        }

        desView.addSubview(progressLabel)
        progressLabel.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
        }

        let desLabel = UILabel.with(textColor: .qu_black, fontSize: 20, defaultText: "进度")
        desView.addSubview(desLabel)
        desLabel.snp.makeConstraints { make in
            make.bottom.centerX.equalToSuperview()
            make.top.equalTo(progressLabel.snp.bottom).offset(8)
        }
    }

    func configureWith(detail: ComposeDetail) {
        self.detail = detail

        titleLabel.text = "材料：\(detail.title)"
        if detail.hasReachAll {
            progressLabel.text = "已达成"
            progressLabel.textColor = UIColor.UIColorFromRGB(0xff5a37)
        } else {
            progressLabel.text = "\(detail.ownCount)/\(detail.totalCount)"
            progressLabel.textColor = UIColor.qu_black
        }

        var newMaterials: [ComposeMaterial?] = detail.materials
        while newMaterials.count < detail.totalCount {
            newMaterials.append(nil)
        }
        materials = newMaterials
//        findMaterialButton.isHidden = !detail.canLockAll || detail.materials.isEmpty
//        findMaterialButton.rx.tap
//            .asDriver()
//            .drive(onNext: { [weak self] in
////                let orderIds = newMaterials.compactMap { $0 }.map { $0.orderId }
////                self?.delegate?.tableCellLockButtonTapped(orderIds: orderIds)
//            })
//            .disposed(by: rx.reuseBag)
    }

    @objc func findMaterial() {
        if let detail = self.detail {
            self.delegate?.tableCellFindMaterialButtonTapped(notice: detail.notice, action: detail.action)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        progressLabel.text = nil
        materials.removeAll()
//        findMaterialButton.isHidden = true
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CompositionDetailTableCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return materials.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CompositionDetailMaterialCollectionCellIdentifier, for: indexPath) as! CompositionDetailMaterialCollectionCell
        if let material = materials[indexPath.row] {
            cell.configureWith(material: material)
//            cell.delegate = self
        }
        return cell
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 66, height: 116)
//    }
}

// extension CompositionDetailTableCell: CompositionDetailMaterialCollectionCellDelegate {
//
//    func lockButtonTapped(orderId: String) {
//        self.delegate?.tableCellLockButtonTapped(orderIds: [orderId])
//    }
// }

protocol CompositionDetailTableCellDelegate: class {

//    func tableCellLockButtonTapped(orderIds: [String])
    func tableCellFindMaterialButtonTapped(notice: String, action: String)
}
