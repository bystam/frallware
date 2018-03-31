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


// MARK: - Void request

public protocol VoidRequestNetworkCall: NetworkCall where RequestBody == Void {
}

public extension VoidRequestNetworkCall {

    var body: Void {
        return ()
    }

    var bodyMimeType: String? {
        return nil
    }

    func encode(body: RequestBody) -> Data? {
        return nil
    }
}

// MARK: - Void request

public protocol DataRequestNetworkCall: NetworkCall where RequestBody == Data {
}

public extension DataRequestNetworkCall {

    var bodyMimeType: String? {
        return "application/octet-stream"
    }

    func encode(body: Data) -> Data? {
        return body
    }
}


// MARK: - JSON request

public protocol JSONRequestNetworkCall: NetworkCall where RequestBody: Encodable {

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

    public func encode(body: RequestBody) -> Data? {
        return try? bodyEncoder.encode(body)
    }
}


// MARK: - Void response

public protocol VoidResponseNetworkCall: NetworkCall where ResponseBody == Void {
}

public extension DataResponseNetworkCall {
    func decodeResponse(from data: Data) throws -> Void {
        return ()
    }
}


// MARK: - Data response

public protocol DataResponseNetworkCall: NetworkCall where ResponseBody == Data {
}

public extension DataResponseNetworkCall {
    func decodeResponse(from data: Data) throws -> Data {
        return data
    }
}


// MARK: - JSON response

public protocol JSONResponseNetworkCall: NetworkCall where ResponseBody: Decodable {
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
