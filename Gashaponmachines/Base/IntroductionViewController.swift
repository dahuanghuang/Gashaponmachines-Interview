import Foundation

class IntroductionViewController: AnimatedPagingScrollViewController {

    private var isShowHomeVc = false

    private let blue = UIColor.UIColorFromRGB(0x3d90ee)
    private let green = UIColor.UIColorFromRGB(0xa8e96b)
    private let yellow = UIColor.UIColorFromRGB(0xffd713)

    lazy var pageControl: UIPageControl = {
       	let pc = UIPageControl()
        pc.numberOfPages = self.numberOfPages()
        pc.currentPage = 0
        pc.pageIndicatorTintColor = UIColor.UIColorFromRGB(0xffffff, alpha: 0.6)
        pc.currentPageIndicatorTintColor = .white
        return pc
    }()

    private var lastContentOffset: CGFloat = 0

    override func numberOfPages() -> Int {
        return 3
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let bg = [blue, green, yellow]
       	let ivs = [UIImageView.with(imageName: "slide_1"), UIImageView.with(imageName: "slide_2"), UIImageView.with(imageName: "slide_3")]
        for (index, iv) in ivs.enumerated() {

            let view = UIView.withBackgounrdColor(bg[index])
            self.contentView.addSubview(view)
            view.snp.makeConstraints { make in
            	make.width.equalTo(Constants.kScreenWidth)
                make.height.equalTo(Constants.kScreenHeight)
                make.centerX.equalTo(self.scrollView).offset(Constants.kScreenWidth * CGFloat(index))
                make.centerY.equalTo(self.contentView)
            }

            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            self.contentView.addSubview(iv)

            iv.snp.makeConstraints { make in
                make.centerX.equalTo(self.scrollView).offset(Constants.kScreenWidth * CGFloat(index))
                make.centerY.equalTo(self.contentView)
                make.height.equalTo(Constants.kScreenWidth * iv.image!.size.height / iv.image!.size.width)
                make.width.equalTo(Constants.kScreenWidth)
            }
        }

        self.view.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.height.equalTo(6)
            make.width.equalTo(50)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view.safeArea.bottom).offset(-10)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)

        self.animator.animate(scrollView.contentOffset.x)

        let pageWidth = self.scrollView.width
        let fractionPage = self.scrollView.contentOffset.x / pageWidth
        let page = lround(Double(fractionPage))
    	self.pageControl.currentPage = page
        if self.lastContentOffset > scrollView.contentOffset.x && !self.scrollView.isDragging && self.pageControl.currentPage == 2 {
            showMainView()
        }
        self.lastContentOffset = scrollView.contentOffset.x
    }

    func showMainView() {
        if isShowHomeVc {
            return
        }
        isShowHomeVc = true
        UIApplication.shared.keyWindow?.rootViewController = MainViewController()
    }
}
