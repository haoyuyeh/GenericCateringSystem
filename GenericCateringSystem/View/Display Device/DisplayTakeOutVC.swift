//
//  DisplayTakeOutVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/18.
//
import OSLog
import UIKit

class DisplayTakeOutVC: UIViewController {
    // MARK: Properties
    private let logger = Logger(subsystem: "Display", category: "DisplayTakeOutVC")
    
    private var viewModel = DisplayTakeOutVCViewModel()
        
    typealias OrderDataSource = UITableViewDiffableDataSource<OrdersSection, Order>
    typealias OrderSnapShot = NSDiffableDataSourceSnapshot<OrdersSection, Order>
    private lazy var readyDatasource = configureOrderTableDataSource(tableView: readyTableView)
    private lazy var prepareDatasource = configureOrderTableDataSource(tableView: prepareTableView)
    
    override func viewIsAppearing(_ animated: Bool) {
        readyTableView.dataSource = readyDatasource
        updateReadyOrderSnapShot()
        prepareTableView.dataSource = prepareDatasource
        updatePrepareOrderSnapShot()
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateRemoteChanges), name: .NSPersistentStoreRemoteChange, object: PersistenceService.shared.persistentContainer.persistentStoreCoordinator)
    }
    
    
    // MARK: IBOutlet
    @IBOutlet weak var readyTableView: UITableView!
    @IBOutlet weak var prepareTableView: UITableView!
    
}

// MARK: Helper
extension DisplayTakeOutVC {
    @objc func updateRemoteChanges() {
        DispatchQueue.main.async { [unowned self] in
            updateReadyOrderSnapShot()
            updatePrepareOrderSnapShot()
        }
    }
}


// MARK: Ready & Prepare Table View
extension DisplayTakeOutVC {
    func configureOrderTableDataSource(tableView: UITableView) -> OrderDataSource {
        let dataSource = OrderDataSource(tableView: tableView) { [unowned self] (tableView, indexPath, order) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            
            switch Int(order.type) {
            case OrderType.walkIn.rawValue:
                content.text = "Walk-IN #\(order.number ?? "nil")"
                content.secondaryText = "\(order.establishedDate?.toString(format: nil) ?? "nil")"
                
            case OrderType.deliveryPlatform.rawValue:
                content.text = "\(order.platformName?.capitalized ?? "nil"): \(order.number ?? "nil")"
                content.secondaryText = "\(order.establishedDate?.toString(format: nil) ?? "nil")"
            default:
                logger.error("wrong order type: \(String(order.type))")
                break
            }
            cell.contentConfiguration = content
            
            return cell
        }
        
        return dataSource
    }
    
    func updateReadyOrderSnapShot(animatingDifferences value: Bool = false) {
        var snapShot = OrderSnapShot()
        
        snapShot.appendSections([.walkIn, .deliveryPlatform])
        snapShot.appendItems(viewModel.getOrders(of: .walkIn, at: .waitingPickUp), toSection: .walkIn)
        snapShot.appendItems(viewModel.getOrders(of: .deliveryPlatform, at: .waitingPickUp), toSection: .deliveryPlatform)
        
        if snapShot.numberOfItems == 0 {
            readyTableView.noData(msg: "No Orders!!")
        }else {
            readyTableView.clearBackgroundView()
        }
        
        DispatchQueue.main.async { [unowned self] in
            readyDatasource.apply(snapShot, animatingDifferences: value)
        }
    }
    
    func updatePrepareOrderSnapShot(animatingDifferences value: Bool = false) {
        var snapShot = OrderSnapShot()
        
        snapShot.appendSections([.walkIn, .deliveryPlatform])
        snapShot.appendItems(viewModel.getOrders(of: .walkIn, at: .preparing), toSection: .walkIn)
        snapShot.appendItems(viewModel.getOrders(of: .deliveryPlatform, at: .preparing), toSection: .deliveryPlatform)
        logger.debug("\(snapShot.numberOfItems(inSection: .walkIn))")
        if snapShot.numberOfItems == 0 {
            prepareTableView.noData(msg: "No Orders!!")
        }else {
            prepareTableView.clearBackgroundView()
        }
        DispatchQueue.main.async { [unowned self] in
            prepareDatasource.apply(snapShot, animatingDifferences: value)
        }
    }
}


