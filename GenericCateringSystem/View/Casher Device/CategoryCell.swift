//
//  CategoryCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/4/21.
//

import UIKit
import OSLog

class CategoryCell: UICollectionViewCell {
    private let logger = Logger(subsystem: "Cashier", category: "CategoryCell")

    @IBOutlet weak var isSelectedImg: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    var uuid: UUID? = nil
    var cellIsSelected = false
    
    override var isSelected: Bool {
        didSet{
            if self.isSelected{
                self.backgroundColor = .systemYellow

            }else {
                self.backgroundColor = .white
            }
        }
    }
}

extension CategoryCell: CategoryDeleteModeDelegate {
    func isEnterDeleteMode(value: Bool) {
        logger.debug("isEnterDeleteMode \(value)")

        isSelectedImg.isHidden = !value
    }
}
