public class AddressListLocationPicker: UIView {

    var picker: UIPickerView {
        let picker = UIPickerView(frame: .zero)
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .white
        return picker
    }

    public var preSelectedProvinceCode: String? {
        didSet {
            self.selectedProvinceCode = preSelectedProvinceCode
        }
    }

    public var preSelectedCityCode: String? {
        didSet {
            self.selectedCityCode = preSelectedCityCode
        }
    }

    public var preSelectedDistrictCode: String? {
        didSet {
            self.selectedDistrictCode = preSelectedDistrictCode
        }
    }

    private var selectedProvinceCode: String? {
        didSet {
            cities.removeAll()

        }
    }

    public var selectedCityCode: String? {
        didSet {

        }
    }

    public var selectedDistrictCode: String? {
        didSet {

        }
    }

    private let provinces: [String] = ["北京", "天津", "河北", "山西", "内蒙古", "辽宁", "吉林", "黑龙江", "上海", "江苏", "浙江", "安徽", "福建", "江西", "山东", "河南", "湖北", "湖南", "广东", "广西", "海南", "重庆", "四川", "贵州", "云南", "西藏", "陕西", "甘肃", "青海", "宁夏", "新疆", "台湾", "香港", "澳门"]
    private var cities: [String] = []
    private var districts: [String] = []

    private var provinceCodeArray: [String] = []
    private var cityCodeArray: [String] = []
    private var districtCodeArray: [String] = []

    var data: [String: Any] {
        do {
            let filePath = Bundle.main.path(forResource: "area", ofType: "json")
            let data = try Data(contentsOf: URL(string: filePath!)!)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
            return json
        } catch {
            QLog.error(error.localizedDescription)
        }
        return [:]
    }

    var allProvinceCodes: [String] {
        var provinceCodes: [String] = []
        let array = self.data["province"] as! [[String: String]]
        for (index, ele) in array.enumerated() {
            for key in ele.keys where ele[key] == provinces[index] {
                provinceCodes.append(key)
            }
        }
		return provinceCodes
    }

    var result: [String: [[String: [String]]]] {
        let district = self.data["district"] as! [String: [[String: String]]]
        var res: [String: [[String: [String]]]] = [:]
        for provinceCode in allProvinceCodes {
            let tmpCities = self.data["city"] as! [String: [[String: String]]]
            let citiesArray = tmpCities[provinceCode]!

            var allCities: [[String: [String]]] = []
            for cityDic in citiesArray {
                let cities = cityDic.keys

                var subResult: [String: [String]] = [:]
                for city: String in cities {

                    var districts: [String] = []

                    for districtDic: [String: String] in district[city]! {

                        let district = districtDic.keys.first!
                        districts.append(district)
                    }

                    subResult[city] = districts
                }

                allCities.append(subResult)
            }

            res[provinceCode] = allCities
        }

        return res
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(picker)
        picker.snp.makeConstraints { make in
            make.width.bottom.centerX.equalTo(self)
            make.height.equalTo(200)
        }

        let toolBar = UIView()
        addSubview(toolBar)
        toolBar.snp.makeConstraints { make in
            make.width.top.left.right.equalTo(self)
            make.height.equalTo(48)
        }

        let cancelButton = UIButton.simpleTextButton(title: "取消")

        let doneButton = UIButton.simpleTextButton(title: "确定")

        let blankLabel = UILabel.with(textColor: .qu_black, fontSize: 30, defaultText: "请选择您所在区域")
        blankLabel.backgroundColor = .clear
        blankLabel.textAlignment = .center
        blankLabel.sizeToFit()

        toolBar.addSubview(cancelButton)
        toolBar.addSubview(doneButton)
        toolBar.addSubview(blankLabel)

        blankLabel.snp.makeConstraints { make in
            make.center.equalTo(toolBar)
        }

        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(toolBar)
            make.left.equalTo(toolBar).offset(10)
        }

        doneButton.snp.makeConstraints { make in
            make.centerY.equalTo(toolBar)
            make.right.equalTo(toolBar).offset(-10)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddressListLocationPicker: UIPickerViewDelegate, UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return self.provinces.count
        case 1:
            return self.cities.count
        case 2:
            return self.districts.count
        default:
            return 0
        }
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return self.provinces[row]
        case 1:
            return self.cities[row]
        case 2:
            if !self.districts.isEmpty {
                return self.districts[row]
            }
            return ""
        default:
            return ""
        }
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            if !provinceCodeArray.isEmpty {

            }
        default:
            break
        }
    }
}
