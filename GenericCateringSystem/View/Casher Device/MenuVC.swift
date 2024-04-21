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
    
    var pickItemState = PickItemState.enterCategory
    var selectedCategory: UUID?
    var selectedOption: UUID?
    var quantityPopup: QuantityPopUpView!
    
    lazy var categoryDataSource = configureCategoryDataSource()
    lazy var optionDataSource = configureOptionDataSource()
    
    
    // MARK: IBOutlet
    // order type change to pull down btn
    @IBOutlet weak var orderTypeTF: UITextField!
    @IBOutlet weak var orderNumberTF: UITextField!
    @IBOutlet weak var orderOthersTF: UITextField!
    
    @IBOutlet weak var orderTableView: UITableView!
    
    @IBOutlet weak var sumLabel: UILabel!
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var optionCollectionView: UICollectionView!
    
    // MARK: IBAction
    
    @IBAction func checkOutBtnPressed(_ sender: UIButton) {
        // complet and save current order. then set current order to nil
    }
    
    @IBAction func logOutBtnPressed(_ sender: UIButton) {
        // segue to LogInVC
    }
    
    @IBAction func editBtnPressed(_ sender: UIButton) {
        // segue to MenuEditVC
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        categoryCollectionView.dataSource = categoryDataSource
        updateCategorySnapshot()
        
        optionCollectionView.dataSource = optionDataSource
        updateOptionSnapshot()
    }
}

// MARK: UITableViewDataSource
extension MenuVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCurrentOrderedItemCounts()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        cell.itemNameLebel.text = viewModel.getItemName(at: indexPath.row)
        
        cell.itemQuantiyBtn.titleLabel?.text = String(viewModel.getItemQuantity(at: indexPath.row))
        
        return cell
    }
}

// MARK: QuantityPopUpViewDelegate
extension MenuVC: QuantityPopUpViewDelegate {
    /// Adding choosed item into current order,
    /// if not have one, then create
    /// - Parameter quantity: quantity of choosed item
    func addChoosedItem(quantity: Int) {
        if currentOrder == nil {
            currentOrder = Order()
            currentOrder?.uuid = UUID()
            currentOrder?.establishedDate = Date()
            currentOrder?.currentState
            currentOrder?.isTakeOut = true
            currentOrder?.type =
            currentOrder?.number = orderNumberTF.text
            currentOrder?.comments = orderOthersTF.text
        }
        var newItem = Item()
        newItem.uuid = UUID()
        newItem.orderedBy = currentOrder
        (newItem.name, newItem.price) = viewModel.getNameAndUnitPrice(of: selectedOption)
        newItem.quantity = Int16(quantity)
        
        quantityPopup.removeFromSuperview()
    }
}

// MARK: UICollectionViewDelegate
enum PickItemState {
    case enterCategory
    case enterOption
    case endOfChoic
}

extension MenuVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case categoryCollectionView:
            pickItemState = .enterCategory
            let cell = categoryCollectionView.cellForItem(at: indexPath) as! CategoryCell
            selectedCategory = cell.uuid
        default:
            
            let cell = optionCollectionView.cellForItem(at: indexPath) as! OptionCell
            selectedOption = cell.uuid
            
            if viewModel.hasMoreOption(of: selectedOption) {
                pickItemState = .enterOption
            }else {
                pickItemState = .endOfChoic
                quantityPopup = QuantityPopUpView(frame: self.view.frame)
                quantityPopup.delegate = self
                self.view.addSubview(quantityPopup)
            }
        }
    }
}

// MARK: Category CollectionView
enum CategorySection {
    case all
}

extension MenuVC {
    func configureCategoryDataSource() -> UICollectionViewDiffableDataSource<CategorySection, Category> {
        let dataSource = UICollectionViewDiffableDataSource<CategorySection, Category>(collectionView: categoryCollectionView) {
            (collectionView, indexPath, catagory) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            cell.name.text = catagory.name
            cell.uuid = catagory.uuid
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
enum OptionSection {
    case all
}

extension MenuVC {
    func configureOptionDataSource() -> UICollectionViewDiffableDataSource<OptionSection, Option> {
        let dataSource = UICollectionViewDiffableDataSource<OptionSection, Option>(collectionView: optionCollectionView) {
            (collectionView, indexPath, option) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionCell", for: indexPath) as! OptionCell
            cell.name.text = option.name
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
