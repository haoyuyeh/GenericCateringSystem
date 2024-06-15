//
//  CustomerOptionCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/6/15.
//
import OSLog
import UIKit
import CoreData

class CustomerOptionCell: UICollectionViewCell {
    // MARK: Properties
    private let logger = Logger(subsystem: "Customer", category: "CustomerOptionCell")
    var option: Option?
    var delegate: CustomerOptionCellDelegate?
    
    // MARK: IBOutlet

    @IBOutlet weak var optionImg: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var unitPrice: UILabel!
    
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var minusBtn: UIButton!
    
    @IBOutlet weak var addItemBtn: UIButton!
    
    
    
    // MARK: IBAction

    @IBAction func plusBtnPressed(_ sender: UIButton) {
        let quantity = Int(self.quantity.text ?? "1")
        
        self.quantity.text = String(quantity! + 1)
    }
    
    @IBAction func minusBtnPressed(_ sender: UIButton) {
        let quantity = Int(self.quantity.text ?? "1")

        guard quantity! > 1 else {
            return
        }
        
        self.quantity.text = String(quantity! - 1)
    }
    
    @IBAction func addItemBtnPressed(_ sender: UIButton) {
        let quantity = Int(self.quantity.text ?? "1")
        
        delegate?.addItem(of: option!, quantity: quantity!)
    }
    
}

// MARK: CellConfig
extension CustomerOptionCell: CellConfig {
    func configure<T>(with target: NSManagedObject, of cellType: T.Type) {
//        optionImg.image =
        name.text = option!.name
        unitPrice.text = "$\(String(option!.price))"
        quantity.text = "1"
    }
}
