//  测试协议跳转

/*
<a href="yqnd://yqnd.quqqi.com/Game/A02?type=1">跳转到机台主页</a >
<a href="yqnd://yqnd.quqqi.com/Recharge">跳转到充值页</a >
<a href="yqnd://yqnd.quqqi.com/MallCategory/5a9f601f6d52424a4a0b1ada">跳转到兑换商城某分类下商品列表页</a >
<a href="yqnd://yqnd.quqqi.com/MallProduct/5c81d94761da070033957224">跳转到兑换商城某商品页</a >
<a href="yqnd://yqnd.quqqi.com/Invitation">跳转到邀请好友页面</a >
<a href="yqnd://yqnd.quqqi.com/EggExchange">跳转到兑换蛋壳页面</a >
<a href="yqnd://yqnd.quqqi.com/Login">跳转到登录页面</a >
<a href="yqnd://yqnd.quqqi.com/Collection/5ce230a3485a170033ebbff3">跳转到合集展示页面</a >
<a href="yqnd://yqnd.quqqi.com/DistinctExchangeRecord">跳转到喜好兑换物品页面</a >
<a href="yqnd://yqnd.quqqi.com/EggProduct">跳转到蛋槽页面</a >
<a href="yqnd://yqnd.quqqi.com/ShipList/10">跳转到发货记录页面 -- 未发货</a >
<a href="yqnd://yqnd.quqqi.com/ShipList/20">跳转到发货记录页面 -- 已发货</a >
<a href="yqnd://yqnd.quqqi.com/ShipList/25">跳转到发货记录页面 -- 已完成</a >
<a href="yqnd://yqnd.quqqi.com/RechargeRecord">跳转到充值记录（元气明细）页面</a >
<a href="yqnd://yqnd.quqqi.com/EggPointRecord">跳转到蛋壳明细页面</a >
<a href="yqnd://yqnd.quqqi.com/Compose">跳转到合成主页</a >
<a href="yqnd://yqnd.quqqi.com/ComposePath/5ea1477631e3330035a37558">跳转到某商品合成页</a >
<a href="yqnd://yqnd.quqqi.com/OnePiece">在售元气赏列表</a >
<a href="yqnd://yqnd.quqqi.com/OnePieceMyList">我的元气赏列表</a >
<a href="yqnd://yqnd.quqqi.com/OnePiecePlayHistory">元气赏购买记录</a >
<a href="yqnd://yqnd.quqqi.com/OnePieceGameDetail/5ea7d707dcbce1003656b407">元气赏游戏详情页</a >
<a href="yqnd://yqnd.quqqi.com/OnePieceLiveDetail/5ea7d707dcbce1003656b407">元气赏游戏开奖页</a >
<a href="yqnd://yqnd.quqqi.com/OnePieceEggProduct">蛋槽-元气赏展架</a >
<a href="yqnd://yqnd.quqqi.com/MachineTopic/5e16fbe6ed5d800036c56763">专题列表</a >
<a href="yqnd://yqnd.quqqi.com/Mall">兑换商城</a >
<a href="yqnd://yqnd.quqqi.com/Conversation">客服留言</a >
<a href="yqnd://yqnd.quqqi.com/Invitation">邀请送元气</a >
<a href="yqnd://yqnd.quqqi.com/Promocode">兑换码</a >
<a href="yqnd://yqnd.quqqi.com/Coupons">优惠券</a >
<a href="yqnd://yqnd.quqqi.com/AddressConfig">地址管理</a >
<a href="yqnd://yqnd.quqqi.com/LogReport">上传日志</a >
<a href="yqnd://yqnd.quqqi.com/ChangeEnv">切换环境</a >
*/

import UIKit

class TestProtocolPopViewController: BaseViewController {

    let titleLabel = UILabel.with(textColor: .qu_black, fontSize: 28)

    lazy var closeButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .black
        btn.setTitle("关闭", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
        blackView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.bottom.equalTo(-100)
            make.left.equalTo(50)
            make.right.equalTo(-50)
        }

        let webVc = WKWebViewController(url: URL(string: "https://nd.quqqi.com/#/liubin")!, headers: [:])
        self.addChild(webVc)
        contentView.addSubview(webVc.view)
        webVc.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        webVc.routerHandle = { [weak self] in
            self?.dismissVC()
        }

        closeButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        contentView.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
        }
    }

    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}
