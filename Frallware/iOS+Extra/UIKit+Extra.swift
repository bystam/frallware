//
//  Copyright © 2018 Frallware. All rights reserved.
//

import UIKit

public protocol NibBased {
    static var nib: UINib { get }
}

public extension NibBased {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
}

public extension NibBased where Self: UITableViewCell {

    static func registerAsNib(in tableView: UITableView) {
        tableView.register(nib, forCellReuseIdentifier: defaultReuseIdentifier)
    }
}

private extension UITableViewCell {

    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}

public extension UITableView {

    func dequeueCell<C: UITableViewCell>(type: C.Type, at indexPath: IndexPath) -> C {
        return dequeueReusableCell(withIdentifier: type.defaultReuseIdentifier, for: indexPath) as! C
    }
}
