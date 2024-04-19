//
//  MenuVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/11/5.
//

import OSLog
import UIKit

class MenuVC: UIViewController {
    // MARK: Properties
    private let logger = Logger(subsystem: "Cashier", category: "MenuVC")
    private var viewModel = MenuVCViewModel()
    var currentDevice: Device?
    
    // MARK: IBOutlet
    @IBOutlet weak var orderTypeTF: UITextField!
    @IBOutlet weak var orderNumberTF: UITextField!
    @IBOutlet weak var orderOthersTF: UITextField!
    
    @IBOutlet weak var orderTableView: UITableView!
    
    @IBOutlet weak var sumLabel: UILabel!
    
    @IBOutlet weak var catagoryCollectionView: UICollectionView!
    @IBOutlet weak var optionCollectionView: UICollectionView!
    
    // MARK: IBAction
    
    @IBAction func checkOutBtnPressed(_ sender: UIButton) {
        // complet and save current order, then start a new order
    }
    
    @IBAction func logOutBtnPressed(_ sender: UIButton) {
        // segue to LogInVC
    }
    
    @IBAction func editBtnPressed(_ sender: UIButton) {
        // segue to MenuEditVC
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

// MARK: UITableViewDataSource
extension MenuVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCurrentOrderedItemCounts()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        cell.itemNameLebel.text = viewModel.getItemName(at: indexPath.row)
        
        cell.itemQuantiyBtn.titleLabel?.text = String(viewModel.getItemQuantity(at: indexPath.row))
        
        return cell
    }
}

// MARK: UICollectionViewDataSource
//extension MenuVC: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        <#code#>
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        <#code#>
//    }
//}

@available(iOS 17.0, *)
#Preview {
    var vc = MenuVC()
    return vc
}
