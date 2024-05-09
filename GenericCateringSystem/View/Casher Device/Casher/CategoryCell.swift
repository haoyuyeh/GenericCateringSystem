//
//  CategoryCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/4/21.
//

import UIKit
import OSLog
import CoreData

class CategoryCell: UICollectionViewCell {
    private let logger = Logger(subsystem: "Cashier", category: "CategoryCell")
    
    /// use to mark whether this cell will be delete or not
    @IBOutlet weak var isSelectedImg: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override var isSelected: Bool {
        didSet{
            if isSelected {
                self.backgroundColor = UIColor.systemYellow
            }else {
                self.backgroundColor = UIColor.white
            }
        }
    }
    
    var uuid: UUID? = nil
    var isEnterDeleteMode: Bool {
        didSet {
            if isEnterDeleteMode {
                isSelectedImg.isHidden = false
            }else {
                isSelectedImg.isHidden = true
            }
        }
    }
    
    /// use to track whether the cell is selected during delete mode
    var cellIsChoosed: Bool {
        didSet {
            if isEnterDeleteMode {
                if cellIsChoosed {
                    isSelectedImg.image = UIImage(systemName: "checkmark.square")
                }else {
                    isSelectedImg.image = UIImage(systemName: "square")
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        isEnterDeleteMode = false
        cellIsChoosed = false
        super.init(coder: coder)
    }
}

// MARK: CellConfig
extension CategoryCell: CellConfig {
    func configure(target: NSManagedObject) {
        let target = target as! Category
        
        name.text = target.name
    }
}

// MARK: CategoryDeleteModeDelegate
extension CategoryCell: CategoryDeleteModeDelegate {
    func isEnterDeleteMode(value: Bool) {
        isEnterDeleteMode = value
    }
}
