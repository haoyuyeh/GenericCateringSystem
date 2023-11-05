//
//  AccountCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/11/4.
//

import UIKit

protocol AccountCellDelegate {
    func idTFTextChanged(to newName: String, at indexPath: IndexPath)
    func pwTFTextChanged(to newPw: String, at indexPath: IndexPath)
}



class AccountCell: UITableViewCell {
    // MARK: Properties
    var delegate: AccountCellDelegate!
    var indexPath: IndexPath!
    
    // MARK: IBOutlet
    
    @IBOutlet weak var idTextField: UITextField!
    
    @IBOutlet weak var pwTextField: UITextField!
    
    // MARK: IBAction

    @IBAction func idTextFieldChanged(_ sender: UITextField) {
        delegate.idTFTextChanged(to: idTextField.text ?? "nil username", at: indexPath)
    }
    
    
    @IBAction func pwTextFieldChanged(_ sender: UITextField) {
        delegate.pwTFTextChanged(to: pwTextField.text ?? "nil password",at: indexPath)
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
