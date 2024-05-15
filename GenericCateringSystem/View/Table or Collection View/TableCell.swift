//
//  TableCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/7.
//

import UIKit
import CoreData

class TableCell: UICollectionViewCell {
    // MARK: IBOutlet
    @IBOutlet weak var tableNumber: UILabel!
    @IBOutlet weak var peopleServed: UILabel!
    @IBOutlet weak var tableImg: UIImageView!
    
    // MARK: Properties
    // customer device uuid
    var uuid: UUID?
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
}

// MARK: CellConfig
extension TableCell: CellConfig {
    func configure<T>(with target: NSManagedObject, of cellType: T.Type) {
        let target = target as! Device
        tableNumber.text = target.number
        peopleServed.text = String(target.person)
        
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
    }
}

// MARK: TableStateChangedDelegate
extension TableCell: EatInTableDelegate {
    func occupied(at table: UUID) {
        if table.uuidString == self.uuid!.uuidString {
            isOcuppied = true
        }
    }
    
    func released(at table: UUID) {
        if table.uuidString == self.uuid!.uuidString {
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
