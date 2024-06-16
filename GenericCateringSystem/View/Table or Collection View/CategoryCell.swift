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
    
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    
    var widthOrHeight: Bool?
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
                self.backgroundColor = UIColor.white
            }else {
                self.backgroundColor = UIColor.systemYellow
            }
        }
    }
    
    required init?(coder: NSCoder) {
        isEnterDeleteMode = false
        cellIsChoosed = false
        super.init(coder: coder)
    }
    
    override func updateConstraints() {
        if widthOrHeight! {
            widthConstraint = contentView.widthAnchor.constraint(equalToConstant: 0)
            widthConstraint?.constant = superview?.bounds.width ?? 0
            widthConstraint?.isActive = true
        }else {
            // for MenuVC and MenuEditVC
            heightConstraint = contentView.heightAnchor.constraint(equalToConstant: 0)
            heightConstraint?.constant = superview?.bounds.height ?? 0
            heightConstraint?.isActive = true
        }
        super.updateConstraints()
    }
    
    // MARK: IBOutlet
    /// use to mark whether this cell will be delete or not
    @IBOutlet weak var isSelectedImg: UIImageView!
    @IBOutlet weak var name: UILabel!
}

// MARK: CellConfig
extension CategoryCell: CellConfig {
    func configure<T>(with target: NSManagedObject, of classType: T.Type) {
        category = (target as! Category)
        
        if classType.self == OrderingVC.self {
            widthOrHeight = true
        }else {
            // for MenuVC and MenuEditVC
            widthOrHeight = false
        }
        if classType.self == MenuEditVC.self {
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
