import UIKit

class SearchTopView: UIView {

    /// 清楚所有文字回调
    var clearAllTextHandle: (() -> Void)?

    /// 搜索点击回调
    var searchReturnHandle: ((String) -> Void)?
    
    /// 取消按钮
    lazy var cancelButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("取消", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        btn.setTitleColor(.qu_black, for: .normal)
        return btn
    }()
    
    /// 整体背景
    lazy var searchBgView: UIView = {
        let v = UIView.withBackgounrdColor(.white)
        v.layer.borderColor = UIColor.new_yellow.cgColor
        v.layer.borderWidth = 2
        v.layer.cornerRadius = 16
        return v
    }()
    
    /// 眼睛
    let searchIv = UIImageView(image: UIImage(named: "home_search"))

    /// 分割线
    let line = UIView.withBackgounrdColor(.qu_lightGray.alpha(0.3))

    /// 搜索框
    lazy var searchTextFiled: UITextField = {
        let tf = UITextField()
        tf.addTarget(self, action: #selector(textFieldTextDidChange(textFiled:)), for: .editingChanged)
        tf.delegate = self
        tf.returnKeyType = .search
        tf.clearButtonMode = .always
        tf.font = UIFont.systemFont(ofSize: 12)
        return tf
    }()
    
    /// 搜索按钮
    lazy var searchButton: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 16
        btn.backgroundColor = .new_bgYellow
        btn.setTitle("搜索", for: .normal)
        btn.setTitleColor(UIColor(hex: "754E00"), for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        btn.addTarget(self, action: #selector(searchButtonOnClick), for: .touchUpInside)
        return btn
    }()

    var placeholder: String = ""

    init(placeholder: String) {
        super.init(frame: .zero)

        self.backgroundColor = .white

        self.placeholder = placeholder

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.right.equalTo(-18)
            make.centerY.equalToSuperview()
        }
        
        addSubview(searchBgView)
        searchBgView.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(cancelButton.snp.left).offset(-18)
            make.centerY.equalTo(cancelButton)
            make.height.equalTo(32)
        }
        
        searchBgView.addSubview(searchIv)
        searchIv.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }
        
        searchBgView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalTo(searchIv.snp.right).offset(8)
            make.centerY.equalTo(searchIv)
            make.width.equalTo(1)
            make.height.equalTo(16)
        }
        
        searchBgView.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.centerY.right.height.equalToSuperview()
            make.width.equalTo(58)
        }
        
        searchTextFiled.attributedPlaceholder = NSAttributedString.init(string: placeholder, attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.qu_lightGray])
        searchBgView.addSubview(searchTextFiled)
        searchTextFiled.snp.makeConstraints { (make) in
            make.left.equalTo(line.snp.right).offset(8)
            make.right.equalTo(searchButton.snp.left).offset(-8)
            make.centerY.height.equalToSuperview()
        }
    }

    @objc func textFieldTextDidChange(textFiled: UITextField) {
        if !textFiled.hasText {
            if let handle = clearAllTextHandle {
                handle()
            }
        }
    }
    
    @objc func searchButtonOnClick() {
        if let handle = searchReturnHandle, let text = searchTextFiled.text {

            // 默认搜索
            if text.count == 0 || text == "" {
                if let placeHolder = searchTextFiled.placeholder {
                    handle(placeHolder)
                }
            }

            // 不支持一个字
            if text.count == 1 {
                HUD.showError(second: 1.0, text: "字数不能小于2位哦", completion: nil)
                return
            }

            handle(text)
        }
    }
}

extension SearchTopView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchButtonOnClick()
        return true
    }
}
