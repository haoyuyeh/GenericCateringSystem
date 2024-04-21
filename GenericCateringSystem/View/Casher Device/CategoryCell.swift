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
                UIView.animate(withDuration: 0.3) {
                    self.backgroundColor = UIColor(red: 115/255, green: 190/255, blue: 170/255, alpha: 1.0)
                }
            }else {
                UIView.animate(withDuration: 0.3) {
                    self.backgroundColor = UIColor(red: 60/255, green: 63/255, blue: 73/255, alpha: 1.0)
                }
            }
        }
    }
}
