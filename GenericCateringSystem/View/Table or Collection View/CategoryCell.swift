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
    // MARK: Properties
    private let logger = Logger(subsystem: "Table or Collection View", category: "CategoryCell")
    
    var category: Category?
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
    
    override var isSelected: Bool {
        didSet{
            if isSelected {
                self.backgroundColor = UIColor.systemYellow
            }else {
                self.backgroundColor = UIColor.white
            }
        }
    }
    
    required init?(coder: NSCoder) {
        isEnterDeleteMode = false
        cellIsChoosed = false
        super.init(coder: coder)
    }
    // MARK: IBOutlet
    /// use to mark whether this cell will be delete or not
    @IBOutlet weak var isSelectedImg: UIImageView!
    @IBOutlet weak var name: UILabel!
}

// MARK: CellConfig
extension CategoryCell: CellConfig {
    func configure<T>(with target: NSManagedObject, of cellType: T.Type) {
        category = (target as! Category)
        if cellType.self == MenuEditVC.self {
            isSelectedImg.isHidden = false
        }
        
        name.text = category!.name
    }
}

// MARK: CategoryDeleteModeDelegate
extension CategoryCell: DeleteModeDelegate {
    func isEnterDeleteMode(value: Bool) {
        isEnterDeleteMode = value
    }
}
