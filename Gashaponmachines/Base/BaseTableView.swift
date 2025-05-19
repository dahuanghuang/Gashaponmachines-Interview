class BaseTableView: UITableView {

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        showsVerticalScrollIndicator = false
        backgroundColor = .new_backgroundColor
        separatorStyle = .none

        if DeviceType.IS_IPHONE_X_OR_XS {
            if #available(iOS 11.0, *) {
                contentInsetAdjustmentBehavior = .automatic
            } else {

            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
