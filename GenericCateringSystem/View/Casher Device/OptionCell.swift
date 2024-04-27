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
    var cellIsSelected = false

}

extension OptionCell: OptionDeleteModeDelegate {
    func isEnterDeleteMode(value: Bool) {
        isSelectedImg.isHidden = !value
    }
    
    
}
