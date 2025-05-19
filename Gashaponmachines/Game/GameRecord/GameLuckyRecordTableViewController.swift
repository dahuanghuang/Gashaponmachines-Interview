// 黑金蛋记录
import UIKit
import RxDataSources

private let GameLuckyRecordTableViewCellReusableIdentifier = "GameLuckyRecordTableViewCellReusableIdentifier"

class GameLuckyRecordTableViewController: BaseViewController {

    var canScroll: Bool = false

    var viewModel: GameLuckyRecordTableViewModel = GameLuckyRecordTableViewModel()

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .new_yellow
//        tv.bounces = false
        tv.sectionHeaderHeight = 56
        tv.sectionFooterHeight = 40
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.kScreenBottomInset, right: 0)
        tv.register(GameLuckyRecordTableViewCell.self, forCellReuseIdentifier: GameLuckyRecordTableViewCellReusableIdentifier)
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }

    override func bindViewModels() {
        super.bindViewModels()

        self.tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        self.viewModel.records
            .drive(self.tableView.rx.items(cellIdentifier: GameLuckyRecordTableViewCellReusableIdentifier, cellType: GameLuckyRecordTableViewCell.self)) { (_, item, cell) in
            	cell.configureWith(record: item)
        	}
        	.disposed(by: disposeBag)

        self.viewModel.error
            .subscribe(onNext: { env in
            	HUD.showErrorEnvelope(env: env)
        	})
        	.disposed(by: disposeBag)

    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !canScroll {
            scrollView.contentOffset = .zero
            return
        }
        if scrollView.contentOffset.y <= 0 {
            canScroll = false
            scrollView.contentOffset = .zero
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "leaveTop"), object: nil)
        }
    }
}

extension GameLuckyRecordTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView()
        headView.backgroundColor = .white

        let noticeBg = RoundedCornerView(corners: [.topLeft, .topRight], radius: 8, backgroundColor: .new_backgroundColor)
        headView.addSubview(noticeBg)
        noticeBg.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(42)
            make.bottom.equalToSuperview()
        }
        
        let noticeIv = UIImageView(image: UIImage(named: "game_n_record_notice"))
        headView.addSubview(noticeIv)
        noticeIv.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.width.equalTo(70)
            make.height.equalTo(48)
            make.bottom.equalToSuperview()
        }
        
        let noticeLb = UILabel.with(textColor: .new_middleGray, fontSize: 24, defaultText: "多个商品共用一个扭蛋机时黑金蛋记录会统计在一起")
        noticeLb.textAlignment = .left
        headView.addSubview(noticeLb)
        noticeLb.snp.makeConstraints { (make) in
            make.left.equalTo(noticeIv.snp.right).offset(4)
            make.centerY.equalTo(noticeBg)
        }

        return headView
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footView = UIView.withBackgounrdColor(.new_yellow)
        
        let noticeBg = RoundedCornerView(corners: [.bottomLeft, .bottomRight], radius: 12, backgroundColor: .white)
        footView.addSubview(noticeBg)
        noticeBg.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(20)
        }
        
        let noticeIv = UIImageView(image: UIImage(named: "game_n_record_footer"))
        footView.addSubview(noticeIv)
        noticeIv.snp.makeConstraints { (make) in
            make.top.centerX.height.equalToSuperview()
            make.width.equalTo(227)
        }

        let noticeLb = UILabel.with(textColor: .new_middleGray, fontSize: 24, defaultText: "仅显示最近30条黑金蛋记录哦")
        footView.addSubview(noticeLb)
        noticeLb.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.centerX.equalToSuperview()
        }

        return footView
    }
}
