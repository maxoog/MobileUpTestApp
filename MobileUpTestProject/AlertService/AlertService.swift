import Foundation
import UIKit

class AlertService {
    static func networkAlert(in controller: UIViewController) {
        let alert = UIAlertController(title: "The internet connection is unstable, try to connect later", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "try later", style: .default))
        DispatchQueue.main.async {
            controller.present(alert, animated: true)
        }
    }
}
