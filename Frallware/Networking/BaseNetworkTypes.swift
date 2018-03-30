//
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public protocol NetworkCall {

    var method: HTTPMethod { get }
    var url: URL { get }

    var httpHeaders: [String : String] { get }

    var bodyMimeType: String? { get }
    var bodyData: Data? { get }
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
}
