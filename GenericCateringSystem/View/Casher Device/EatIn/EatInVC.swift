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
    var delegate: TableStateChangedDelegate?
    
    typealias TableDataSource = UICollectionViewDiffableDataSource<TableSection, Device>
    typealias TableSnapShot = NSDiffableDataSourceSnapshot<TableSection, Device>
    private lazy var tableDataSource = configureTableDataSource()
    
    override func viewIsAppearing(_ animated: Bool) {
        self.tabBarController?.delegate = self
        
        tableCollectionView.dataSource = tableDataSource
        updateTableSnapShot()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "logOut":
            let destVC = segue.destination as! LogInVC
            
            destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            destVC.currentDevice = currentDevice
            
        default:
            logger.error("unknown segue")
            
        }
    }
    
    // MARK: IBOutlet
    @IBOutlet weak var tableCollectionView: UICollectionView!
    
    @IBSegueAction func showTableDetail(_ coder: NSCoder, sender: Any?) -> TableOrderDetailVC {
        let sender = sender as! TableCell
        logger.debug("\(sender)")
        let outcome = viewModel.hasOngoingOrder(of: sender.uuid)
        let destVC = TableOrderDetailVC()
        
        destVC.uuid = sender.uuid
        destVC.currentOrder = outcome.order
        destVC.delegate = self
        
        return destVC
    }
}
// MARK: - CheckOutDelegate
extension EatInVC: CheckOutDelegate {
    func orderCompleted(at table: UUID) {
        delegate?.tableReleased()
        //        delegate?.released(at: table)
    }
}

// MARK: - CheckOutDelegate
extension EatInVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TableCell
        
        if cell.isOcuppied {
            // should check order state before segue to table order details VC
            let outcome = viewModel.hasOngoingOrder(of: cell.uuid)
        
            if outcome.result {
                performSegue(withIdentifier: "showTableDetail", sender: cell)
            }else {
                self.showAlert(alertTitle: "Warning", message: "Not Order Yet")
            }
        }else {
            delegate?.tableOccupied()
//            delegate?.occupied(at: cell.uuid!)
        }
    }
}

// MARK: - Table Collection View
extension EatInVC {
    func configureTableDataSource() -> TableDataSource {
        let dataSource = TableDataSource(collectionView: tableCollectionView){
            (collectionView, indexPath, device) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TableCell", for: indexPath) as! TableCell
            
            cell.uuid = device.uuid
            cell.configure(with: device, of: type(of: self))
            self.delegate = cell
            
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
