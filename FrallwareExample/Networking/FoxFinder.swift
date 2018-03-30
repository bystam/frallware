//
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation
import Frallware

protocol FoxFinderCall: RelativeNetworkCall {
    
}

extension FoxFinderCall {
    var baseURL: URL {
        return URL(string: "https://randomfox.ca")!
    }
}


struct RandomFoxCall: FoxFinderCall, JSONResponseCall {

    struct ResponseBody: Decodable {
        let image: URL
        let link: URL
    }

    let path: String = "/floof"
    let method: HTTPMethod = .get
    let queryParameters: [String : String] = [:]
}

