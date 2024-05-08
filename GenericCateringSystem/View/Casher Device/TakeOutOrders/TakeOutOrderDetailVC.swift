//
//  TakeOutOrderDetailVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/8.
//
import OSLog
import UIKit

class TakeOutOrderDetailVC: UIViewController {
    // MARK: Properties
    private let logger = Logger(subsystem: "TakeOut", category: "TakeOutOrderDetailVC")
    
    private var viewModel = TakeOutOrderDetailVCViewModel()
    var order: Order?
    
    private lazy var itemDataSource = configureItemDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemTableView.dataSource = itemDataSource
        updateItemSnapShot()
    }
    
    // MARK: IBOutlet
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var sum: UILabel!
    
    @IBOutlet weak var itemTableView: UITableView!
}

// MARK: Item Table View
extension TakeOutOrderDetailVC {
    func configureItemDataSource() -> UITableViewDiffableDataSource<ItemSection, Item> {
        let dataSource = UITableViewDiffableDataSource<ItemSection, Item>(tableView: itemTableView) { (tableView, indexPath, item) -> UITableViewCell? in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
            
            cell.name.text = item.name
            cell.unitPrice.text = "$\(item.price)"
            cell.quantity.text = String(item.quantity)
            
            return cell
        }
        return dataSource
    }
    
    func updateItemSnapShot() {
        var snapShot = NSDiffableDataSourceSnapshot<ItemSection, Item>()
        
        snapShot.appendSections([.all])
        snapShot.appendItems(viewModel.getAllItems(of: order!), toSection: .all)
        
        itemDataSource.apply(snapShot, animatingDifferences: false)
    }
}
