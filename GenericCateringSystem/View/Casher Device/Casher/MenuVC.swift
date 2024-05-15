//
//  MenuVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/11/5.
//

import OSLog
import UIKit

class MenuVC: UIViewController {
    // MARK: Properties
    private let logger = Logger(subsystem: "Cashier", category: "MenuVC")
    
    private var viewModel = MenuVCViewModel()
    var currentDevice: Device?
    var currentOrder: Order?
    
    private var pickItemState = PickItemState.enterCategory
    private var selectedCategory: UUID?
    private var selectedOption: UUID?
    
    typealias OrderDataSource = UITableViewDiffableDataSource<ItemSection, Item>
    typealias OrdrSnapShot = NSDiffableDataSourceSnapshot<ItemSection, Item>
    private lazy var itemDataSource = configureOrderDataSource()
    
    typealias CategoryDataSource = UICollectionViewDiffableDataSource<CategorySection, Category>
    typealias CategorySnapShot = NSDiffableDataSourceSnapshot<CategorySection, Category>
    private lazy var categoryDataSource = configureCategoryDataSource()
    
    typealias OptionDataSource = UICollectionViewDiffableDataSource<OptionSection, Option>
    typealias OptionSnapShot = NSDiffableDataSourceSnapshot<OptionSection, Option>
    private lazy var optionDataSource = configureOptionDataSource()
    
    override func viewIsAppearing(_ animated: Bool) {
        config()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        viewModel.discardAll()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "logOut":
            let destVC = segue.destination as! LogInVC
            
            destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            destVC.currentDevice = currentDevice
        case "editMenu":
            let destVC = segue.destination as! MenuEditVC
            
            destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            destVC.currentDevice = currentDevice
            
        default:
            logger.error("unknown segue")
            
        }
    }
    
    // MARK: IBOutlet
    @IBOutlet weak var orderTypeControler: UISegmentedControl!
    @IBOutlet weak var deliveryPlatformNameTF: UITextField!
    @IBOutlet weak var orderNumberTF: UITextField!
    @IBOutlet weak var notes: UITextView!
    
    @IBOutlet weak var orderTableView: UITableView!
    
    @IBOutlet weak var sumLabel: UILabel!
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var optionCollectionView: UICollectionView!
    
    // MARK: IBAction
    
    @IBAction func orderTypeChanged(_ sender: UISegmentedControl) {
        reset()
        
        switch sender.selectedSegmentIndex {
            // delivery platform
        case 0:
            deliveryPlatformNameTF.isHidden = false
            orderNumberTF.isEnabled = true
            orderNumberTF.text = nil
            // Walk-in
        default:
            deliveryPlatformNameTF.isHidden = true
            orderNumberTF.isEnabled = false
            orderNumberTF.text = viewModel.getWalkInOrderNumber()
        }
    }
    
    @IBAction func checkOutBtnPressed(_ sender: UIButton) {
        guard let order = currentOrder else {
            self.showAlert(alertTitle: "Warning", message: "Not have an order!!!")
            return
        }
        
        // complet order and reset for next order
        viewModel.completOrder(currentOrder: order, type: orderTypeControler.selectedSegmentIndex == 0 ? OrderType.deliveryPlatform.rawValue: OrderType.walkIn.rawValue, platformName: deliveryPlatformNameTF.text ?? "nil", number: orderNumberTF.text ?? "nil", comments: notes.text)
        reset()
    }
}

// MARK: UITextFieldDelegate
extension MenuVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            notes.textColor = UIColor.lightGray
            notes.text = "Enter notes here."
        }
    }
}


// MARK: UITextFieldDelegate
extension MenuVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: Order Table View
extension MenuVC {
    func configureOrderDataSource() -> OrderDataSource {
        let dataSource = OrderDataSource(tableView: orderTableView) { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
            
            cell.delegate = self
            cell.indexPath = indexPath
            cell.configure(with: item, of: type(of: self))
            
            return cell
        }
        return dataSource
    }
    
    func updateOrderSnapShot(animatingDifferences value: Bool = false) {
        var snapshot = OrdrSnapShot()
        
        snapshot.appendSections([.all])
        snapshot.appendItems(viewModel.getAllItems(of: currentOrder).sorted{
            $0.name! < $1.name!
        }, toSection: .all)
        
        itemDataSource.apply(snapshot, animatingDifferences: value)
    }
}

// MARK: UITableViewDelegate
extension MenuVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] action, view, handler in
            viewModel.deleteItem(at: indexPath.row)
            
            DispatchQueue.main.async { [unowned self] in
                updateOrderSnapShot(animatingDifferences: true)
                orderTableView.reloadData()
            }
        }
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}

// MARK: ItemQuantityDelegate
extension MenuVC: TextFieldChangedDelegate {
    func itemQuantityChanged(to num: Int, of index: IndexPath) {
        viewModel.changeQuantity(of: index.row, to: num)
    }
}

// MARK: TotalSumDelegate
extension MenuVC: TotalSumDelegate {
    func totalSumChanged(to sum: Double) {
        sumLabel.text = String("$\(sum)")
    }
}

// MARK: Helpler
extension MenuVC {
    func config() {
        self.tabBarController?.delegate = self
        viewModel.delegate = self
        
        if currentOrder != nil && currentOrder?.comments != nil {
            notes.textColor = UIColor.black
            notes.text = currentOrder?.comments
        }else {
            notes.textColor = UIColor.lightGray
            notes.text = "Enter notes here."
        }
        
        orderTableView.dataSource = itemDataSource
        categoryCollectionView.dataSource = categoryDataSource
        optionCollectionView.dataSource = optionDataSource
        updateOrderSnapShot()
        updateCategorySnapshot()
        updateOptionSnapshot()
        
        DispatchQueue.main.async { [unowned self] in
            orderTableView.reloadData()
            categoryCollectionView.reloadData()
            optionCollectionView.reloadData()
        }
    }
    
    /// called when the order completed
    func reset() {
        viewModel.discardAll()
        
        currentOrder = nil
        pickItemState = .enterCategory
        selectedOption = nil
        deliveryPlatformNameTF.text = nil
        orderNumberTF.text = nil
        notes.textColor = UIColor.lightGray
        notes.text = "Enter notes here."
        sumLabel.text = "$0"
        
        if orderTypeControler.selectedSegmentIndex == 1 {
            orderNumberTF.text = viewModel.getWalkInOrderNumber()
        }
        
        DispatchQueue.main.async { [unowned self] in
            updateOrderSnapShot()
            updateCategorySnapshot()
            updateOptionSnapshot()
            
            orderTableView.reloadData()
            categoryCollectionView.reloadData()
            optionCollectionView.reloadData()
        }
    }
    
    /// Adding choosed item into current order,
    /// if not have one, then create
    func addChoosedItem() {
        if currentOrder == nil {
            currentOrder = viewModel.addNewOrder()
        }
        
        viewModel.addNewItem(currentOrder: currentOrder!, selectedOption: selectedOption!)
        pickItemState = .enterCategory
        selectedOption = nil
        
        DispatchQueue.main.async { [unowned self] in
            updateOrderSnapShot()
            orderTableView.reloadData()
        }
    }
}

// MARK: UICollectionViewDelegate
extension MenuVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case categoryCollectionView:
            pickItemState = .enterCategory
            let cell = categoryCollectionView.cellForItem(at: indexPath) as! CategoryCell
            selectedCategory = cell.uuid
            
            updateOptionSnapshot()
        default:
            let cell = optionCollectionView.cellForItem(at: indexPath) as! OptionCell
            selectedOption = cell.uuid
            
            if viewModel.hasChildrenOption(of: selectedOption) {
                pickItemState = .enterOption
                
                updateOptionSnapshot()
            }else {
                pickItemState = .endOfChoic
                addChoosedItem()
            }
        }
    }
}

// MARK: Category CollectionView
extension MenuVC {
    func configureCategoryDataSource() -> CategoryDataSource {
        let dataSource = CategoryDataSource(collectionView: categoryCollectionView) {
            (collectionView, indexPath, category) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            
            cell.uuid = category.uuid
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
extension MenuVC {
    func configureOptionDataSource() -> OptionDataSource {
        let dataSource = OptionDataSource(collectionView: optionCollectionView) {
            (collectionView, indexPath, option) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionCell", for: indexPath) as! OptionCell
            
            cell.uuid = option.uuid
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
            snapshot.appendItems(viewModel.getAllOption(of: selectedCategory, at: .enterCategory), toSection: .all)
        case .enterOption:
            snapshot.appendItems(viewModel.getAllOption(of: selectedOption, at: .enterOption), toSection: .all)
        default:
            break
        }
        DispatchQueue.main.async { [unowned self] in
            optionDataSource.apply(snapshot, animatingDifferences: value)
        }
    }
}

// MARK: UITabBarControllerDelegate
extension MenuVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        reset()
        
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
