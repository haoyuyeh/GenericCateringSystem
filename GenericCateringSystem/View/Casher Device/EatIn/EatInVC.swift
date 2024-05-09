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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logger.debug("enter: \(self.currentDevice)")
        self.tabBarController?.delegate = self

        tableCollectionView.dataSource = tableDataSource
        updateTableSnapShot()
    }
    
    // MARK: IBOutlet
    @IBOutlet weak var tableCollectionView: UICollectionView!
    
    // MARK: IBAction
    @IBAction func logOutBtnPressed(_ sender: UIButton) {
        // segue to LogInVC
        let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
        
        let destVC = storyboard.instantiateViewController(withIdentifier: "LogIn") as! LogInVC
        destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        destVC.currentDevice = currentDevice
        
        show(destVC, sender: sender)
    }
}
// MARK: - CheckOutDelegate
extension EatInVC: CheckOutDelegate {
    func orderCompleted(at table: UUID) {
        delegate?.tableReleased()
//        delegate?.released(at: table)
    }
}

// MARK: - UICollectionViewDelegate
extension EatInVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TableCell
        if cell.isOcuppied {
            // should check order state before segue to table order details VC
            let outcome = viewModel.hasOngoingOrder(of: cell.uuid)
            if outcome.result {
                let storyboard = UIStoryboard(name: "EatIn", bundle: nil)
                let destVC = storyboard.instantiateViewController(withIdentifier: "TableOrderDetailVC") as! TableOrderDetailVC
                
                destVC.uuid = cell.uuid
                destVC.currentOrder = outcome.order
                destVC.delegate = self
                
                destVC.modalPresentationStyle = .formSheet
                
                show(destVC, sender: self)
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
            cell.configure(target: device)
            self.delegate = cell
            
            return cell
        }
        return dataSource
    }
    
    func updateTableSnapShot(animatingDifferences value:Bool = false) {
        var snapShot = TableSnapShot()
        snapShot.appendSections([.all])
        snapShot.appendItems(viewModel.getAllTable(), toSection: .all)
        
        tableDataSource.apply(snapShot, animatingDifferences: value)
        
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
