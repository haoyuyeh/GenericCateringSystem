//
//  HistoricalOrderDetailVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/9.
//

import UIKit

class HistoricalOrderDetailVC: UIViewController {
    // MARK: Properties
    private var viewModel = HistoricalOrderDetailVCViewModel()
    var order: Order?
    
    typealias ItemDataSource = UITableViewDiffableDataSource<ItemSection, Item>
    typealias ItemSnapShot = NSDiffableDataSourceSnapshot<ItemSection, Item>
    private lazy var itemDataSource = configureItemDataSource()
    
    override func viewIsAppearing(_ animated: Bool) {
        config()
    }
    
    // MARK: IBOutlet
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var sum: UILabel!
    @IBOutlet weak var notes: UITextView!
    
    @IBOutlet weak var itemTableView: UITableView!
}

// MARK: Helper
extension HistoricalOrderDetailVC {
    func config() {
        switch Int(order!.type) {
        case OrderType.eatIn.rawValue:
            name.text = "Eat-in"
        case OrderType.walkIn.rawValue:
            name.text = "Walk-in"
        default:
            name.text = "\(order?.platformName ?? "nil")"
        }
        number.text = order?.number
        sum.text = "$\(String(order?.totalSum ?? 0))"
        
        switch Int(order!.currentState) {
        case OrderState.orderNotFinished.rawValue:
            notes.isEditable = true
            if let notes = order?.comments {
                self.notes.textColor = UIColor.black
                self.notes.text = notes
            }else {
                self.notes.textColor = UIColor.lightGray
                self.notes.text = "Enter the reasons why the order didn't finish."
            }
        default:
            notes.isEditable = false
            notes.text = order?.comments ?? ""
        }
        
        
        
        
        itemTableView.dataSource = itemDataSource
        updateItemSnapShot()
    }
}

extension HistoricalOrderDetailVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = UIColor.lightGray
            textView.text = "Enter the reasons why the order didn't finish."
        }else {
            viewModel.updateNotes(to: textView.text, of: order!)
        }
    }
}

// MARK: Item Table View
extension HistoricalOrderDetailVC {
    func configureItemDataSource() -> ItemDataSource {
        let dataSource = ItemDataSource(tableView: itemTableView) { (tableView, indexPath, item) -> UITableViewCell? in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
            
            cell.configure(with: item, of: type(of: self))
            
            return cell
        }
        return dataSource
    }
    
    func updateItemSnapShot() {
        var snapShot = ItemSnapShot()
        
        snapShot.appendSections([.all])
        snapShot.appendItems(viewModel.getAllItems(of: order!), toSection: .all)
        
        DispatchQueue.main.async { [unowned self] in
            itemDataSource.apply(snapShot, animatingDifferences: false)
        }
    }
}
