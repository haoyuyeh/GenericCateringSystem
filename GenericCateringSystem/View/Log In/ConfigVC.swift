//
//  ConfigVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/10/19.
//

import OSLog
import UIKit
import Foundation

enum Mode:String {
    case full
    case takeOut
}

/// only one device can be cashier, the rest are all client
enum Roll:String {
    case cashier
    case client
}

class ConfigVC: UIViewController {
    // MARK: IBOutlet
    
    
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var modeBtn: UIButton!
    @IBOutlet weak var rollBtn: UIButton!
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    
    @IBOutlet weak var deviceNumberLabel: UILabel!
    @IBOutlet weak var deviceNumberTF: UITextField!
    
    @IBOutlet weak var personServedLable: UILabel!
    @IBOutlet weak var personServedTF: UITextField!
    
    // MARK: Properties
    private let logger = Logger(subsystem: "LogIn", category: "ConfigVC")
    private var viewModel = ConfigVCViewModel()
    var currentDevice: Device?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        preSetUP()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        PersistenceService.shared.saveContext()
    }
    
    // MARK: IBAction
    
    @IBAction func deviceNumberTFChanged(_ sender: UITextField) {
        currentDevice?.number = deviceNumberTF.text ?? ""
    }
    
    
    @IBAction func personServedTFChanged(_ sender: UITextField) {
        // use number pad as input, no need to check for numbers only
        currentDevice?.person = Int16(personServedTF.text ?? "0") ?? 0
    }
    
    
    @IBAction func logOutBtnPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
        
        let destVC = storyboard.instantiateViewController(withIdentifier: "LogIn") as! LogInVC
        destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        destVC.currentDevice = currentDevice
        
        show(destVC, sender: sender)
    }
    
    
    @IBAction func editBtnPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
        
        let destVC = storyboard.instantiateViewController(identifier: "AccountVC") as AccountVC
        destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        destVC.currentDevice = currentDevice
        
        show(destVC, sender: sender)
    }
    
    @IBAction func startBtnPressed(_ sender: UIButton) {
        // segue to MenuVC
        let storyboard = UIStoryboard(name: "Casher", bundle: nil)
        
        let destVC = storyboard.instantiateViewController(identifier: "CasherTabC") as UITabBarController
        destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        destVC.selectedIndex = 0
        
        let menuVC = destVC.selectedViewController as! MenuVC
        menuVC.currentDevice = currentDevice

        show(destVC, sender: sender)
    }
}

// MARK: UITextFieldDelegate
extension ConfigVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: Helpler Function
extension ConfigVC {
    
    func preSetUP() {
        deviceNameLabel.text = "Device Name: \(currentDevice?.name ?? "nil")"
        
        setupModeBtn()
        setupRollBtn()
        
        layoutArrangement()
    }
    
    /// set up mode button
    func setupModeBtn() {
        let full = UIAction(title: Mode.full.rawValue, handler: { [unowned self] _ in
            self.currentDevice?.mode = Mode.full.rawValue
        })
        let takeout = UIAction(title: Mode.takeOut.rawValue, handler: { [unowned self] _ in
            self.currentDevice?.mode = Mode.takeOut.rawValue
        })
        
        // if currentDevice has its own mode, then show the corresponding action on the screen
        if let currentMode = currentDevice?.mode {
            if currentMode == Mode.full.rawValue {
                full.state = .on
            }else
            {
                takeout.state = .on
            }
        }else {
            currentDevice?.mode = Mode.takeOut.rawValue
            takeout.state = .on
        }
        
        modeBtn.menu = UIMenu(children:[
            full, takeout
        ])
        modeBtn.showsMenuAsPrimaryAction = true
        modeBtn.changesSelectionAsPrimaryAction = true
    }
    
    /// set up roll button
    func setupRollBtn() {
        let cashierAction = UIAction(title: Roll.cashier.rawValue, handler: { [unowned self] _ in
            self.currentDevice?.roll = Roll.cashier.rawValue
            layoutArrangement()
        })
        let clientAction = UIAction(title: Roll.client.rawValue, handler: { [unowned self] _ in
            self.currentDevice?.roll = Roll.client.rawValue
            layoutArrangement()
        })
        /**
         it can only have one cashier in the system, therefore, it try to provide different options based on the state of cashier
         */
        let currentRoll = currentDevice?.roll ?? ""
        let cashier = NSPredicate(format: "roll == %@", Roll.cashier.rawValue)
        let hasCashier = viewModel.hasRoll(as: cashier)
        
        switch (currentRoll, hasCashier) {
            //already has cashier in the system
        case ("", true), (Roll.client.rawValue, true):
            clientAction.state = .on
            currentDevice?.roll = Roll.client.rawValue
            rollBtn.menu = UIMenu(children:[
                clientAction
            ])
            // no cashier in the system
        case ("", false), (Roll.client.rawValue, false):
            clientAction.state = .on
            currentDevice?.roll = Roll.client.rawValue
            rollBtn.menu = UIMenu(children:[
                cashierAction, clientAction
            ])
            // current device is the cashier; (Roll.cashier.rawValue, _)
        default:
            cashierAction.state = .on
            rollBtn.menu = UIMenu(children:[
                cashierAction, clientAction
            ])
        }
        
        rollBtn.showsMenuAsPrimaryAction = true
        rollBtn.changesSelectionAsPrimaryAction = true
    }
    /// display the layout based on the roll of device
    func layoutArrangement() {
        switch currentDevice?.roll {
        case Roll.cashier.rawValue:
            deviceNumberLabel.isHidden = true
            deviceNumberTF.isHidden = true
            personServedLable.isHidden = true
            personServedTF.isHidden = true
        case Roll.client.rawValue:
            // only cashier can change accounts detail
            editBtn.isHidden = true
            deviceNumberLabel.isHidden = false
            deviceNumberTF.isHidden = false
            personServedLable.isHidden = false
            personServedTF.isHidden = false
            deviceNumberTF.text = currentDevice?.number
            personServedTF.text =  String(describing: currentDevice?.person ?? 0)
        default:
            break
        }
    }
}

