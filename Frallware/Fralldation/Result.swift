//
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T)
    case error(Error)

    public func map<R>(_ transform: (T) throws -> R) -> Result<R> {
        switch self {
        case .success(let value):
            do {
                let value = try transform(value)
                return .success(value)
            } catch let error {
                return .error(error)
            }
        case .error(let error):
            return .error(error)
        }
    }
}
