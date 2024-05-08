//
//  TableOrderDetailVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/7.
//
import OSLog
import UIKit

protocol CheckOutDelegate {
    func orderCompleted(at table: UUID)
}

class TableOrderDetailVC: UIViewController {
    // MARK: Properties
    private let logger = Logger(subsystem: "EatIn", category: "TableOrderDetailVC")
    private var viewModel = TableOrderDetailVCViewModel()
    /// customer device uuid
    var uuid: UUID?
    var currentOrder: Order?
    var delegate: CheckOutDelegate?
    
    lazy var itemDataSource = configureItemDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemTableView.dataSource = itemDataSource
        updateItemSnapShot()
    }
    
    // MARK: IBOutlet
    @IBOutlet weak var orderTitle: UILabel!
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var totalSum: UIButton!
    @IBOutlet weak var notes: UITextView!
    
    // MARK: IBAction

    @IBAction func totalSumBtnPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Warning", message: "Offer discount between 0.01 ~ 1.0(newSum = sum * discount) ", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.delegate = self
            textField.placeholder = "such as 0.3"
            textField.keyboardType = .decimalPad
            textField.clearButtonMode = .whileEditing
        }
        
        let ok = UIAlertAction(title: "OK", style: .default) { [unowned self] (_) in
            viewModel.discount(for: currentOrder, rate: Double(alert.textFields?[0].text ?? "1.0")!)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func checkOutBtnPressed(_ sender: UIButton) {
        viewModel.checkOut(order: currentOrder!)
        delegate?.orderCompleted(at: uuid!)
    }
}

// MARK: UITextFieldDelegate
extension TableOrderDetailVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // make sure only input decimal between 0.01~1.0
        if let text = textField.text {
            if !text.isMatch(pattern: "^0\\.\\d+$") {
                textField.text = nil
                self.showAlert(alertTitle: "Warning", message: "Input deciaml between 0.01 ~ 1.0")
            }
        }else {
            textField.text = nil
        }
    }
}

// MARK: Item Table View
extension TableOrderDetailVC {
    func configureItemDataSource() -> UITableViewDiffableDataSource<TableSection, Item> {
        let dataSource = UITableViewDiffableDataSource<TableSection, Item>(tableView: itemTableView) { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
            
            cell.delegate = self
            cell.indexPath = indexPath
            
            cell.name.text = self.viewModel.getItemName(at: indexPath.row)
            cell.unitPrice.text = self.viewModel.getItemUnitPrice(at: indexPath.row)
            cell.quantity.text = self.viewModel.getItemQuantity(at: indexPath.row)
            
            return cell
        }
        return dataSource
    }
    
    func updateItemSnapShot() {
        var snapShot = NSDiffableDataSourceSnapshot<TableSection, Item>()
        snapShot.appendSections([.all])
        snapShot.appendItems(viewModel.getAllItems(of: currentOrder!), toSection: .all)
        
        itemDataSource.apply(snapShot, animatingDifferences: false)
    }
}

// MARK: UITableViewDelegate
extension TableOrderDetailVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        viewModel.deleteItem(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
    }
}

// MARK: ItemQuantityDelegate
extension TableOrderDetailVC: ItemQuantityDelegate {
    func itemQuantityChanged(to num: Int, of index: IndexPath) {
        viewModel.changeQuantity(of: index.row, to: num)
    }
}

// MARK: TotalSumDelegate
extension TableOrderDetailVC: TotalSumDelegate {
    func totalSumChanged(to sum: Double) {
        totalSum.titleLabel?.text = String(sum)
    }
}
