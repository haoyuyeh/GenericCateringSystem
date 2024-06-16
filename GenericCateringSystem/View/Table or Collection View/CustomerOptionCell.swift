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
        let quantity = Int(self.quantity.text!)
        
        self.quantity.text = String(quantity! + 1)
    }
    
    @IBAction func minusBtnPressed(_ sender: UIButton) {
        let quantity = Int(self.quantity.text!)

        guard quantity! > 1 else {
            return
        }
        
        self.quantity.text = String(quantity! - 1)
    }
    
    @IBAction func addItemBtnPressed(_ sender: UIButton) {
        let quantity = Int(self.quantity.text!)
        logger.debug("add: \(quantity!)")
        delegate?.addItem(of: option!, quantity: quantity!)
        hidePurchasPart()
    }
    
}

// MARK: Helper
extension CustomerOptionCell {
    func showPurchasPart() {
        plusBtn.isHidden = false
        quantity.isHidden = false
        minusBtn.isHidden = false
        addItemBtn.isHidden = false
    }
    
    func hidePurchasPart() {
        quantity.text = "1"
        plusBtn.isHidden = true
        quantity.isHidden = true
        minusBtn.isHidden = true
        addItemBtn.isHidden = true
    }
}


// MARK: CellConfig
extension CustomerOptionCell: CellConfig {
    func configure<T>(with target: NSManagedObject, of classType: T.Type) {
        option = (target as! Option)
//        optionImg.image =
        name.text = option!.name
        unitPrice.text = "$\(String(option!.price))"
        quantity.text = "1"
        hidePurchasPart()
    }
}
