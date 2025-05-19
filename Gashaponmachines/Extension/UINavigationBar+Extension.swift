extension UINavigationController {
    var storedNavigationBar: UINavigationBar {
        return self.value(forKey: "navigationBar") as! UINavigationBar
    }

    func updateNavigationTitleColor(_ color: UIColor) {
        let textAttributes = [NSAttributedString.Key.foregroundColor: color]
        self.navigationBar.titleTextAttributes = textAttributes
    }
}
