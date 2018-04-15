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


public protocol NetworkCall {

    var method: HTTPMethod { get }
    var url: URL { get }
    var httpHeaders: [String : String] { get }


    associatedtype RequestBody

    var bodyMimeType: String? { get }
    var body: RequestBody { get }
    func encode(body: RequestBody) -> Data?


    associatedtype ResponseBody

    func decodeError(from data: Data) -> Error?
    func decodeBody(from data: Data) throws -> ResponseBody
}

public extension NetworkCall {

    var httpHeaders: [String : String] {
        return [:]
    }

    func decodeError(from data: Data) -> Error? {
        return nil
    }
}
