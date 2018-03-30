//
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

public protocol NetworkErrorMiddleware {

    func decodeError(from data: Data) -> Error?

}

public protocol NetworkCall {

    var method: HTTPMethod { get }
    var url: URL { get }

    var httpHeaders: [String : String] { get }

    var bodyMimeType: String? { get }
    var bodyData: Data? { get }

    var errorMiddleware: NetworkErrorMiddleware? { get }
}

public extension NetworkCall {

    var httpHeaders: [String : String] {
        return [:]
    }

    var bodyMimeType: String? {
        return nil
    }

    var bodyData: Data? {
        return nil
    }

    var errorMiddleware: NetworkErrorMiddleware? {
        return nil
    }
}
