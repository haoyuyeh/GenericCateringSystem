//
//  EatInVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/7.
//
import OSLog
import UIKit

class EatInVC: UIViewController {
    // MARK: Properties
    private let logger = Logger(subsystem: "EatIn", category: "EatInVC")
    private var viewModel = EatInVCViewModel()
    var currentDevice: Device?
    
    typealias TableDataSource = UICollectionViewDiffableDataSource<TableSection, Device>
    typealias TableSnapShot = NSDiffableDataSourceSnapshot<TableSection, Device>
    private lazy var tableDataSource = configureTableDataSource()
    
    override func viewIsAppearing(_ animated: Bool) {
        self.tabBarController?.delegate = self
        
        let lpg = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressHandler))
        
        tableCollectionView.addGestureRecognizer(lpg)
        tableCollectionView.dataSource = tableDataSource
        updateTableSnapShot()
        DispatchQueue.main.async { [unowned self] in
            tableCollectionView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "logOut":
            let destVC = segue.destination as! LogInVC
            
            destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            destVC.currentDevice = currentDevice
        case "showTableDetail":
            let sender = sender as! TableCell
            let destVC = segue.destination as! TableOrderDetailVC
            
            destVC.indexPath = sender.indexPath
            destVC.currentOrder = sender.ongoingOrder
            logger.debug("order: \(destVC.currentOrder)")
            destVC.delegate = self
        default:
            logger.error("unknown segue")
            
        }
    }
    
    // MARK: IBOutlet
    @IBOutlet weak var tableCollectionView: UICollectionView!
}

// MARK: - Helper
extension EatInVC {
    @objc func cellLongPressHandler(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: tableCollectionView)
            
            if let indexPath = tableCollectionView.indexPathForItem(at: touchPoint) {
                let cell = tableCollectionView.cellForItem(at: indexPath) as! TableCell
                let alert = UIAlertController(title: "Warning", message: "Do you want to release table?", preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "Yes", style: .destructive) {_ in 
                    cell.tableCanceled()
                }
                let noAction = UIAlertAction(title: "No", style: .cancel)
                
                alert.addAction(yesAction)
                alert.addAction(noAction)
                present(alert, animated: true)
            }
        }
    }
}

// MARK: - CheckOutDelegate
extension EatInVC: EatInTableDelegate {
    func orderCompleted(at table: IndexPath) {
        let cell = tableCollectionView.cellForItem(at: table) as! TableCell
        cell.tableReleased()
        
    }
}

// MARK: - UICollectionViewDelegate
extension EatInVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TableCell
        
        if cell.isOcuppied {
            performSegue(withIdentifier: "showTableDetail", sender: cell)
        }else {
            cell.tableOccupied()
            cell.ongoingOrder = viewModel.addNewOrder(at: "Table #\(cell.tableNumber.text ?? "nil")")
        }
    }
}

// MARK: - Table Collection View
extension EatInVC {
    func configureTableDataSource() -> TableDataSource {
        let dataSource = TableDataSource(collectionView: tableCollectionView){
            (collectionView, indexPath, device) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TableCell", for: indexPath) as! TableCell
            
            cell.indexPath = indexPath
            cell.configure(with: device, of: type(of: self))
            
            return cell
        }
        return dataSource
    }
    
    func updateTableSnapShot(animatingDifferences value:Bool = false) {
        var snapShot = TableSnapShot()
        snapShot.appendSections([.all])
        snapShot.appendItems(viewModel.getAllTable(), toSection: .all)
        
        DispatchQueue.main.async { [unowned self] in
            tableDataSource.apply(snapShot, animatingDifferences: value)
        }
    }
}

// MARK: UITabBarControllerDelegate
extension EatInVC: UITabBarControllerDelegate {
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
