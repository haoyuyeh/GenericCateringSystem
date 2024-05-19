//
//  AccountCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/11/4.
//
import OSLog
import UIKit
import CoreData

class AccountCell: UITableViewCell {
    // MARK: Properties
    private let logger = Logger(subsystem: "Table or Collection View", category: "AccountCell")
    
    var delegate: TextFieldChangedDelegate!
    var indexPath: IndexPath!
    
    // MARK: IBOutlet
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    
    // MARK: IBAction
    @IBAction func idTFEndChange(_ sender: UITextField) {
        delegate.idChanged(to: idTextField.text ?? "nil username", at: indexPath)
    }
    
    @IBAction func pwTFEndChange(_ sender: UITextField) {
        delegate.pwChanged(to: pwTextField.text ?? "nil password",at: indexPath)
    }
}

extension AccountCell: CellConfig {
    func configure<T>(with target: NSManagedObject, of cellType: T.Type) {
        let target = target as! Device
        
        idTextField.text = target.name
        pwTextField.text = target.password
    }
}
