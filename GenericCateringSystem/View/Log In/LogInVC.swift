//
//  LogInVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/10/19.
//

import UIKit


enum LogInState: String {
    case emptyName
    case emptyPassword
    case wrongPassword
    case success
}


class LogInVC: UIViewController {
    // MARK: IBOutlet
    @IBOutlet weak var deviceNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    // MARK: Properties
    private var viewModel = LogInVCViewModel()
    private var currentDevice: Device?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: IBAction
    @IBAction func logInBtnPressed(_ sender: UIButton) {
        // validate the name/password
        switch logInValidation() {
        case .emptyName:
            self.showAlert(alertTitle: "Warning", message: "Device name can't be empty or whitespaces only!!")
//            print("enter \(LogInState.emptyName.rawValue)")
            
        case .emptyPassword:
            self.showAlert(alertTitle: "Warning", message: "Password can't be empty!!")
//            print("enter \(LogInState.emptyPassword.rawValue)")

        case .wrongPassword:
            self.showAlert(alertTitle: "Warning", message: "Wrong password!!")
//            print("enter \(LogInState.wrongPassword.rawValue)")
                        
        default:
            // log into the system
            // segue to ConfigVC
            let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
            
            let destVC = storyboard.instantiateViewController(identifier: "ConfigVC") as ConfigVC
            destVC.currentDevice = self.currentDevice
            destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            
            show(destVC, sender: self)
            
//            self.showAlert(alertTitle: "Message", message: "Log in success!!")
//            print("enter \(LogInState.success.rawValue)")
        }
    }
}

// MARK: Helper functions
extension LogInVC {
    /// log in credential validation
    /// - Returns: retrun state based on the validation
    func logInValidation() -> LogInState {
        // check if there are values in name & password TF
        
        // a name cannot be an empty string or only all whitespaces
        let name = (deviceNameTF.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            return LogInState.emptyName
        }
        // password cannot be nil
        if passwordTF.text == "" {
            return LogInState.emptyPassword
        }
        
        // check if the name/password exists in the database
        // exist: validate and react based on the result
        if viewModel.isIDExist(checking: deviceNameTF.text!) {
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
