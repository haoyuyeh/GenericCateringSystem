//
//  TableCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/7.
//
import OSLog
import UIKit
import CoreData

class TableCell: UICollectionViewCell {
    // MARK: Properties
    private let logger = Logger(subsystem: "Table or Collection View", category: "TableCell")

    // for indentifying which cell in the collectionview
    var indexPath: IndexPath?
    var ongoingOrder: Order?
    
    var isOcuppied: Bool {
        didSet {
            if isOcuppied {
                tableImg.image = UIImage(systemName: "sofa.fill")
            }else {
                tableImg.image = UIImage(systemName: "sofa")
            }
        }
    }
    
    required init?(coder: NSCoder) {
        isOcuppied = false
        super.init(coder: coder)
    }
    
    // MARK: IBOutlet
    @IBOutlet weak var tableNumber: UILabel!
    @IBOutlet weak var peopleServed: UILabel!
    @IBOutlet weak var tableImg: UIImageView!
}

// MARK: CellConfig
extension TableCell: CellConfig {
    func configure<T>(with target: NSManagedObject, of classType: T.Type) {
        let target = (target as! Device)
        let outcome = Helper.shared.hasOngoingOrder(of: target)
        
        tableNumber.text = target.number
        peopleServed.text = String(target.person)
        
        if outcome.result {
            ongoingOrder = outcome.order
            isOcuppied = true
        }
        
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
    }
}
// MARK: Helper
extension TableCell {
    func tableOccupied() {
        isOcuppied = true
    }
    
    func tableReleased() {
        isOcuppied = false
        ongoingOrder = nil
    }
    
    /// customer decide to leave before ordering anything.
    /// therefore, it will clear the table and delete the order
    func tableCanceled() {
        guard ongoingOrder != nil else {
            return
        }
        isOcuppied = false
        PersistenceService.shared.delete(object: ongoingOrder!)
        PersistenceService.shared.saveContext()
        ongoingOrder = nil
    }
}
