//
//  DisplayWalkInVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/18.
//
import OSLog
import UIKit

class DisplayWalkInVC: UIViewController {
    // MARK: Properties
    private let logger = Logger(subsystem: "Display", category: "DisplayWalkInVC")
    
    private var viewModel = DisplayWalkInVCViewModel()
    
    typealias ItemDataSource = UITableViewDiffableDataSource<ItemSection, Item>
    typealias ItemSnapShot = NSDiffableDataSourceSnapshot<ItemSection, Item>
    private lazy var itemDatasource = configureItemTableDataSource()
    
    override func viewIsAppearing(_ animated: Bool) {
        itemTableView.dataSource = itemDatasource
        updateItemSnapShot()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateRemoteChanges), name: .NSPersistentStoreRemoteChange, object: PersistenceService.shared.persistentContainer.persistentStoreCoordinator)
    }
    
    // MARK: IBOutlet
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var totalSum: UILabel!
}

// MARK: Helper
extension DisplayWalkInVC {
    @objc func updateRemoteChanges() {
        DispatchQueue.main.async { [unowned self] in
            updateItemSnapShot()
            itemTableView.reloadData()
        }
    }
}

// MARK: Item Table View
extension DisplayWalkInVC {
    func configureItemTableDataSource() -> ItemDataSource {
        let dataSource = ItemDataSource(tableView: itemTableView) { [unowned self] (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
            
            cell.configure(with: item, of: type(of: self))
            
            return cell
        }
        
        return dataSource
    }
    
    func updateItemSnapShot(animatingDifferences value: Bool = false) {
        var snapShot = ItemSnapShot()
        let items = viewModel.getCurrentWalkInOrderItems()
        
        snapShot.appendSections([.all])
        snapShot.appendItems(items, toSection: .all)
        if snapShot.numberOfItems == 0 {
            itemTableView.noData(msg: "Nothing ordered yet.")
        }else {
            itemTableView.clearBackgroundView()
        }
        totalSum.text = "$\(String(viewModel.updateTotalSum()))"
        
        DispatchQueue.main.async { [unowned self] in
            itemDatasource.apply(snapShot, animatingDifferences: value)
        }
    }
}


