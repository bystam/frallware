//
//  Copyright © 2018 Frallware. All rights reserved.
//

import UIKit

public extension UITableViewCell {

    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }

    public static func register(in tableView: UITableView) {
        tableView.register(self, forCellReuseIdentifier: defaultReuseIdentifier)
    }
}


public extension UITableView {

    public func dequeueCell<C: UITableViewCell>(type: C.Type, at indexPath: IndexPath) -> C {
        return dequeueReusableCell(withIdentifier: type.defaultReuseIdentifier, for: indexPath) as! C
    }
}


public extension NSLayoutConstraint {

    static func fill(_ view: UIView, inside container: UIView, with insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        return [
            view.topAnchor.constraint(equalTo: container.topAnchor, constant: insets.top),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -insets.right),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -insets.bottom),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: insets.left)
        ]
    }

}
