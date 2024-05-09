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
    
    typealias ItemDataSource = UITableViewDiffableDataSource<ItemSection, Item>
    typealias ItemSnapShot = NSDiffableDataSourceSnapshot<ItemSection, Item>
    private lazy var itemDataSource = configureItemDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        itemTableView.dataSource = itemDataSource
        updateItemSnapShot()
    }
    
    // MARK: IBOutlet
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var sum: UILabel!
    
    @IBOutlet weak var itemTableView: UITableView!
}

// MARK: Helper
extension TakeOutOrderDetailVC {
    func config() {
        switch Int(order!.type) {
        case OrderType.eatIn.rawValue:
            type.text = "Eat-in"
        case OrderType.walkIn.rawValue:
            type.text = "Walk-in"
        default:
            type.text = "\(order?.platformName ?? "nil")"
        }
        number.text = order?.number
        sum.text = "$\(String(order?.totalSum ?? 0))"
    }
}

// MARK: Item Table View
extension TakeOutOrderDetailVC {
    func configureItemDataSource() -> ItemDataSource {
        let dataSource = ItemDataSource(tableView: itemTableView) { (tableView, indexPath, item) -> UITableViewCell? in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
            
            cell.configure(target: item)
            
            return cell
        }
        return dataSource
    }
    
    func updateItemSnapShot() {
        var snapShot = ItemSnapShot()
        
        snapShot.appendSections([.all])
        snapShot.appendItems(viewModel.getAllItems(of: order!), toSection: .all)
        
        itemDataSource.apply(snapShot, animatingDifferences: false)
    }
}
