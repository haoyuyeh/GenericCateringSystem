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
    
    lazy var categoryDataSource = configureCategoryDataSource()
    lazy var optionDataSource = configureOptionDataSource()
    
    
    // MARK: IBOutlet
    @IBOutlet weak var orderTypeControler: UISegmentedControl!
    @IBOutlet weak var deliveryPlatformNameTF: UITextField!
    @IBOutlet weak var orderNumberTF: UITextField!
    @IBOutlet weak var orderDescriptionTF: UITextField!
    
    @IBOutlet weak var orderTableView: UITableView!
    
    @IBOutlet weak var sumLabel: UILabel!
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var optionCollectionView: UICollectionView!
    
    // MARK: IBAction
    
    @IBAction func orderTypeChanged(_ sender: UISegmentedControl) {
        currentOrder = nil
        viewModel.discardAll()
        orderTableView.reloadData()
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
        guard currentOrder != nil else {
            self.showAlert(alertTitle: "Warning", message: "Not have an order!!!")
            return
        }
        
        // complet order and reset for next order
        viewModel.completOrder(currentOrder: currentOrder!, type: orderTypeControler.selectedSegmentIndex == 0 ? OrderType.deliveryPlatform.rawValue: OrderType.walkIn.rawValue, platformName: deliveryPlatformNameTF.text ?? "nil", number: orderNumberTF.text ?? "nil", comments: orderDescriptionTF.text ?? "nil")
        reset()
    }
    
    @IBAction func logOutBtnPressed(_ sender: UIButton) {
        // segue to LogInVC
        let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
        
        let destVC = storyboard.instantiateViewController(withIdentifier: "LogIn") as! LogInVC
        destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        destVC.currentDevice = currentDevice
        
        show(destVC, sender: sender)
    }
    
    @IBAction func editBtnPressed(_ sender: UIButton) {
        // segue to MenuEditVC
        let storyBoard = UIStoryboard(name: "Casher", bundle: nil)
        let destVC = storyBoard.instantiateViewController(withIdentifier: "MenuEditVC") as! MenuEditVC
        destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        destVC.currentDevice = currentDevice
        
        show(destVC, sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        logger.debug("enter: \(self.currentDevice)")
        
        self.tabBarController?.delegate = self
        viewModel.delegate = self
        
        categoryCollectionView.dataSource = categoryDataSource
        updateCategorySnapshot()
        
        optionCollectionView.dataSource = optionDataSource
        updateOptionSnapshot()
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

// MARK: UITableViewDataSource
extension MenuVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCurrentOrderedItemCounts()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        
        cell.delegate = self
        cell.indexPath = indexPath
        
        cell.name.text = viewModel.getItemName(at: indexPath.row)
        cell.unitPrice.text = viewModel.getItemUnitPrice(at: indexPath.row)
        cell.quantity.text = viewModel.getItemQuantity(at: indexPath.row)
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension MenuVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        viewModel.deleteItem(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
    }
}

// MARK: ItemQuantityDelegate
extension MenuVC: ItemQuantityDelegate {
    func itemQuantityChanged(to num: Int, of index: IndexPath) {
        viewModel.changeQuantity(of: index.row, to: num)
    }
}

// MARK: TotalSumDelegate
extension MenuVC: TotalSumDelegate {
    func totalSumChanged(to sum: Double) {
        sumLabel.text = String(sum)
    }
}

// MARK: Helpler
extension MenuVC {
    /// called when the order completed
    func reset() {
        viewModel.discardAll()
        
        currentOrder = nil
        pickItemState = .enterCategory
        selectedOption = nil
        deliveryPlatformNameTF.text = nil
        orderNumberTF.text = nil
        orderDescriptionTF.text = nil
        sumLabel.text = "0"
        orderTableView.reloadData()
        
        if orderTypeControler.selectedSegmentIndex == 1 {
            orderNumberTF.text = viewModel.getWalkInOrderNumber()
        }
        updateCategorySnapshot()
        updateOptionSnapshot()
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
        
        orderTableView.reloadData()
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
    func configureCategoryDataSource() -> UICollectionViewDiffableDataSource<CategorySection, Category> {
        let dataSource = UICollectionViewDiffableDataSource<CategorySection, Category>(collectionView: categoryCollectionView) {
            (collectionView, indexPath, category) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            cell.name.text = category.name
            cell.uuid = category.uuid
            
            return cell
        }
        return dataSource
    }
    
    func updateCategorySnapshot(animatingChange: Bool = false) {
        
        // Create a snapshot and populate the data
        var snapshot = NSDiffableDataSourceSnapshot<CategorySection, Category>()
        snapshot.appendSections([.all])
        snapshot.appendItems(viewModel.getAllCategory(), toSection: .all)
        
        categoryDataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: Option CollectionView
extension MenuVC {
    func configureOptionDataSource() -> UICollectionViewDiffableDataSource<OptionSection, Option> {
        let dataSource = UICollectionViewDiffableDataSource<OptionSection, Option>(collectionView: optionCollectionView) {
            (collectionView, indexPath, option) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionCell", for: indexPath) as! OptionCell
            cell.name.text = option.name
            cell.unitPrice.text = String(option.price)  
            cell.uuid = option.uuid
            return cell
        }
        return dataSource
    }
    
    func updateOptionSnapshot(animatingChange: Bool = false) {
        
        // Create a snapshot and populate the data
        var snapshot = NSDiffableDataSourceSnapshot<OptionSection, Option>()
        snapshot.appendSections([.all])
        
        switch pickItemState {
        case .enterCategory:
            snapshot.appendItems(viewModel.getAllOption(of: selectedCategory, at: .enterCategory), toSection: .all)
        case .enterOption:
            snapshot.appendItems(viewModel.getAllOption(of: selectedOption, at: .enterOption), toSection: .all)
        default:
            break
        }
        
        optionDataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: UITabBarControllerDelegate
extension MenuVC: UITabBarControllerDelegate {
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
