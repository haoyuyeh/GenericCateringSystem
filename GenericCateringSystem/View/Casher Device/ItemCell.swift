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
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var unitPrice: UILabel!
    @IBOutlet weak var quantity: UITextField!
    
    @IBAction func itemQuantityChanged(_ sender: UITextField) {
        if let text = sender.text {
            if !text.isMatch(pattern: "^[\\d]+$") {
                sender.text = "1"
            }
        }else {
            sender.text = "1"
        }
        delegate?.itemQuantityChanged(to: Int(sender.text!)!,
                                      of: indexPath!)
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
