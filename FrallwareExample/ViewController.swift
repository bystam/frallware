//
//  Copyright © 2018 Frallware. All rights reserved.
//

import UIKit
import Frallware

class ViewController: UIViewController {

    private let client = NetworkClient()

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        view.addGestureRecognizer(tap)

        loadRandomFox()
    }

    @objc private func didTap() {
        loadRandomFox()
    }

    private func loadRandomFox() {
        let call = RandomFoxCall()
        client.request(call).onResponse { result in
            switch result {
            case .success(let response):
                self.loadImage(at: response.image)
            case .error(let error):
                print(error)
            }
        }.start()
    }

    private func loadImage(at url: URL) {
        let call = FetchImageCall(url: url)
        client.request(call).onData { result in
            switch result {
            case .success(let data):
                self.setImage(UIImage(data: data))
            case .error(let error):
                print(error)
            }
        }.start()
    }

    private func setImage(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
}
