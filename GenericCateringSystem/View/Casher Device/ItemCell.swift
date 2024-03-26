//
//  ItemCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/3/26.
//

import UIKit

class ItemCell: UITableViewCell {

    
    @IBOutlet weak var itemNameLebel: UILabel!
    
    @IBOutlet weak var itemQuantiyBtn: UIButton!
    
    
    
    @IBAction func itemQuantityBtnPressed(_ sender: UIButton) {
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
