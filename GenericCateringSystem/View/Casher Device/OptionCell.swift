//
//  OptionCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/4/21.
//

import UIKit

class OptionCell: UICollectionViewCell {
    
    @IBOutlet weak var isSelectedImg: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    var uuid: UUID? = nil
    var isEnterDeleteMode: Bool{
        didSet {
            if self.isEnterDeleteMode {
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
                if self.cellIsChoosed {
                    isSelectedImg.image = UIImage(systemName: "checkmark.square")
                }else {
                    isSelectedImg.image = UIImage(systemName: "square")
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        self.isEnterDeleteMode = false
        self.cellIsChoosed = false
        super.init(coder: coder)
    }

}

extension OptionCell: OptionDeleteModeDelegate {
    func isEnterDeleteMode(value: Bool) {
        isEnterDeleteMode = value
    }
}
