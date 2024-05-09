//
//  HistoricalOrderVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/8.
//
import OSLog
import UIKit

class HistoricalOrderVC: UIViewController {
    // MARK: Properties
    private let logger = Logger(subsystem: "HistoricalOrders", category: "HistoricalOrderVC")
    private var viewModel = HistoricalOrderVCViewModel()
    var currentDevice: Device?
    private var targetDate = Date()
    
    private lazy var historicalOrderDataSource = configureHistoricalOrderDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
        historicalOrderTableView.dataSource = historicalOrderDataSource
        updateHistoricalOrderDataSource()
    }
    
    // MARK: IBOutlet
    @IBOutlet weak var historicalOrderTableView: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    // MARK: IBAction
    @IBAction func logOutBtnPressed(_ sender: UIButton) {
        // segue to LogInVC
        let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "LogIn") as! LogInVC
        
        destVC.currentDevice = currentDevice
        
        destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        show(destVC, sender: sender)
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        targetDate = datePicker.date
        updateHistoricalOrderDataSource()
    }
    
}

// MARK: UITableViewDelegate
extension HistoricalOrderVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderCell
        // segue to HistoricalOrderDetailVC
        let storyboard = UIStoryboard(name: "HistoricalOrders", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "HistoricalOrderDetailVC") as! HistoricalOrderDetailVC
        
        destVC.order = cell.order
        
        destVC.modalPresentationStyle = UIModalPresentationStyle.currentContext
        show(destVC, sender: self)
    }
}

// MARK: Historical Order Table View
extension HistoricalOrderVC {
    func configureHistoricalOrderDataSource() -> UITableViewDiffableDataSource<OrderSection, Order> {
        let dataSource = UITableViewDiffableDataSource<OrderSection, Order>(tableView: historicalOrderTableView) { (tableView, indexPath, order) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderCell
            
            cell.indexPath = indexPath
            cell.order = order
            
            switch Int(order.type) {
            case OrderType.eatIn.rawValue:
                cell.name.text = "Eat-in - Table #\(order.number ?? "nil")"
            case OrderType.walkIn.rawValue:
                cell.name.text = "Walk-in #\(order.number ?? "nil")"
            default:
                cell.name.text = "\(order.platformName ?? "nil") - \(order.number ?? "nil")"
            }
            cell.number.text = order.establishedDate?.toString(format: nil, dateStyle: .omitted, timeStyle: .standard)
            
            return cell
        }
        return dataSource
    }
    
    func updateHistoricalOrderDataSource() {
        var snapShot = NSDiffableDataSourceSnapshot<OrderSection, Order>()
        
        snapShot.appendSections([.eatIn, .walkIn, .deliveryPlatform])
        snapShot.appendItems(viewModel.getAllHistoricalOrders(on: targetDate, for: .eatIn), toSection: .eatIn)
        snapShot.appendItems(viewModel.getAllHistoricalOrders(on: targetDate, for: .walkIn), toSection: .walkIn)
        snapShot.appendItems(viewModel.getAllHistoricalOrders(on: targetDate, for: .deliveryPlatform), toSection: .deliveryPlatform)
        
        historicalOrderDataSource.apply(snapShot, animatingDifferences: false)
    }
}

// MARK: UITabBarControllerDelegate
extension HistoricalOrderVC: UITabBarControllerDelegate {
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
