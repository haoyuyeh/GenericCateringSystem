//
//  AccountCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/11/4.
//

import UIKit
import CoreData

class AccountCell: UITableViewCell {
    // MARK: Properties
    var delegate: AccountCellDelegate!
    var indexPath: IndexPath!
    
    // MARK: IBOutlet
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    
    // MARK: IBAction
    @IBAction func idTFEndChange(_ sender: UITextField) {
        delegate.idTFTextChanged(to: idTextField.text ?? "nil username", at: indexPath)
    }
    
    @IBAction func pwTFEndChange(_ sender: UITextField) {
        delegate.pwTFTextChanged(to: pwTextField.text ?? "nil password",at: indexPath)
    }
}

extension AccountCell: CellConfig {
    func configure<T>(with target: NSManagedObject, of cellType: T.Type) {
        let target = target as! Device
        
        idTextField.text = target.name
        pwTextField.text = target.password
    }
}
