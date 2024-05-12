//
//  MenuEditVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/4/25.
//

import OSLog
import UIKit

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
    
    typealias CategoryDataSource = UICollectionViewDiffableDataSource<CategorySection, Category>
    typealias CategorySnapShot = NSDiffableDataSourceSnapshot<CategorySection, Category>
    private lazy var categoryDataSource = configureCategoryDataSource()
    
    typealias OptionDataSource = UICollectionViewDiffableDataSource<OptionSection, Option>
    typealias OptionSnapShot = NSDiffableDataSourceSnapshot<OptionSection, Option>
    private lazy var optionDataSource = configureOptionDataSource()
    
    override func viewIsAppearing(_ animated: Bool) {
        categoryCollectionView.dataSource = categoryDataSource
        updateCategorySnapshot()
        optionCollectionView.dataSource = optionDataSource
        updateOptionSnapshot()
        config()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ok":
            viewModel.saveAll()
            
        case "cancel":
            viewModel.discardAll()
            
        default:
            logger.error("unknown segue")
            
            return
        }
        
        let destVC = segue.destination as! UITabBarController
        
        destVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        destVC.selectedIndex = 0
        
        let menuVC = destVC.selectedViewController as! MenuVC
        menuVC.currentDevice = currentDevice
    }
    
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
        // enter delete mode will enable multiple selection, therefore, it should clear all selections
        if let selected = categoryCollectionView.indexPathsForSelectedItems {
            selected.forEach{
                let cell = self.categoryCollectionView.cellForItem(at: $0) as! CategoryCell
                cell.cellIsChoosed = false
                self.categoryCollectionView.deselectItem(at: $0, animated: false)}
        }
        categoryDelegate?.isEnterDeleteMode(value: !deleteBtn.isHidden)

        // reloadData will refresh all data relate to the collection view, such as indexPathsForSelectedItems
        // therefore, if there are some operations relate to the cell, they should be put before reloadData
        DispatchQueue.main.async { [unowned self] in
            categoryCollectionView.reloadData()
        }
        
        optionCollectionView.allowsMultipleSelection = false
        optionCollectionView.isUserInteractionEnabled = true
        if let selected = optionCollectionView.indexPathsForSelectedItems {
            selected.forEach{
                let cell = self.optionCollectionView.cellForItem(at: $0) as! OptionCell
                cell.cellIsChoosed = false
                self.optionCollectionView.deselectItem(at: $0, animated: false)}
        }
        optionDelegate?.isEnterDeleteMode(value: !deleteBtn.isHidden)
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
        updateCategorySnapshot()
        DispatchQueue.main.async { [unowned self] in
            categoryCollectionView.reloadData()
        }
        
        optionDelegate?.isEnterDeleteMode(value: !deleteBtn.isHidden)
        updateOptionSnapshot()
        DispatchQueue.main.async { [unowned self] in
            optionCollectionView.reloadData()
        }
        
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
    func configureCategoryDataSource() -> CategoryDataSource {
        let dataSource = CategoryDataSource(collectionView: categoryCollectionView) { (collectionView, indexPath, category) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            
            cell.uuid = category.uuid
            cell.configure(with: category, of: type(of: self))
            self.categoryDelegate = cell
            self.categoryDelegate?.isEnterDeleteMode(value: !self.deleteBtn.isHidden)
            
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
extension MenuEditVC {
    func configureOptionDataSource() -> OptionDataSource {
        let dataSource = OptionDataSource(collectionView: optionCollectionView) {
            (collectionView, indexPath, option) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionCell", for: indexPath) as! OptionCell
            
            cell.uuid = option.uuid
            cell.configure(with: option, of: type(of: self))
            self.optionDelegate = cell
            self.optionDelegate?.isEnterDeleteMode(value: !self.deleteBtn.isHidden)
            
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
            snapshot.appendItems(viewModel.getAllOption(of: selectedCategory, at: PickItemState.enterCategory), toSection: .all)
        case .enterOption:
            snapshot.appendItems(viewModel.getAllOption(of: selectedOption, at: PickItemState.enterOption), toSection: .all)
        default:
            break
        }
        
        DispatchQueue.main.async { [unowned self] in
            optionDataSource.apply(snapshot, animatingDifferences: value)
        }
    }
}
