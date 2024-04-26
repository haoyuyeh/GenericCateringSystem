//
//  Viewcontroller+Ext.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/11/3.
//

import UIKit

extension UIViewController {
    /// pop up an alert to show a simple message and title
    /// - Parameters:
    ///   - title:
    ///   - msg: message to be showed
    func showAlert(alertTitle title: String, message msg:String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
