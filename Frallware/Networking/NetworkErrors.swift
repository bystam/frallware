//
//  Copyright © 2018 Frallware. All rights reserved.
//

import Foundation

struct MissingBodyError: Error {

    let url: URL?

    var localizedDescription: String {
        guard let url = url else {
            return "Response body was empty"
        }
        return "Response body was empty for URL: \(url)"
    }
}
