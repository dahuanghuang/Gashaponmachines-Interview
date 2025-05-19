import UIKit

protocol GameRecordDropDownViewDelegate: class {
    func didButtonClick(index: Int)
}

class GameRecordDropDownView: UIView {
    
    weak var delegate: GameRecordDropDownViewDelegate?
    
    /// 所有按钮
    var buttons = [UIButton]()
    
    /// 选中按钮
    var selectButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
    }
    
    func setupButtons(titles: [String]) {
        if titles.isEmpty { return }
        if !buttons.isEmpty { return }
        
        for index in 0..<titles.count {
            let title = titles[index]
            let button = UIButton()
            button.tag = index
            button.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
            button.setTitle(title, for: .normal)
            button.setTitleColor(.new_gray, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.backgroundColor = .white
            button.layer.cornerRadius = 3
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.new_backgroundColor.cgColor
            let row = CGFloat(index / 3)
            let col = CGFloat(index % 3)
            let width: CGFloat = (Constants.kScreenWidth - 64)/3
            let x: CGFloat = col * (width + 12) + 20
            let y: CGFloat = row * 44 + 12
            button.frame = CGRect(x: x, y: y, width: width, height: 28)
            self.addSubview(button)
            buttons.append(button)
            
            if index == 0 {
                button.setTitleColor(.black, for: .normal)
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
                button.backgroundColor = .new_yellow
                button.layer.borderColor = UIColor.white.cgColor
                self.selectButton = button
            }
        }
        
        let row = (titles.count / 3) + 1
        let h = CGFloat(44 * row + 12)
        self.height = h
    }
    
    @objc func buttonClick(button: UIButton) {
        
        selectButton.setTitleColor(.new_gray, for: .normal)
        selectButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        selectButton.backgroundColor = .white
        selectButton.layer.borderColor = UIColor.new_backgroundColor.cgColor
        
        selectButton = button
        
        selectButton.setTitleColor(.black, for: .normal)
        selectButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        selectButton.backgroundColor = .new_yellow
        selectButton.layer.borderColor = UIColor.white.cgColor
        
        self.isHidden = true
        
        self.delegate?.didButtonClick(index: button.tag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.roundCorners([.bottomLeft, .bottomRight], radius: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
