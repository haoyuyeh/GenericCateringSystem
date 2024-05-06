//
//  MenuEditVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/4/25.
//

import OSLog
import UIKit

/// Tell the category cell how to display itself
protocol CategoryDeleteModeDelegate {
    func isEnterDeleteMode(value: Bool)
}
/// Tell the option cell how to display itself
protocol OptionDeleteModeDelegate {
    func isEnterDeleteMode(value: Bool)
}

class MenuEditVC: UIViewController {
    // MARK: Properties
    private let logger = Logger(subsystem: "Cashier", category: "MenuEditVC")
    
    private var viewModel = MenuEditVCViewModel()
    var currentDevice: Device?
    private var pickItemState = PickItemState.enterCategory
    private var selectedCategory: UUID?
    private var selectedOption: UUID?
    
    private var categoryDelegate: CategoryDeleteModeDelegate?
    private var optionDelegate: OptionDeleteModeDelegate?
    
    lazy var categoryDataSource = configureCategoryDataSource()
    lazy var optionDataSource = configureOptionDataSource()
    
    // MARK: IBOutlet
    @IBOutlet weak var addCategoryBtn: UIButton!
    @IBOutlet weak var deleteCategoryBtn: UIButton!
    
    @IBOutlet weak var addOptionBtn: UIButton!
    @IBOutlet weak var deleteOptionBtn: UIButton!
    
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var deleteCancelBtn: UIButton!
    
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var optionCollectionView: UICollectionView!
    
    // MARK: IBAction
    @IBAction func addCategoryBtnPressed(_ sender: UIButton) {
        addCategory()
    }
    
    @IBAction func addOptionBtnPressed(_ sender: UIButton) {
        addOption()
    }
    
    /// show the delete UI which multiple delete is supported
    /// - Parameter sender:
    @IBAction func deleteCategoryBtnPressed(_ sender: UIButton) {
        delete(objectType: .category)
    }
    
    /// show the delete UI which multiple delete is supported
    /// - Parameter sender:
    @IBAction func deleteOptionBtnPressed(_ sender: UIButton) {
        delete(objectType: .option)
    }
    
    /// delete selected categories or options, then return to edit mode
    /// - Parameter sender:
    @IBAction func deleteBtnPressed(_ sender: UIButton) {
        if categoryCollectionView.isUserInteractionEnabled {
            viewModel.deleteCategory(targets: generateDeleteObjects(type: .category))
        }else {
            viewModel.deleteOption(targets: generateDeleteObjects(type: .option))
        }
        config()
    }
    
    /// discard all changes and return to edit mode
    /// - Parameter sender:
    @IBAction func deleteCancelBtnPressed(_ sender: UIButton) {
        config()
    }
    
    
    /// save all data and segue to MenuVC
    /// - Parameter sender:
    @IBAction func OKBtnPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Casher", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        destVC.currentDevice = currentDevice
        viewModel.saveAll()
        
        destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        show(destVC, sender: self)
    }
    
    /// discard all changes and segue to MenuVC
    /// - Parameter sender:
    @IBAction func CancelBtnPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Casher", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        destVC.currentDevice = currentDevice
        viewModel.discardAll()
        
        destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        show(destVC, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
}

// MARK: UITextFieldDelegate
extension MenuEditVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: UICollectionViewDelegate
extension MenuEditVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if deleteBtn.isHidden {
            // construct items
            switch collectionView {
            case categoryCollectionView:
                pickItemState = .enterCategory
                selectedOption = nil
                let cell = categoryCollectionView.cellForItem(at: indexPath) as! CategoryCell
                selectedCategory = cell.uuid
                
                addOptionBtn.isHidden = false
                deleteOptionBtn.isHidden = false
                
                updateOptionSnapshot()
            default:
                pickItemState = .enterOption
                let cell = optionCollectionView.cellForItem(at: indexPath) as! OptionCell
                selectedOption = cell.uuid
                
                updateOptionSnapshot()
            }
        }else {
            // delete mode
            switch collectionView {
            case categoryCollectionView:
                let cell = categoryCollectionView.cellForItem(at: indexPath) as! CategoryCell
                cell.cellIsChoosed = true
            default:
                let cell = optionCollectionView.cellForItem(at: indexPath) as! OptionCell
                cell.cellIsChoosed = true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if !deleteBtn.isHidden {
            // delete mode
            switch collectionView {
            case categoryCollectionView:
                let cell = categoryCollectionView.cellForItem(at: indexPath) as! CategoryCell
                cell.cellIsChoosed = false
            default:
                let cell = optionCollectionView.cellForItem(at: indexPath) as! OptionCell
                cell.cellIsChoosed = false
            }
        }
    }
}

// MARK: Helper Function
enum DeleteObjectType {
    case category
    case option
}

extension MenuEditVC {
    func config() {
        addCategoryBtn.isHidden = false
        deleteCategoryBtn.isHidden = false
        okBtn.isHidden = false
        cancelBtn.isHidden = false
        
        deleteBtn.isHidden = true
        deleteCancelBtn.isHidden = true
        
        selectedCategory = nil
        selectedOption = nil
        addOptionBtn.isHidden = true
        deleteOptionBtn.isHidden = true
        
        categoryCollectionView.allowsMultipleSelection = false
        categoryCollectionView.isUserInteractionEnabled = true
        categoryDelegate?.isEnterDeleteMode(value: !deleteBtn.isHidden)
        // enter delete mode will enable multiple selection, therefore, it should clear all selections
        if let selected = categoryCollectionView.indexPathsForSelectedItems {
            selected.forEach{
                let cell = self.categoryCollectionView.cellForItem(at: $0) as! CategoryCell
                cell.cellIsChoosed = false
                self.categoryCollectionView.deselectItem(at: $0, animated: false)}
        }
        updateCategorySnapshot()
        // reloadData will refresh all data relate to the collection view, such as indexPathsForSelectedItems
        // therefore, if there are some operations relate to the cell, they should be put before reloadData
        categoryCollectionView.reloadData()
        
        optionCollectionView.allowsMultipleSelection = false
        optionCollectionView.isUserInteractionEnabled = true
        optionDelegate?.isEnterDeleteMode(value: !deleteBtn.isHidden)
        if let selected = optionCollectionView.indexPathsForSelectedItems {
            selected.forEach{
                let cell = self.optionCollectionView.cellForItem(at: $0) as! OptionCell
                cell.cellIsChoosed = false
                self.optionCollectionView.deselectItem(at: $0, animated: false)}
        }
        updateOptionSnapshot()
    }
    
    
    /// show an alert to let user enter the info of category
    func addCategory() {
        let alert = UIAlertController(title: nil, message: "Create category", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.delegate = self
            textField.placeholder = "name of category"
            textField.keyboardType = .default
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .words
            textField.clearButtonMode = .whileEditing
        }
        let ok = UIAlertAction(title: "OK", style: .default) { [unowned self] (_) in
            self.viewModel.addCategory(name: alert.textFields![0].text ?? "empty")
            self.updateCategorySnapshot()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    /// show an alert to let user enter the info of option
    func addOption() {
        let alert = UIAlertController(title: nil, message: "Create Option", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.delegate = self
            textField.placeholder = "name of option"
            textField.keyboardType = .default
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .words
            textField.clearButtonMode = .whileEditing
        }
        alert.addTextField { (textField) in
            textField.delegate = self
            textField.placeholder = "unit price of option"
            textField.keyboardType = .decimalPad
            textField.clearButtonMode = .whileEditing
        }
        let ok = UIAlertAction(title: "OK", style: .default) { [unowned self] (_) in
            self.viewModel.addOption(name: alert.textFields![0].text ?? "empty",
                                     unitPrice: Double(Helper.shared.digisGuarantee(input: alert.textFields![1].text ?? "0.0"))!,
                                     belongTo: selectedCategory!,
                                     parent: selectedOption)
            self.updateOptionSnapshot()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    func delete(objectType: DeleteObjectType) {
        addCategoryBtn.isHidden = true
        deleteCategoryBtn.isHidden = true
        addOptionBtn.isHidden = true
        deleteOptionBtn.isHidden = true
        okBtn.isHidden = true
        cancelBtn.isHidden = true
        
        deleteBtn.isHidden = false
        deleteCancelBtn.isHidden = false
        
        categoryDelegate?.isEnterDeleteMode(value: !deleteBtn.isHidden)
        categoryCollectionView.reloadData()
        updateCategorySnapshot()
        
        optionDelegate?.isEnterDeleteMode(value: !deleteBtn.isHidden)
        optionCollectionView.reloadData()
        updateOptionSnapshot()
        
        switch objectType {
        case .category:
            categoryCollectionView.allowsMultipleSelection = true
            optionCollectionView.isUserInteractionEnabled = false
        default:
            optionCollectionView.allowsMultipleSelection = true
            categoryCollectionView.isUserInteractionEnabled = false
        }
    }
    
    /// This function will compile the deleted objects list, based on the selections of collection views
    /// - Parameter type: category or option
    /// - Returns: <#description#>
    func generateDeleteObjects(type: DeleteObjectType) -> [UUID] {
        switch type {
        case .category:
            let selected = categoryCollectionView.indexPathsForSelectedItems ?? []
            var results: [UUID] = []
            selected.forEach { indexPath in
                let cell = categoryCollectionView.cellForItem(at: indexPath) as! CategoryCell
                results.append(cell.uuid!)
            }
            
            return results
        default:
            let selected = optionCollectionView.indexPathsForSelectedItems ?? []
            var results: [UUID] = []
            selected.forEach { indexPath in
                let cell = optionCollectionView.cellForItem(at: indexPath) as! OptionCell
                results.append(cell.uuid!)
            }
            
            return results
        }
    }
}


// MARK: Category CollectionView
extension MenuEditVC {
    func configureCategoryDataSource() -> UICollectionViewDiffableDataSource<CategorySection, Category> {
        let dataSource = UICollectionViewDiffableDataSource<CategorySection, Category>(collectionView: categoryCollectionView) { (collectionView, indexPath, category) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            cell.name.text = category.name
            cell.uuid = category.uuid
            self.categoryDelegate = cell
            self.categoryDelegate?.isEnterDeleteMode(value: !self.deleteBtn.isHidden)
            
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
extension MenuEditVC {
    func configureOptionDataSource() -> UICollectionViewDiffableDataSource<OptionSection, Option> {
        let dataSource = UICollectionViewDiffableDataSource<OptionSection, Option>(collectionView: optionCollectionView) {
            (collectionView, indexPath, option) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionCell", for: indexPath) as! OptionCell
            cell.name.text = option.name
            cell.uuid = option.uuid
            cell.unitPrice.text = String(option.price)
            
            self.optionDelegate = cell
            self.optionDelegate?.isEnterDeleteMode(value: !self.deleteBtn.isHidden)
            
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
            snapshot.appendItems(viewModel.getAllOption(of: selectedCategory, at: PickItemState.enterCategory), toSection: .all)
        case .enterOption:
            snapshot.appendItems(viewModel.getAllOption(of: selectedOption, at: PickItemState.enterOption), toSection: .all)
        default:
            break
        }
        
        optionDataSource.apply(snapshot, animatingDifferences: false)
    }
}
