//
//  KitchenControllCenterVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/6/23.
//
import OSLog
import UIKit

class KitchenControllCenterVC: UIViewController {
    // MARK: Properties
    private let logger = Logger(subsystem: "Kitchen", category: "KitchenControllCenterVC")
    
    private var viewModel = KitchenControllCenterVCViewModel()
    var currentDevice: Device?
    
    typealias OrderDataSource = UITableViewDiffableDataSource<OrdersSection, AnyHashable>
    typealias OrderSnapShot = NSDiffableDataSourceSnapshot<OrdersSection, AnyHashable>
    private lazy var orderDataSource = configureOrderDataSource()
    
    override func viewIsAppearing(_ animated: Bool) {
        orderTableView.dataSource = orderDataSource
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "logOut":
            let destVC = segue.destination as! LogInVC
            
            destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            destVC.currentDevice = currentDevice
        default:
            logger.error("unknown segue:\(segue.identifier ?? "nil")")
        }
    }
    // MARK: IBOutlet
    @IBOutlet weak var orderTableView: UITableView!
}

extension KitchenControllCenterVC {
    func configureOrderDataSource() -> OrderDataSource {
        var dataSource = OrderDataSource(tableView: orderTableView) { [unowned self] (tableView, indexPath, target) -> UITableViewCell? in
            switch target {
            case is Order:
                let order = target as! Order
                let cell = tableView.dequeueReusableCell(withIdentifier: "KorderCell", for: indexPath) as! KorderCell
                
                cell.configure(with: order, of: type(of: self))
                return cell
            case is Item:
                let item = target as! Item
                let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
                
                cell.indexPath = indexPath
                cell.configure(with: item, of: type(of: self))
                return cell
            default:
                logger.error("Wrong type: \(target)")
                return nil
            }
        }
        return dataSource
    }
    
    func updateOrderSnapShot(animatingDifferences value: Bool = false) {
        var snapShot = OrderSnapShot()
        
        snapShot.appendSections([.all])
        snapShot.appendItems(<#T##identifiers: [AnyHashable]##[AnyHashable]#>, toSection: .all)
        
        DispatchQueue.main.async { [unowned self] in
            orderDataSource.apply(snapShot, animatingDifferences: value)
        }
    }
}
