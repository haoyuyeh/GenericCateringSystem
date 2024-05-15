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
    
    typealias HistoricalOrderDataSource = UITableViewDiffableDataSource<OrdersSection, Order>
    typealias HistoricalOrderSnapShot = NSDiffableDataSourceSnapshot<OrdersSection, Order>
    private lazy var historicalOrderDataSource = configureHistoricalOrderDataSource()
    
    override func viewIsAppearing(_ animated: Bool) {
        datePicker.contentHorizontalAlignment = .fill
        datePicker.contentVerticalAlignment = .fill
        self.tabBarController?.delegate = self
        historicalOrderTableView.register(SectionHeader.self, forHeaderFooterViewReuseIdentifier: SectionHeader.reuseIdentifier)
        historicalOrderTableView.dataSource = historicalOrderDataSource
        updateHistoricalOrderDataSource()
        DispatchQueue.main.async { [unowned self] in
            historicalOrderTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "logOut":
            // segue to LogInVC
            let destVC = segue.destination as! LogInVC
            
            destVC.currentDevice = currentDevice
            destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        case "showOrderDetail":
            let destVC = segue.destination as! HistoricalOrderDetailVC
            let cell = sender as! OrderCell
            
            destVC.order = cell.order
            
        default:
            logger.error("unknown segue")
        }
    }
    
    // MARK: IBOutlet
    @IBOutlet weak var historicalOrderTableView: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    // MARK: IBAction
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        targetDate = datePicker.date
        updateHistoricalOrderDataSource()
    }
    
}

// MARK: UITableViewDelegate
extension HistoricalOrderVC: UITableViewDelegate {
    
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
            header.title.text = "Eat-In"
            
            return header
        case 1:
            header.title.text = "Walk-In"
            
            return header
        case 2:
            header.title.text = "Delivery Platform"
            return header
            
        default:
            return nil
        }
    }
}

// MARK: Historical Order Table View
extension HistoricalOrderVC {
    func configureHistoricalOrderDataSource() -> HistoricalOrderDataSource {
        let dataSource = HistoricalOrderDataSource(tableView: historicalOrderTableView) { (tableView, indexPath, order) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderCell
            
            cell.configure(with: order, of: type(of: self))
            return cell
        }
        return dataSource
    }
    
    func updateHistoricalOrderDataSource() {
        var snapShot = HistoricalOrderSnapShot()
        
        snapShot.appendSections([.eatIn, .walkIn, .deliveryPlatform])
        snapShot.appendItems(viewModel.getAllHistoricalOrders(on: targetDate, for: .eatIn), toSection: .eatIn)
        snapShot.appendItems(viewModel.getAllHistoricalOrders(on: targetDate, for: .walkIn), toSection: .walkIn)
        snapShot.appendItems(viewModel.getAllHistoricalOrders(on: targetDate, for: .deliveryPlatform), toSection: .deliveryPlatform)
        
        DispatchQueue.main.async { [unowned self] in
            historicalOrderDataSource.apply(snapShot, animatingDifferences: false)
        }
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
