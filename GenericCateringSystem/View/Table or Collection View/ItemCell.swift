//
//  ItemCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/3/26.
//
import OSLog
import UIKit
import CoreData

class ItemCell: UITableViewCell {
    // MARK: Properties
    private let logger = Logger(subsystem: "Table or Collection View", category: "ItemCell")
    
    var delegate: TextFieldChangedDelegate?
    var item: Item?
    var indexPath: IndexPath?
    // MARK: IBOutlet

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var unitPrice: UILabel!
    @IBOutlet weak var quantity: UITextField!
    // MARK: IBAction

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
    func configure<T>(with target: NSManagedObject, of classType: T.Type) {
        item = (target as! Item)
        
        switch classType {
        case is MenuVC.Type, is TableOrderDetailVC.Type:
            quantity.isEnabled = true
            name.text = item!.name
            unitPrice.text = "$\(String(item!.price))"
            quantity.text = "\(String(item!.quantity))"
            
        case is OrderDetailVC.Type:
            quantity.isEnabled = false
            name.text = "\(item!.name ?? "nil") ( \(item!.quantity) )"
            quantity.text = "\(item!.quantity - item!.served) Left"
            
        case is KitchenControllCenterVC.Type, is KitchenPositionVC.Type:
            quantity.isEnabled = false
            name.text = "   -\(item!.name ?? "nil") ( \(item!.quantity) )"
            quantity.text = "\(item!.quantity - item!.served) Left"
            
        default:
            quantity.isEnabled = false
            name.text = item!.name
            unitPrice.text = "$\(String(item!.price))"
            quantity.text = "\(String(item!.quantity))"
        }
        
        
        
        
        
//        if (classType.self == MenuVC.self) || (classType.self == TableOrderDetailVC.self) || (classType.self == OrderingVC.self) {
//            quantity.isEnabled = true
//        }else {
//            quantity.isEnabled = false
//        }
//        if (classType == OrderDetailVC.self) || (classType == KitchenControllCenterVC.self) || (classType == KitchenPositionVC.self) {
//            name.text = "   -\(item!.name ?? "nil") ( \(item!.quantity) )"
//            quantity.text = "\(item!.quantity - item!.served) Left"
//        }else {
//            name.text = item!.name
//            unitPrice.text = "$\(String(item!.price))"
//            quantity.text = "\(String(item!.quantity))"
//        }
    }
}
