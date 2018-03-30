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

public extension NetworkCall where Self: JSONRequestCall {

    var bodyMimeType: String? {
        return "application/json"
    }

    var bodyData: Data? {
        return try? bodyEncoder.encode(body)
    }
}


// MARK: - JSON response

public protocol JSONResponseCall {

    associatedtype ResponseBody: Decodable

    var bodyDecoder: JSONDecoder { get }
}

public extension JSONResponseCall {

    var bodyDecoder: JSONDecoder {
        return JSONDecoder()
    }
}

public extension NetworkTask where C: JSONResponseCall {

    func onResponse(_ handler: @escaping (C.ResponseBody) -> Void) -> NetworkTask<C> {
        let call = self.call
        return self.onData { data in
            let decoded = try call.bodyDecoder.decode(C.ResponseBody.self, from: data)
            handler(decoded)
        }
    }
}
