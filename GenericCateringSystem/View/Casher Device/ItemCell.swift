//
//  ItemCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/3/26.
//

import UIKit

protocol ItemQuantityDelegate {
    func itemQuantityChanged(to num: Int, of index: IndexPath)
}

class ItemCell: UITableViewCell {

    
    var delegate: ItemQuantityDelegate?
    var indexPath: IndexPath?
    
    @IBOutlet weak var itemNameLebel: UILabel!
    @IBOutlet weak var itemQuantityTF: UITextField!
    
    @IBAction func itemQuantityChanged(_ sender: UITextField) {
        
        delegate?.itemQuantityChanged(to: Int(itemQuantityTF.text ?? "1")!, of: indexPath!)
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
