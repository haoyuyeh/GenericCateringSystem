//
//  OptionCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/4/21.
//

import UIKit
import CoreData

class OptionCell: UICollectionViewCell {
    
    @IBOutlet weak var isSelectedImg: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var unitPrice: UILabel!
    
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
extension OptionCell: CellConfig {
    func configure(target: NSManagedObject) {
        let target = target as! Option
        
        name.text = target.name
        unitPrice.text = "$\(String(target.price))"
    }
}

// MARK: OptionDeleteModeDelegate
extension OptionCell: OptionDeleteModeDelegate {
    func isEnterDeleteMode(value: Bool) {
        isEnterDeleteMode = value
    }
}
