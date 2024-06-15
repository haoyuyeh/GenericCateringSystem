//
//  TableOrderDetailVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/7.
//
import OSLog
import UIKit

class TableOrderDetailVC: UIViewController {
    // MARK: Properties
    private let logger = Logger(subsystem: "EatIn", category: "TableOrderDetailVC")
    private var viewModel = TableOrderDetailVCViewModel()
    /// customer device
    var device: Device?
    var currentOrder: Order?
    var delegate: EatInTableDelegate?
    
    typealias ItemDataSource = UITableViewDiffableDataSource<TableSection, Item>
    typealias ItemSnapShot = NSDiffableDataSourceSnapshot<TableSection, Item>
    private lazy var itemDataSource = configureItemDataSource()
    
    override func viewIsAppearing(_ animated: Bool) {
        config()
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
        delegate?.orderCompleted(at: device!)
    }
}

// MARK: Helper
extension TableOrderDetailVC {
    func config() {
        switch Int(currentOrder!.type) {
        case OrderType.eatIn.rawValue:
            orderTitle.text = "Table #\(currentOrder?.number ?? "nil")"
        default:
            orderTitle.text = "error order type"
        }
        totalSum.titleLabel?.text = "$\(String(currentOrder?.totalSum ?? 0))"
        notes.text = currentOrder?.comments
    }
}

// MARK: UITextFieldDelegate
extension TableOrderDetailVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.updateNotes(of: currentOrder!, to: textView.text)
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
    func configureItemDataSource() -> ItemDataSource {
        let dataSource = ItemDataSource(tableView: itemTableView) { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
            
            cell.delegate = self
            cell.indexPath = indexPath
            cell.configure(with: item, of: type(of: self))
            
            return cell
        }
        return dataSource
    }
    
    func updateItemSnapShot(animatingDifferences value:Bool = false) {
        var snapShot = ItemSnapShot()
        snapShot.appendSections([.all])
        snapShot.appendItems(viewModel.getAllItems(of: currentOrder!), toSection: .all)
        
        DispatchQueue.main.async { [unowned self] in
            itemDataSource.apply(snapShot, animatingDifferences: value)
        }
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
extension TableOrderDetailVC: TextFieldChangedDelegate {
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
