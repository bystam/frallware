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
    var headers: [String : String] { get }

}

public protocol NetworkBodyCall: NetworkCall {

    var bodyMimeType: String? { get }
    var bodyData: Data? { get }

}
