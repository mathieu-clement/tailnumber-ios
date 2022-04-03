//
// Created by Mathieu Clement on 02.04.22.
//

import Foundation
import SwiftUI

class Commons {

//    static let shared = Commons()

    static func alert(title: String, message: String, onDismiss: @escaping () -> Void?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                onDismiss()
            }))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
        }
    }
}