//
//  OrderingVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/19.
//
import OSLog
import UIKit

class OrderingVC: UIViewController {
    // MARK: Properties
    private let logger = Logger(subsystem: "Customer", category: "OrderingVC")
    
    private var viewModel = OrderingVCViewModel()
    var currentDevice: Device?
    var currentOrder: Order?
    
    private var pickItemState = PickItemState.enterCategory
    private var selectedCategory: Category?
    private var selectedOption: Option?
    
    typealias CategoryDataSource = UICollectionViewDiffableDataSource<CategorySection, Category>
    typealias CategorySnapShot = NSDiffableDataSourceSnapshot<CategorySection, Category>
    private lazy var categoryDataSource = configureCategoryDataSource()
    
    typealias OptionDataSource = UICollectionViewDiffableDataSource<OptionSection, Option>
    typealias OptionSnapShot = NSDiffableDataSourceSnapshot<OptionSection, Option>
    private lazy var optionDataSource = configureOptionDataSource()
    
    override func viewIsAppearing(_ animated: Bool) {
        config()
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateRemoteChanges), name: .NSPersistentStoreRemoteChange, object: PersistenceService.shared.persistentContainer.persistentStoreCoordinator)
    }
    
    // MARK: IBOutlet
    @IBOutlet weak var tableNumber: UILabel!
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var optionCollectionView: UICollectionView!
}

// MARK: Helpler
extension OrderingVC {
    @objc func updateRemoteChanges() {
        guard let currentOrder = currentOrder else {
            return
        }
        if currentOrder.currentState == OrderState.paid.rawValue {
            self.currentOrder = nil
        }
    }
    
    func config() {
        
        self.tabBarController?.delegate = self
        tableNumber.text = "Table #\(currentDevice?.number ?? "nil")"
        currentOrder = viewModel.checkOngoingOrder(at: tableNumber.text!)
        
        categoryCollectionView.dataSource = categoryDataSource
        optionCollectionView.dataSource = optionDataSource
        updateCategorySnapshot()
        updateOptionSnapshot()
        
        DispatchQueue.main.async { [unowned self] in
            categoryCollectionView.reloadData()
            optionCollectionView.reloadData()
        }
    }
    
    /// called when the order completed or aborted
    func reset() {
        viewModel.clearCurrentOrderedItems()
        
        currentOrder = nil
        pickItemState = .enterCategory
        selectedOption = nil
       
        DispatchQueue.main.async { [unowned self] in
            updateCategorySnapshot()
            updateOptionSnapshot()
            
            categoryCollectionView.reloadData()
            optionCollectionView.reloadData()
        }
    }
}

// MARK: CustomerOptionCellDelegate
extension OrderingVC: CustomerOptionCellDelegate {
    func addItem(of option: Option, quantity: Int) {
        if currentOrder == nil {
            currentOrder = viewModel.addNewOrder(at: tableNumber.text!)
        }
        logger.debug("additem: \(quantity)")

        viewModel.addNewItem(currentOrder: currentOrder!, selectedOption: selectedOption!, quantity: quantity)
        pickItemState = .enterCategory
        selectedOption = nil
    }
}

// MARK: UICollectionViewDelegate
extension OrderingVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch collectionView {
        case optionCollectionView:
            let cell = optionCollectionView.cellForItem(at: indexPath) as! CustomerOptionCell
            cell.hidePurchasPart()
            updateCategorySnapshot()
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case categoryCollectionView:
            pickItemState = .enterCategory
            let cell = categoryCollectionView.cellForItem(at: indexPath) as! CategoryCell
            
            selectedCategory = cell.category
            updateCategorySnapshot()
            updateOptionSnapshot()
            
        default:
            let cell = optionCollectionView.cellForItem(at: indexPath) as! CustomerOptionCell
            selectedOption = cell.option
            
            if Helper.shared.hasChildren(of: selectedOption!) {
                pickItemState = .enterOption
                
                updateOptionSnapshot()
            }else {
                pickItemState = .endOfChoic
                cell.showPurchasPart()
            }
        }
    }
}

// MARK: Category CollectionView
extension OrderingVC {
    func configureCategoryDataSource() -> CategoryDataSource {
        let dataSource = CategoryDataSource(collectionView: categoryCollectionView) {
            (collectionView, indexPath, category) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            
            cell.configure(with: category, of: type(of: self))
            
            return cell
        }
        return dataSource
    }
    
    func updateCategorySnapshot(animatingDifferences value: Bool = false) {
        
        // Create a snapshot and populate the data
        var snapshot = CategorySnapShot()
        snapshot.appendSections([.all])
        snapshot.appendItems(viewModel.getAllCategory(), toSection: .all)
        
        DispatchQueue.main.async { [unowned self] in
            categoryDataSource.apply(snapshot, animatingDifferences: value)
        }
    }
}

// MARK: Option CollectionView
extension OrderingVC {
    func configureOptionDataSource() -> OptionDataSource {
        let dataSource = OptionDataSource(collectionView: optionCollectionView) {
            (collectionView, indexPath, option) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomerOptionCell", for: indexPath) as! CustomerOptionCell
            
            cell.delegate = self
            cell.configure(with: option, of: type(of: self))
            
            return cell
        }
        return dataSource
    }
    
    func updateOptionSnapshot(animatingDifferences value: Bool = false) {
        
        // Create a snapshot and populate the data
        var snapshot = OptionSnapShot()
        snapshot.appendSections([.all])
        
        switch pickItemState {
        case .enterCategory:
            snapshot.appendItems(Helper.shared.getAllOption(of: selectedCategory, at: .enterCategory), toSection: .all)
        case .enterOption:
            snapshot.appendItems(Helper.shared.getAllOption(of: selectedOption, at: .enterOption), toSection: .all)
        default:
            break
        }
        DispatchQueue.main.async { [unowned self] in
            optionDataSource.apply(snapshot, animatingDifferences: value)
        }
    }
}

// MARK: UITabBarControllerDelegate
extension OrderingVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch tabBarController.selectedIndex {
        case 0:
            let vc = viewController as! OrderingVC
            vc.currentDevice = currentDevice

        case 1:
            let vc = viewController as! OrderDetailVC
            vc.currentDevice = currentDevice
            vc.currentOrder = currentOrder
        default:
            logger.error("unrecognized view controller")
        }
    }
}
