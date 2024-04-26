//
//  CategoryCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/4/21.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    
    @IBOutlet weak var name: UILabel!
    var uuid: UUID? = nil
    
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
