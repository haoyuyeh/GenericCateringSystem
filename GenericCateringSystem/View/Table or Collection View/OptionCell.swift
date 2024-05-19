//
//  OptionCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/4/21.
//
import OSLog
import UIKit
import CoreData

class OptionCell: UICollectionViewCell {
    // MARK: Properties
    private let logger = Logger(subsystem: "Table or Collection View", category: "OptionCell")
    
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
    
    // MARK: IBOutlet
    @IBOutlet weak var isSelectedImg: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var unitPrice: UILabel!
}
// MARK: CellConfig
extension OptionCell: CellConfig {
    func configure<T>(with target: NSManagedObject, of cellType: T.Type) {
        let target = target as! Option
        
        if cellType.self == MenuEditVC.self {
            isSelectedImg.isHidden = false
        }
        name.text = target.name
        unitPrice.text = "$\(String(target.price))"
    }
}

// MARK: OptionDeleteModeDelegate
extension OptionCell: DeleteModeDelegate {
    func isEnterDeleteMode(value: Bool) {
        isEnterDeleteMode = value
    }
}
