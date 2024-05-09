//
//  TakeOutOrderVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/8.
//
import OSLog
import UIKit

class TakeOutOrderVC: UIViewController {
    // MARK: Properties
    private let logger = Logger(subsystem: "TakeOut", category: "TakeOutOrderVC")
    
    private var viewModel = TakeOutOrderVCViewModel()
    var currentDevice: Device?
    
    typealias OrderDataSource = UITableViewDiffableDataSource<OrderSection, Order>
    typealias OrderSnapShot = NSDiffableDataSourceSnapshot<OrderSection, Order>
    private lazy var orderDataSource = configureOrderDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
        orderTableView.dataSource = orderDataSource
        updateOrderSnapShot()
    }
    
    // MARK: IBOutlet
    @IBOutlet weak var orderTableView: UITableView!
    
    // MARK: IBAction
    @IBAction func logOutBtnPressed(_ sender: UIButton) {
        // segue to LogInVC
        let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "LogIn") as! LogInVC
        
        destVC.currentDevice = currentDevice
        
        destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        show(destVC, sender: sender)
    }
}

// MARK: UITableViewDelegate
extension TakeOutOrderVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // segue to TakeOutOrderDetailVC
        let storyboard = UIStoryboard(name: "TakeOut", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "TakeOutOrderDetailVC") as! TakeOutOrderDetailVC
        let cell = tableView.cellForRow(at: indexPath) as! OrderCell
        
        destVC.order = cell.order
        
        destVC.modalPresentationStyle = UIModalPresentationStyle.currentContext
        show(destVC, sender: self)
    }
}

// MARK: Order Table View
extension TakeOutOrderVC {
    func configureOrderDataSource() -> OrderDataSource {
        let dataSource = OrderDataSource(tableView: orderTableView) { [unowned self] (tableView, indexPath, order) -> UITableViewCell? in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderCell
            
            cell.indexPath = indexPath
            cell.delegate = self
            cell.configure(target: order)
            
            return cell
        }
        return dataSource
    }
    
    func updateOrderSnapShot() {
        var snapShot = OrderSnapShot()
        snapShot.appendSections([.all])
        snapShot.appendItems(viewModel.getAllTakeOutOrders(), toSection: .all)
        
        orderDataSource.apply(snapShot, animatingDifferences: false)
    }
}

// MARK: OrderStatusChangedDelegate
extension TakeOutOrderVC: OrderStatusChangedDelegate {
    func statusChanged(to state: OrderState, of order: Order, at indexPath: IndexPath) {
        viewModel.updateOrderState(to: state, of: order)
        if state == OrderState.orderDelivered {
            orderTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: UITabBarControllerDelegate
extension TakeOutOrderVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch tabBarController.selectedIndex {
        case 0:
            let vc = viewController as! MenuVC
            vc.currentDevice = currentDevice
            
        case 1:
            let vc = viewController as! EatInVC
            vc.currentDevice = currentDevice
            
        case 2:
            let vc = viewController as! TakeOutOrderVC
            vc.currentDevice = currentDevice
            
        case 3:
            let vc = viewController as! HistoricalOrderVC
            vc.currentDevice = currentDevice
            
        default:
            logger.error("unrecognized view controller")
        }
    }
}
