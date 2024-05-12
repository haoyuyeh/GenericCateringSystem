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
    
    typealias OrderDataSource = UITableViewDiffableDataSource<OrdersSection, Order>
    typealias OrderSnapShot = NSDiffableDataSourceSnapshot<OrdersSection, Order>
    private lazy var orderDataSource = configureOrderDataSource()
    
    override func viewIsAppearing(_ animated: Bool) {
        self.tabBarController?.delegate = self
        orderTableView.register(SectionHeader.self, forHeaderFooterViewReuseIdentifier: SectionHeader.reuseIdentifier)
        orderTableView.dataSource = orderDataSource
        updateOrderSnapShot()
        DispatchQueue.main.async { [unowned self] in
            orderTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "logOut":
            // segue to LogInVC
            let destVC = segue.destination as! LogInVC
            
            destVC.currentDevice = currentDevice
            
            destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            
        case "showTAOrderDetail":
            if let sender = sender as? OrderCell {
                let destVC = segue.destination as! TakeOutOrderDetailVC
                
                destVC.order = sender.order
            }else {
                logger.error("showTAOrderDetail: sender is not OrderCell")
            }
        default:
            logger.error("unknown segue")
        }
    }
    
    // MARK: IBOutlet
    @IBOutlet weak var orderTableView: UITableView!
}

// MARK: Order Table Vie
extension TakeOutOrderVC {
    func configureOrderDataSource() -> OrderDataSource {
        let dataSource = OrderDataSource(tableView: orderTableView) { (tableView, indexPath, order) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderCell
            
            cell.indexPath = indexPath
            cell.delegate = self
            cell.configure(with: order, of: type(of: self))
            
            return cell
        }
        return dataSource
    }
    
    func updateOrderSnapShot(animatingDifferences value: Bool = false) {
        var snapShot = OrderSnapShot()
        
        snapShot.appendSections([.walkIn, .deliveryPlatform])
        snapShot.appendItems(viewModel.getAllTakeOutOrders(with: .walkIn), toSection: .walkIn)
        snapShot.appendItems(viewModel.getAllTakeOutOrders(with: .deliveryPlatform), toSection: .deliveryPlatform)
        
        DispatchQueue.main.async { [unowned self] in
            orderDataSource.apply(snapShot, animatingDifferences: value)
        }
    }
}

// MARK: UITableViewDelegate
extension TakeOutOrderVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: SectionHeader.reuseIdentifier) as? SectionHeader
        else { return nil }
        
        switch section {
        case 0:
            header.title.text = "Walk-In"
            
            return header
            
        case 1:
            header.title.text = "Delivery Platform"
            return header
            
        default:
            return nil
        }
    }
}

// MARK: OrderStatusChangedDelegate
extension TakeOutOrderVC: OrderStatusChangedDelegate {
    func statusChanged(to state: OrderState, of order: Order, at indexPath: IndexPath) {
        viewModel.updateOrderState(to: state, of: order)
        updateOrderSnapShot()
        DispatchQueue.main.async { [unowned self] in
            orderTableView.reloadData()
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
