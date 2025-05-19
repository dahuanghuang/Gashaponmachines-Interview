import UIKit
import RxDataSources

private let FAQTableViewCellReusableIdentifier = "FAQTableViewCellReusableIdentifier"

class FAQViewController: BaseViewController {

    var viewModel: FAQViewModel = FAQViewModel()

    lazy var tableView: BaseTableView = {
        let tv = BaseTableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .clear
        tv.dataSource = self
        tv.delegate = self
        tv.rowHeight = UITableView.automaticDimension
        tv.register(FAQTableViewCell.self, forCellReuseIdentifier: FAQTableViewCellReusableIdentifier)
        return tv
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    let customerView = SingleButtonBottomView(title: "客服留言")
    
    let navBar = CustomNavigationBar()
    
    var faqs = [FAQEnvelope.FAQ]()
    
    let headerView = FAQHeaderView()
    
    let bgView = UIImageView(image: UIImage(named: "FAQ_bg"))
    let logoIv1 = UIImageView(image: UIImage(named: "FAQ_logo1"))
    let logoIv2 = UIImageView(image: UIImage(named: "FAQ_logo2"))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .new_backgroundColor
        
        view.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(280)
        }
        
        navBar.backgroundColor = .clear
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.kStatusBarHeight + Constants.kNavHeight)
        }
        
        let titleLb = UILabel.with(textColor: .black, boldFontSize: 34, defaultText: "客服留言")
        titleLb.textAlignment = .left
        navBar.addSubview(titleLb)
        titleLb.snp.makeConstraints { make in
            make.left.equalTo(52)
            make.bottom.equalToSuperview()
            make.height.equalTo(Constants.kNavHeight)
            make.width.equalTo(100)
        }

        view.addSubview(customerView)
        customerView.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            make.height.equalTo(60 + Constants.kScreenBottomInset)
            make.bottom.equalToSuperview()
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.left.right.equalTo(view)
            make.bottom.equalTo(customerView.snp.top)
        }
        
        view.addSubview(logoIv1)
        logoIv1.snp.makeConstraints { make in
            make.top.equalTo(Constants.kStatusBarHeight + 52)
            make.right.equalTo(-12)
            make.width.equalTo(110)
            make.height.equalTo(42)
        }
        
        view.addSubview(logoIv2)
        logoIv2.snp.makeConstraints { make in
            make.top.equalTo(Constants.kStatusBarHeight)
            make.right.equalTo(-12)
            make.width.equalTo(100)
            make.height.equalTo(67)
        }
        
        self.viewModel.requestFaqs.onNext(())
    }

    func setupHeaderView(faqs: [FAQEnvelope.FAQ]) {
        headerView.configureWith(faqs: faqs)
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        headerView.frame = CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: height)
        tableView.tableHeaderView = headerView
    }
    
    override func bindViewModels() {
        super.bindViewModels()
        
        self.viewModel.faqEnvelope.subscribe(onNext: { [weak self] env in
            guard let sSelf = self else { return }
            sSelf.faqs.removeAll()
            var headerFaqs = [FAQEnvelope.FAQ]()
            for (index, faq) in env.faq.enumerated() {
                if index == 0 || index == 1 {
                    headerFaqs.append(faq)
                }else {
                    let faq = FAQEnvelope.FAQ(question: faq.question, answer: faq.answer, isFold: true)
                    sSelf.faqs.append(faq)
                }
            }
            sSelf.setupHeaderView(faqs: headerFaqs)
            sSelf.tableView.reloadData()
        }).disposed(by: disposeBag)

        self.customerView.rx.buttonTap
            .asDriver()
            .drive(onNext: { [weak self] in
                let cv = ChatViewControlelr()
                self?.navigationController?.pushViewController(cv, animated: true)
            })
        	.disposed(by: disposeBag)
    }
}

extension FAQViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return faqs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FAQTableViewCellReusableIdentifier, for: indexPath) as! FAQTableViewCell
        cell.configureWith(faq: faqs[indexPath.row], isFirst: indexPath.row == 0, isLast: indexPath.row == faqs.count-1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var faq = faqs[indexPath.row]
        guard let isFold = faq.isFold else { return }
        faq.isFold = !isFold
        self.faqs[indexPath.row] = faq
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        if contentOffsetY <= 0 { // 下拉
            tableView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: 0), animated: false)
            tableView.bounces = false
            navBar.backgroundColor = .clear
            bgView.isHidden = false
            logoIv1.isHidden = false
            logoIv2.isHidden = false
        } else { // 上拉
            tableView.bounces = true
            navBar.backgroundColor = .white
            bgView.isHidden = true
            logoIv1.isHidden = true
            logoIv2.isHidden = true
        }
    }
}
