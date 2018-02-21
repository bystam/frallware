//
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation

public protocol ServiceContainer {
    func service<T>(ofType type: T.Type) -> Any
}

public enum Service {

    private static var container: ServiceContainer!

    public static func install(container: ServiceContainer) {
        self.container = container
    }

    public static func find<T>(type: T.Type) -> T {
        // Force downcast here
        return container.service(ofType: type) as! T
    }
}

