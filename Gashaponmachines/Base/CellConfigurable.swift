protocol ConfigurableCell {
    associatedtype ModelType
    func configure(with data: ModelType)
}

protocol CellConfigurator {

    static var reuseId: String { get }
    func configure(cell: BaseTableViewCell)
}

class TableCellConfigurator<CellType: ConfigurableCell, ModelType>: CellConfigurator
where CellType.ModelType == ModelType, CellType: UITableViewCell {
    static var reuseId: String { return String(describing: CellType.self) }

    func configure(cell: BaseTableViewCell) {

    }

}
