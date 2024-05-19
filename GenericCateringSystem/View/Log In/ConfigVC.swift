//
//  ConfigVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/10/19.
//

import OSLog
import UIKit

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
    
    override func viewIsAppearing(_ animated: Bool) {
        preSetUP()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        PersistenceService.shared.saveContext()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "logOut":
            let destVC = segue.destination as! LogInVC
            
            destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            destVC.currentDevice = currentDevice
        case "manageAccount":
            let destVC = segue.destination as! AccountVC
            
            destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            destVC.currentDevice = currentDevice
            
        default:
            logger.error("unknown segue")
        }
    }
    
    
    // MARK: IBAction
    
    @IBAction func deviceNumberTFChanged(_ sender: UITextField) {
        currentDevice?.number = deviceNumberTF.text ?? ""
    }
    
    
    @IBAction func personServedTFChanged(_ sender: UITextField) {
        // use number pad as input, no need to check for numbers only
        currentDevice?.person = Int16(personServedTF.text ?? "0") ?? 0
    }
    
    @IBAction func startBtnPressed(_ sender: UIButton) {
        // segue to MenuVC or OrderingVC(for customer)
        logger.debug("roll: \(self.currentDevice?.roll ?? "nil")")
        if let roll = currentDevice?.roll {
            switch roll {
            case Roll.cashier.rawValue:
                let storyboard = UIStoryboard(name: "Casher", bundle: nil)
                let destVC = storyboard.instantiateViewController(withIdentifier: "CasherTabC") as! UITabBarController
                
                destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                destVC.selectedIndex = 0
                
                let menuVC = destVC.selectedViewController as! MenuVC
                menuVC.currentDevice = currentDevice

                show(destVC, sender: sender)
                
            case Roll.customer.rawValue:
                let storyboard = UIStoryboard(name: "Customer", bundle: nil)
                let tabC = storyboard.instantiateViewController(withIdentifier: "CustomerTabC") as! UITabBarController
                
                tabC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                tabC.selectedIndex = 0
                
                let destVC = tabC.selectedViewController as! OrderingVC
                destVC.currentDevice = currentDevice

                show(tabC, sender: sender)
                
            case Roll.displayWalkIn.rawValue:
                let storyBoard = UIStoryboard(name: "Display", bundle: nil)
                let destVC = storyBoard.instantiateViewController(withIdentifier: "DisplayWalkInVC") as! DisplayWalkInVC
                
                destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen

                show(destVC, sender: self)
                
            case Roll.displayTakeOut.rawValue:
                let storyBoard = UIStoryboard(name: "Display", bundle: nil)
                let destVC = storyBoard.instantiateViewController(withIdentifier: "DisplayTakeOutVC") as! DisplayTakeOutVC
                
                destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen

                show(destVC, sender: self)
                
            default:
                logger.error("unknow device roll.")
            }
        }
        
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
        let customerAction = UIAction(title: Roll.customer.rawValue, handler: { [unowned self] _ in
            self.currentDevice?.roll = Roll.customer.rawValue
            layoutArrangement()
        })
        let displayTAAction = UIAction(title: Roll.displayTakeOut.rawValue, handler: { [unowned self] _ in
            self.currentDevice?.roll = Roll.displayTakeOut.rawValue
            layoutArrangement()
        })
        let displayWIAction = UIAction(title: Roll.displayWalkIn.rawValue, handler: { [unowned self] _ in
            self.currentDevice?.roll = Roll.displayWalkIn.rawValue
            layoutArrangement()
        })
        
        /**
         it can only have one cashier in the system, therefore, it try to provide different options based on the state of cashier
         */
        // asign a default roll for new device
        if currentDevice?.roll == nil {
            currentDevice?.roll = Roll.customer.rawValue
        }
        
        let cashier = NSPredicate(format: "roll == %@", Roll.cashier.rawValue)
        let hasCashier = viewModel.hasRoll(as: cashier)
        
        switch (currentDevice?.roll, hasCashier) {
            //already has cashier in the system
        case (Roll.customer.rawValue, true):
            customerAction.state = .on
            rollBtn.menu = UIMenu(children:[
                customerAction, displayWIAction, displayTAAction
            ])
        case (Roll.displayWalkIn.rawValue, true):
            displayWIAction.state = .on
            rollBtn.menu = UIMenu(children:[
                customerAction, displayWIAction, displayTAAction
            ])
        case (Roll.displayTakeOut.rawValue, true):
            displayTAAction.state = .on
            rollBtn.menu = UIMenu(children:[
                customerAction, displayWIAction, displayTAAction
            ])
            // no cashier in the system
        case (Roll.customer.rawValue, false):
            customerAction.state = .on
            rollBtn.menu = UIMenu(children:[
                cashierAction, customerAction, displayTAAction, displayWIAction
            ])
        case (Roll.displayWalkIn.rawValue, false):
            displayWIAction.state = .on
            rollBtn.menu = UIMenu(children:[
                cashierAction, customerAction, displayTAAction, displayWIAction
            ])
        case (Roll.displayTakeOut.rawValue, false):
            displayTAAction.state = .on
            rollBtn.menu = UIMenu(children:[
                cashierAction, customerAction, displayTAAction, displayWIAction
            ])
            // current device is the cashier; (Roll.cashier.rawValue, _)
        default:
            cashierAction.state = .on
            rollBtn.menu = UIMenu(children:[
                cashierAction, customerAction, displayTAAction, displayWIAction
            ])
        }
        
        rollBtn.showsMenuAsPrimaryAction = true
        rollBtn.changesSelectionAsPrimaryAction = true
        layoutArrangement()
    }
    /// display the layout based on the roll of device
    func layoutArrangement() {
        switch currentDevice?.roll {
        case Roll.cashier.rawValue:
            editBtn.isHidden = false
            deviceNumberLabel.isHidden = true
            deviceNumberTF.isHidden = true
            personServedLable.isHidden = true
            personServedTF.isHidden = true
            
        case Roll.displayWalkIn.rawValue, Roll.displayTakeOut.rawValue:
            editBtn.isHidden = true
            deviceNumberLabel.isHidden = true
            deviceNumberTF.isHidden = true
            personServedLable.isHidden = true
            personServedTF.isHidden = true
            
        case Roll.customer.rawValue:
            // only cashier can change accounts detail
            editBtn.isHidden = true
            deviceNumberLabel.isHidden = false
            deviceNumberTF.isHidden = false
            personServedLable.isHidden = false
            personServedTF.isHidden = false
            deviceNumberTF.text = currentDevice?.number
            personServedTF.text =  String(describing: currentDevice?.person ?? 0)
    
        default:
            editBtn.isHidden = true

        }
    }
}

