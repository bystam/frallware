//
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T)
    case failure(Error)

    public var value: T? {
        if case .success(let value) = self {
            return value
        }
        return nil
    }

    public var error: Error? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }

    public func map<R>(_ transform: (T) throws -> R) -> Result<R> {
        switch self {
        case .success(let value):
            do {
                let value = try transform(value)
                return .success(value)
            } catch let error {
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}
