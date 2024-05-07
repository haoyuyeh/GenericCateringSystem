//
//  TableOrderDetailVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/7.
//
import OSLog
import UIKit

protocol CheckOutDelegate {
    func orderCompleted(of table: UUID)
}

class TableOrderDetailVC: UIViewController {
    // MARK: Properties
    private let logger = Logger(subsystem: "Casher", category: "TableOrderDetailVC")
    private var viewModel = TableOrderDetailVCViewModel()
    var currentOrder: Order?
    var delegate: CheckOutDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: IBOutlet
    @IBOutlet weak var orderTitle: UILabel!
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
            if let text = alert.textFields?[0].text {
                let discount = Double(text) ?? 1.0
                currentOrder?.totalSum = (currentOrder?.totalSum ?? 0.0) * discount
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func checkOutBtnPressed(_ sender: UIButton) {
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
        if let text = textField.text {
            if !text.isMatch(pattern: "^0\\.\\d+$") {
                textField.text = nil
                self.showAlert(alertTitle: "Warning", message: "")
            }
        }else {
            textField.text = nil
        }
    }
}
