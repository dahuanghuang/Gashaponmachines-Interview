extension UIViewController {

    var topMostViewController: UIViewController {
        if let pres = self.presentedViewController {
            return pres.topMostViewController
        } else {
            return self
        }
    }

    func hideKeyboardWhenTappedOutside() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
