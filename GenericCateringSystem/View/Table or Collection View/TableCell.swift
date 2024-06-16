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
    // customer device 
    var device: Device?
    var indexPath: IndexPath?
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
        let target = target as! Device
        tableNumber.text = target.number
        peopleServed.text = String(target.person)
        
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
    }
}

// MARK: TableStateChangedDelegate
extension TableCell: EatInTableDelegate {
    func occupied(at table: Device) {
        if table.uuid?.uuidString == self.device?.uuid?.uuidString {
            isOcuppied = true
        }
    }
    
    func released(at table: Device) {
        if table.uuid?.uuidString == self.device?.uuid?.uuidString {
            isOcuppied = false
        }
    }
    
    func tableOccupied() {
        isOcuppied = true
    }
    
    func tableReleased() {
        isOcuppied = false
    }
}
