//.
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

public extension NetworkCall {

    var headers: [String : String] {
        return [:]
    }
}


public protocol JSONRequestCall {

    associatedtype RequestBody: Encodable

    var body: RequestBody { get }
    var bodyEncoder: JSONEncoder { get }
}

public extension JSONRequestCall {

    var bodyEncoder: JSONEncoder {
        return JSONEncoder()
    }
}


public protocol JSONResponseCall {

    associatedtype ResponseBody: Decodable

    var bodyDecoder: JSONDecoder { get }
}

public extension JSONResponseCall {

    var bodyDecoder: JSONDecoder {
        return JSONDecoder()
    }
}


public protocol RelativeNetworkCall: NetworkCall {

    var baseURL: URL { get }

    var path: String { get }
    var queryParameters: [String : String] { get }

}

extension RelativeNetworkCall {

    var url: URL {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            return baseURL
        }
        components.path += path
        if !queryParameters.isEmpty {
            components.queryItems = queryParameters.map { key, value -> URLQueryItem in
                return URLQueryItem(name: key, value: value)
            }
        }
        return components.url ?? baseURL
    }
}
