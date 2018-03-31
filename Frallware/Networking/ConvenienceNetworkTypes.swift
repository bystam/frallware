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


// MARK: - JSON request

public protocol JSONRequestNetworkCall: NetworkCall {

    associatedtype RequestBody: Encodable

    var body: RequestBody { get }
    var bodyEncoder: JSONEncoder { get }
}

public extension JSONRequestNetworkCall {

    var bodyEncoder: JSONEncoder {
        return JSONEncoder()
    }
}

public extension JSONRequestNetworkCall {

    var bodyMimeType: String? {
        return "application/json"
    }

    var bodyData: Data? {
        return try? bodyEncoder.encode(body)
    }
}


// MARK: - Typed Response

public protocol TypedResponseNetworkCall: NetworkCall {
    associatedtype ResponseBody

    func decodeResponse(from data: Data) throws -> ResponseBody
}


// MARK: - Data response

public protocol DataResponseNetworkCall: NetworkCall {
    typealias ResponseBody = Data
}

public extension DataResponseNetworkCall {
    func decodeResponse(from data: Data) throws -> Data {
        return data
    }
}


// MARK: - JSON response

public protocol JSONResponseNetworkCall: TypedResponseNetworkCall where ResponseBody: Decodable {
    var bodyDecoder: JSONDecoder { get }
}

public extension JSONResponseNetworkCall {

    var bodyDecoder: JSONDecoder {
        return JSONDecoder()
    }

    func decodeResponse(from data: Data) throws -> ResponseBody {
        return try bodyDecoder.decode(ResponseBody.self, from: data)
    }
}
