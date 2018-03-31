//.
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation

// MARK: - Relative Network Call

public protocol RelativeNetworkCall: NetworkCall {

    var baseURL: URL { get }

    var path: String { get }
    var queryParameters: [String : String] { get }

}

public extension RelativeNetworkCall {

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

    var queryParameters: [String : String] {
        return [:]
    }
}


// MARK: - Typed Response

public protocol TypedResponseNetworkCall: NetworkCall {
    associatedtype ResponseBody

    func decodeResponse(from data: Data) throws -> ResponseBody
}


// MARK: - JSON request

public protocol JSONRequestCall: NetworkCall {

    associatedtype RequestBody: Encodable

    var body: RequestBody { get }
    var bodyEncoder: JSONEncoder { get }
}

public extension JSONRequestCall {

    var bodyEncoder: JSONEncoder {
        return JSONEncoder()
    }
}

public extension JSONRequestCall {

    var bodyMimeType: String? {
        return "application/json"
    }

    var bodyData: Data? {
        return try? bodyEncoder.encode(body)
    }
}


// MARK: - JSON response

public protocol JSONResponseCall: TypedResponseNetworkCall where ResponseBody: Decodable {
    var bodyDecoder: JSONDecoder { get }
}

public extension JSONResponseCall {

    var bodyDecoder: JSONDecoder {
        return JSONDecoder()
    }

    func decodeResponse(from data: Data) throws -> ResponseBody {
        return try bodyDecoder.decode(ResponseBody.self, from: data)
    }
}
