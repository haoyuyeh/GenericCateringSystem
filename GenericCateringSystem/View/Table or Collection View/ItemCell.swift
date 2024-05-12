//
//  ItemCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/3/26.
//

import UIKit
import CoreData

class ItemCell: UITableViewCell {
    
    var delegate: ItemQuantityDelegate?
    var indexPath: IndexPath?
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var unitPrice: UILabel!
    @IBOutlet weak var quantity: UITextField!
    
    @IBAction func itemQuantityChanged(_ sender: UITextField) {
        if let text = sender.text {
            if !text.isMatch(pattern: "^[\\d]+$") {
                sender.text = "1"
            }
        }else {
            sender.text = "1"
        }
        delegate?.itemQuantityChanged(to: Int(sender.text!)!,
                                      of: indexPath!)
    }
}

// MARK: CellConfig
extension ItemCell: CellConfig {
    func configure<T>(with target: NSManagedObject, of cellType: T.Type) {
        let target = target as! Item

        if cellType.self == MenuVC.self || cellType.self == TableOrderDetailVC.self {
            quantity.isEnabled = true
        }else {
            quantity.isEnabled = false
        }
        
        name.text = target.name
        unitPrice.text = "$\(String(target.price))"
        quantity.text = "\(String(target.quantity))"
    }
}
