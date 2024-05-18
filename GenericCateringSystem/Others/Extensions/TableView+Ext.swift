//
//  TableView+Ext.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/18.
//

import UIKit
import SwiftUI

extension UITableView {
    func noData(msg: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = msg
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }
    
    func clearBackgroundView() {
        self.backgroundView = nil
        self.separatorStyle = .none
    }
}
