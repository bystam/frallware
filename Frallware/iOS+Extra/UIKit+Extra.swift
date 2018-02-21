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
