class CompositionRecordCollectionViewHeader: UICollectionReusableView {

    lazy var savingCountLabel = UILabel.with(textColor: .white, fontSize: 64)

    override init(frame: CGRect) {
        super.init(frame: frame)

        let bg = UIImageView.with(imageName: "compo_record_header")
        self.addSubview(bg)
        bg.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.addSubview(savingCountLabel)
        savingCountLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        let label1 = UILabel.with(textColor: .white, fontSize: 24, defaultText: "共节省")
        self.addSubview(label1)
        label1.snp.makeConstraints { make in
            make.bottom.equalTo(savingCountLabel.snp.top).offset(-10)
            make.centerX.equalToSuperview()
        }

        let label2 = UILabel.with(textColor: .white, fontSize: 24, defaultText: "蛋壳")
        self.addSubview(label2)
        label2.snp.makeConstraints { make in
            make.top.equalTo(savingCountLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWith(savingCount: String) {
        self.savingCountLabel.text = savingCount
    }
}
