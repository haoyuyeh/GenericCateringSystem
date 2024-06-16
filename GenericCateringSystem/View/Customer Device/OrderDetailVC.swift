//
//  OrderDetailVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/19.
//

import OSLog
import UIKit

class OrderDetailVC: UIViewController {
    // MARK: Properties
    private let logger = Logger(subsystem: "Customer", category: "OrderDetailVC")
    
    private var viewModel = OrderDetailVCViewModel()
    var currentDevice: Device?
    var currentOrder: Order?
//    var isGranted: Bool = false
    
    typealias ItemDataSource = UITableViewDiffableDataSource<ItemSection, Item>
    typealias ItemSnapShot = NSDiffableDataSourceSnapshot<ItemSection, Item>
    private lazy var itemDataSource = configureItemDataSource()
    
    override func viewIsAppearing(_ animated: Bool) {
        config()
    }
    
    
    // MARK: IBOulets
    @IBOutlet weak var tableNumber: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var itemTableView: UITableView!
    
    @IBOutlet weak var sum: UILabel!
    
    // MARK: IBActions

    @IBAction func logOutBtnPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "Enter Password", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.delegate = self
            textField.keyboardType = .asciiCapable
            textField.isSecureTextEntry = true
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
            textField.clearButtonMode = .whileEditing
        }
        let ok = UIAlertAction(title: "OK", style: .default) { [unowned self] tf in
            if passwordValidation(inputPW: alert.textFields?[0].text) {
                let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
                let destVC = storyboard.instantiateViewController(withIdentifier: "LogIn") as! LogInVC
                destVC.currentDevice = self.currentDevice
                destVC.modalPresentationStyle = .fullScreen
                
                present(destVC, animated: true)
            }else {
                self.showAlert(alertTitle: "Warning", message: "Wrong password!!")
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func editBtnPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "Enter Password", preferredStyle: .alert)
        
        alert.addTextField { tf in
            tf.delegate = self
            tf.keyboardType = .asciiCapable
            tf.isSecureTextEntry = true
            tf.autocapitalizationType = .none
            tf.autocorrectionType = .no
            tf.clearButtonMode = .whileEditing
        }
        
        let ok = UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
            if passwordValidation(inputPW: alert.textFields?[0].text) {
//                isGranted = true
                doneBtn.isHidden = false
                itemTableView.isUserInteractionEnabled = true
            }else {
                self.showAlert(alertTitle: "Warning", message: "Wrong password!!")
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func doneBtnPressed(_ sender: UIButton) {
//        isGranted = false
        doneBtn.isHidden = true
        itemTableView.isUserInteractionEnabled = false
    }
}

extension OrderDetailVC {
    func config() {
        self.tabBarController?.delegate = self
        tableNumber.text = "Table #\(currentDevice?.number ?? "nil")"
        doneBtn.isHidden = true
        sum.text = "\(currentOrder!.totalSum)"
        
        itemTableView.isUserInteractionEnabled = false
        itemTableView.dataSource = itemDataSource
        
        DispatchQueue.main.async { [unowned self] in
            updateItemSnapshot()
            itemTableView.reloadData()
        }
    }
    
    func passwordValidation(inputPW: String?) -> Bool {
        guard let inputPW = inputPW else {
            return false
        }
        
        if inputPW == currentDevice?.password! {
            return true
        }else {
            return false
        }
    }
}

// MARK: UITextFieldDelegate
extension OrderDetailVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: UITextFieldDelegate
extension OrderDetailVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ItemCell
        
        cell.item?.served += 1
        viewModel.saveAll()
        
        DispatchQueue.main.async { [unowned self] in
//            updateItemSnapshot()
            itemTableView.reloadData()
        }
    }
}


// MARK: Item Table View
extension OrderDetailVC {
    func configureItemDataSource() -> ItemDataSource {
        let dataSource = ItemDataSource(tableView: itemTableView) { (tableView, indexPath, item) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
            
            cell.indexPath = indexPath
            cell.configure(with: item, of: type(of: self))
            
            return cell
        }
        return dataSource
    }
    
    func updateItemSnapshot(animatingDifferences value: Bool = false) {
        var snapShot = ItemSnapShot()
        
        snapShot.appendSections([.all])
        snapShot.appendItems(viewModel.getAllItems(currentOrder: currentOrder), toSection: .all)
        
        DispatchQueue.main.async { [unowned self] in
            itemDataSource.apply(snapShot, animatingDifferences: value)
        }
    }
}

// MARK: UITabBarControllerDelegate
extension OrderDetailVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch tabBarController.selectedIndex {
        case 0:
            let vc = viewController as! OrderingVC
            vc.currentDevice = currentDevice
            vc.currentOrder = currentOrder

        case 1:
            let vc = viewController as! OrderDetailVC
            vc.currentDevice = currentDevice
            vc.currentOrder = currentOrder

        default:
            logger.error("unrecognized view controller")
        }
    }
}
