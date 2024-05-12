//
//  LogInVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/10/19.
//

import UIKit

class LogInVC: UIViewController {
    // MARK: IBOutlet
    @IBOutlet weak var deviceNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    // MARK: Properties
    private var viewModel = LogInVCViewModel()
    var currentDevice: Device?
    
    // MARK: IBAction
    @IBAction func logInBtnPressed(_ sender: UIButton) {
        // validate the name/password
        switch logInValidation() {
        case .emptyName:
            self.showAlert(alertTitle: "Warning", message: "Device name can't be empty or whitespaces only!!")
            
        case .emptyPassword:
            self.showAlert(alertTitle: "Warning", message: "Password can't be empty!!")

        case .wrongPassword:
            self.showAlert(alertTitle: "Warning", message: "Wrong password!!")
                        
        default:
            // log into the system
            // segue to ConfigVC
            let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
            
            let destVC = storyboard.instantiateViewController(identifier: "ConfigVC") as ConfigVC
            destVC.currentDevice = self.currentDevice
            destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            
            show(destVC, sender: self)
        }
    }
}

// MARK: UITextFieldDelegate
extension LogInVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: Helper functions
extension LogInVC {
    /// log in credential validation
    /// - Returns: retrun state based on the validation
    func logInValidation() -> LogInState {
        // check if there are values in name & password TF
        
        // a name cannot be an empty string or only all whitespaces
        let name = deviceNameTF.text ?? ""
        if !name.isMatch(pattern: "^[\\w\\s-]+$") {
            return LogInState.emptyName
        }
        // password cannot be nil
        if passwordTF.text == "" {
            return LogInState.emptyPassword
        }
        
        // check if the name/password exists in the database
        // exist: validate and react based on the result
        if Helper.shared.isIDExist(checking: deviceNameTF.text!) {
            let result = viewModel.credentialValidate(ID: deviceNameTF.text!, PW: passwordTF.text!)
            
            if result.state == .success {
                currentDevice = result.device
                return LogInState.success
            }else {
                return result.state
            }
        }else {
            // non-exist: see as new device, save the name/password to the database and allow entering the system
            currentDevice = viewModel.addNewDevice(deviceName: deviceNameTF.text!, PW: passwordTF.text!)
            return LogInState.success
        }
    }
}
