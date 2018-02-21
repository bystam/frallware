//
//  Copyright © 2018 Frallware. All rights reserved.
//

import UIKit

public protocol NibBased: class {
    static var nibName: String { get }
}

public extension NibBased {

    public static var nibName: String {
        return String(describing: self)
    }

    public static var nib: UINib {
        return UINib(nibName: nibName, bundle: Bundle(for: self))
    }
}

public extension NibBased where Self: UIView {
    public static func create() -> Self {
        return Bundle(for: self)
            .loadNibNamed(nibName, owner: nil, options: [:])!
            .first as! Self
    }
}

public extension NibBased where Self: UITableViewCell {
    public static func registerAsNib(in tableView: UITableView) {
        tableView.register(nib, forCellReuseIdentifier: defaultReuseIdentifier)
    }
}


public protocol StoryboardBased: class {

    static var storyboardName: String { get }
    static var storyboardID: String? { get }

}

public extension StoryboardBased {

    public static var storyboardName: String {
        return String(describing: self)
    }

    public static var storyboardID: String? {
        return nil
    }

    public static var storyboard: UIStoryboard {
        return UIStoryboard(name: storyboardName, bundle: Bundle(for: self))
    }
}

public extension StoryboardBased where Self: UIViewController {

    public static func create() -> Self {
        if let id = storyboardID {
            return storyboard.instantiateViewController(withIdentifier: id) as! Self
        } else {
            return storyboard.instantiateInitialViewController() as! Self
        }
    }
}
