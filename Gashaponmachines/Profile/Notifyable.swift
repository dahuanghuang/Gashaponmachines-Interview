protocol Notifyable {

    func updateUnreadNotificationCount(_ count: Int)
}

extension MainViewController: Notifyable {

    func updateUnreadNotificationCount(_ count: Int) {
        self.viewControllers?.last?.tabBarItem.badgeValue = count > 0 ? "" : nil
    }
}
