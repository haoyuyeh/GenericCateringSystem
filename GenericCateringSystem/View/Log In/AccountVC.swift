//
//  AccountVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/11/4.
//

import UIKit

class AccountVC: UIViewController {
    // MARK: IBOutlet

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Property
    var viewModel = AccountVCViewModel()
    var currentDevice: Device?
    
    // MARK: IBAction
    @IBAction func doneBtnPressed(_ sender: UIButton) {
        viewModel.saveChanges()
        // segue to ConfigVC
        let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
        
        let destVC = storyboard.instantiateViewController(identifier: "ConfigVC") as ConfigVC
        destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        destVC.currentDevice = currentDevice
        
        show(destVC, sender: sender)
    }
}

// MARK: UITableViewDataSource
extension AccountVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getAccountCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as! AccountCell
        cell.delegate = viewModel
        cell.indexPath = indexPath
        cell.idTextField.text = viewModel.getAccount(at: indexPath.row).name
        cell.pwTextField.text = viewModel.getAccount(at: indexPath.row).password
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension AccountVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard (viewModel.getAccount(at: indexPath.row).roll)! == Roll.client.rawValue else {
            self.showAlert(alertTitle: "Warning", message: "The admin account cannot be deleted!!!")
            return
        }
        
        tableView.beginUpdates()
        viewModel.deleteAccount(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
    }
}

// MARK: UITextFieldDelegate
extension AccountVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
