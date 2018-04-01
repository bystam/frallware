//
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation
import Frallware

struct RandomFoxCall: NetworkCall, VoidRequestBodied, JSONResponseBodied {

    struct ResponseBody: Decodable {
        let image: URL
        let link: URL
    }

    let url: URL = URL(string: "https://randomfox.ca/floof")!
    let method: HTTPMethod = .get
}
