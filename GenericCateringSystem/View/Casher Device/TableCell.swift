//
//  TableCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/7.
//

import UIKit

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
// MARK: TableStateChangedDelegate
extension TableCell: TableStateChangedDelegate {
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
