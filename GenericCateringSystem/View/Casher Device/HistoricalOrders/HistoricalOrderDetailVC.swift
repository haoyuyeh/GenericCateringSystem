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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        itemTableView.dataSource = itemDataSource
        updateItemSnapShot()
    }
    
    // MARK: IBOutlet
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var sum: UILabel!
    
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
    }
}



// MARK: UITableViewDelegate
extension HistoricalOrderDetailVC {
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
