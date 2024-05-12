//
//  AccountVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/11/4.
//

import UIKit

class AccountVC: UIViewController {
    // MARK: Property
    var viewModel = AccountVCViewModel()
    var currentDevice: Device?
    
    typealias AccountDataSource = UITableViewDiffableDataSource<AccountSection, Device>
    typealias AccountSnapShot = NSDiffableDataSourceSnapshot<AccountSection, Device>
    private lazy var accountDataSource = configureAccountDataSource()
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.delegate = self
        tableView.dataSource = accountDataSource
        updateAccountSnapShot()
    }
    
    // MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
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

// MARK: Account Table View
extension AccountVC {
    func configureAccountDataSource() -> AccountDataSource {
        let dataSource = AccountDataSource(tableView: tableView) { [unowned self] (tableView, indexPath, device) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as! AccountCell
            
            cell.delegate = viewModel
            cell.indexPath = indexPath
            cell.configure(with: device, of: type(of: self))
            
            return cell
        }
        return dataSource
    }
    
    func updateAccountSnapShot(animatingDifferences value: Bool = false) {
        var snapShot = AccountSnapShot()
        
        snapShot.appendSections([.all])
        snapShot.appendItems(viewModel.getAllAccount(), toSection: .all)
        
        DispatchQueue.main.async { [unowned self] in
            accountDataSource.apply(snapShot, animatingDifferences: value)
        }
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


extension AccountVC: ShowMsgDelegate {
    func show(msg: String) {
        tableView.reloadData()
        self.showAlert(alertTitle: "Warning", message: msg)
    }
}
