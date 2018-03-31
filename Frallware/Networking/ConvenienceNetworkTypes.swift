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

public protocol VoidRequestBodied {}

public extension VoidRequestBodied where Self: NetworkCall {

    typealias RequestBody = Void

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

public protocol DataRequestBodied {}

public extension DataRequestBodied where Self: NetworkCall {

    typealias RequestBody = Data

    var bodyMimeType: String? {
        return "application/octet-stream"
    }

    func encode(body: Data) -> Data? {
        return body
    }
}


// MARK: - JSON request

public protocol JSONRequestBodied {

    var bodyEncoder: JSONEncoder { get }
}

public extension JSONRequestBodied {

    var bodyEncoder: JSONEncoder {
        return JSONEncoder()
    }
}

public extension JSONRequestBodied where Self: NetworkCall, Self.RequestBody: Encodable {

    var bodyMimeType: String? {
        return "application/json"
    }

    public func encode(body: RequestBody) -> Data? {
        return try? bodyEncoder.encode(body)
    }
}


// MARK: - Void response

public protocol VoidResponseBodied {}

public extension VoidResponseBodied where Self: NetworkCall {

    typealias ResponseBody = Void

    func decodeResponse(from data: Data) throws -> Void {
        return ()
    }
}


// MARK: - Data response

public protocol DataResponseBodied {}

public extension DataResponseBodied where Self: NetworkCall {

    typealias ResponseBody = Data

    func decodeResponse(from data: Data) throws -> Data {
        return data
    }
}


// MARK: - JSON response

public protocol JSONResponseBodied {

    var bodyDecoder: JSONDecoder { get }
}

public extension JSONResponseBodied {

    var bodyDecoder: JSONDecoder {
        return JSONDecoder()
    }
}

public extension JSONResponseBodied where Self: NetworkCall, Self.ResponseBody: Decodable {

    func decodeResponse(from data: Data) throws -> ResponseBody {
        return try bodyDecoder.decode(ResponseBody.self, from: data)
    }
}
