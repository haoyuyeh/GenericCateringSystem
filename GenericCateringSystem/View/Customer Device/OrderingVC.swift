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
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "logOut":
            let destVC = segue.destination as! LogInVC
            
            destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            destVC.currentDevice = currentDevice
        default:
            logger.error("unknown segue:\(segue.identifier ?? "nil")")
        }
    }
    
    // MARK: IBOutlet
    @IBOutlet weak var tableNumber: UILabel!
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var optionCollectionView: UICollectionView!
}

// MARK: Helpler
extension OrderingVC {
    func config() {
        
        self.tabBarController?.delegate = self
        tableNumber.text = "Table #\(currentDevice?.number ?? "nil")"
        
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
    
    /// Adding choosed item into current order,
    /// if not have one, then create
    func addChoosedItem() {
        if currentOrder == nil {
            currentOrder = viewModel.addNewOrder(at: tableNumber.text!)
        }
        
        viewModel.addNewItem(currentOrder: currentOrder!, selectedOption: selectedOption!)
        pickItemState = .enterCategory
        selectedOption = nil
        
    }
}

// MARK: Helpler
extension OrderingVC: CustomerOptionCellDelegate {
    func addItem(of option: Option, quantity: Int) {
        viewModel
    }
}

// MARK: UICollectionViewDelegate
extension OrderingVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case categoryCollectionView:
            pickItemState = .enterCategory
            let cell = categoryCollectionView.cellForItem(at: indexPath) as! CategoryCell
            selectedCategory = cell.category
            
            updateOptionSnapshot()
        default:
            let cell = optionCollectionView.cellForItem(at: indexPath) as! CustomerOptionCell
            selectedOption = cell.option
            
            if Helper.shared.hasChildren(of: selectedOption!) {
                pickItemState = .enterOption
                cell.plusBtn.isHidden = true
                cell.quantity.isHidden = true
                cell.minusBtn.isHidden = true
                cell.addItemBtn.isHidden = true
                
                updateOptionSnapshot()
            }else {
                pickItemState = .endOfChoic
                cell.plusBtn.isHidden = false
                cell.quantity.isHidden = false
                cell.minusBtn.isHidden = false
                cell.addItemBtn.isHidden = false
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
            
            cell.option = option
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
            snapshot.appendItems(Helper.shared.getAllOption(of: selectedCategory!, at: .enterCategory), toSection: .all)
        case .enterOption:
            snapshot.appendItems(Helper.shared.getAllOption(of: selectedOption!, at: .enterOption), toSection: .all)
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
            
        default:
            logger.error("unrecognized view controller")
        }
    }
}
