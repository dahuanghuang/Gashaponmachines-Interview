import UIKit

class YiFanShangDetailTicketView: UIView {
    
    let lookButton = UIButton()
    
    let myTicketCountLb = UILabel.numberFont(size: 20)
    
    var ticketIvs = [UIImageView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        self.backgroundColor = .clear
        
        let contentView = UIView.withBackgounrdColor(UIColor(hex: "FFF2F3")!)
        contentView.layer.cornerRadius = 12
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(11)
            make.left.right.bottom.equalToSuperview()
        }
        
        let logoIv = UIImageView(image: UIImage(named: "yfs_detail_ticket"))
        contentView.addSubview(logoIv)
        logoIv.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.left.equalToSuperview()
            make.size.equalTo(40)
        }
        
        let topContaier = UIView.withBackgounrdColor(.clear)
        contentView.addSubview(topContaier)
        topContaier.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(42)
        }
        
        let myTicketLb = UILabel.with(textColor: .black, boldFontSize: 28, defaultText: "我的券")
        topContaier.addSubview(myTicketLb)
        myTicketLb.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
        }
        
        myTicketCountLb.textColor = UIColor(hex: "FF4B6B")
        topContaier.addSubview(myTicketCountLb)
        myTicketCountLb.snp.makeConstraints { make in
            make.left.equalTo(myTicketLb.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }
        
        let lookIv = UIImageView(image: UIImage(named: "yfs_detail_ticket_lookmore"))
        topContaier.addSubview(lookIv)
        lookIv.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        
        let lookLb = UILabel.with(textColor: UIColor(hex: "FF7C74")!, fontSize: 20, defaultText: "查看全部")
        topContaier.addSubview(lookLb)
        lookLb.snp.makeConstraints { make in
            make.right.equalTo(lookIv.snp.left)
            make.centerY.equalToSuperview()
        }
        
        topContaier.addSubview(lookButton)
        lookButton.snp.makeConstraints { make in
            make.right.centerY.height.equalToSuperview()
            make.left.equalTo(lookLb)
        }
        
        let ticketWH: CGFloat = 59.0
        let ticketMargin = (Constants.kScreenWidth - 48.0 - ticketWH*5)/4
        for index in 0...4 {
            let ticketIv = UIImageView(image: UIImage(named: "yfs_ticket_0"))
            contentView.addSubview(ticketIv)
            ticketIv.snp.makeConstraints { make in
                make.left.equalTo(12 + (ticketWH + ticketMargin) * CGFloat(index))
                make.top.equalTo(topContaier.snp.bottom).offset(8)
                make.size.equalTo(ticketWH)
            }
            ticketIvs.append(ticketIv)
        }
    }
    
    func configWith(env: YiFanShangDetailEnvelope) {
        myTicketCountLb.text = env.ownTicketsCount
        
        if let ownYfsTickets = env.ownTickets {

            var allTickets = [Ticket]()

            // 合并元气赏券
            for number in ownYfsTickets {
                let ticket = Ticket(isMagic: false, number: number)
                allTickets.append(ticket)
            }

            // 合并魔法阵券
            if let ownMagicTickets = env.magicDetail?.ownMagicTickets {
                for number in ownMagicTickets {
                    let ticket = Ticket(isMagic: true, number: number)
                    allTickets.append(ticket)
                }
            }

            // 展示
            zip(allTickets, ticketIvs).forEach { (ticket, iv) in
                if let number = ticket.number {
                    if ticket.isMagic {
                        iv.image = UIImage(named: "yfs_magic_ticket_\(number)")
                    } else {
                        iv.image = UIImage(named: "yfs_ticket_\(number)")
                    }
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
