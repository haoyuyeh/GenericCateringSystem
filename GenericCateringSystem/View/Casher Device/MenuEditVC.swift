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
    private var pickItemState = PickItemState.enterCategory
    private var selectedCategory: UUID?
    private var selectedOption: UUID?
    
    lazy var categoryDataSource = configureCategoryDataSource()
    lazy var optionDataSource = configureOptionDataSource()
    
    // MARK: IBOutlet
    @IBOutlet weak var addCategoryBtn: UIButton!
    @IBOutlet weak var deleteCategoryBtn: UIButton!
    
    @IBOutlet weak var addOptionBtn: UIButton!
    @IBOutlet weak var deleteOptionBtn: UIButton!
    
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
    }
    
    /// show the delete UI which multiple delete is supported
    /// - Parameter sender:
    @IBAction func deleteOptionBtnPressed(_ sender: UIButton) {
    }
    
    /// discard all changes and return to previous view
    /// - Parameter sender:
    @IBAction func deleteCancelBtnPressed(_ sender: UIButton) {
    }
    
    
    /// save all data and segue to MenuVC
    /// - Parameter sender:
    @IBAction func OKBtnPressed(_ sender: UIButton) {
        
    }
    
    /// discard all changes and segue to MenuVC
    /// - Parameter sender:
    @IBAction func CancelBtnPressed(_ sender: UIButton) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
}

// MARK: UICollectionViewDelegate
extension MenuEditVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case categoryCollectionView:
            pickItemState = .enterCategory
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
    }
}

// MARK: Helper Function
extension MenuEditVC {
    func config() {
        deleteCancelBtn.isHidden = true
        if selectedCategory == nil {
            addOptionBtn.isHidden = true
            deleteOptionBtn.isHidden = true
        }else {
            addOptionBtn.isHidden = false
            deleteOptionBtn.isHidden = false
        }
        categoryCollectionView.dataSource = categoryDataSource
        updateCategorySnapshot()
        
        optionCollectionView.dataSource = optionDataSource
        updateOptionSnapshot()
    }
    /// show an alert to let user enter the info of category
    func addCategory() {
        let alert = UIAlertController(title: nil, message: "Create category", preferredStyle: .alert)
        alert.addTextField { (textField) in
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
            textField.placeholder = "name of option"
            textField.keyboardType = .default
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .words
            textField.clearButtonMode = .whileEditing
        }
        alert.addTextField { (textField) in
            textField.placeholder = "unit price of option"
            textField.keyboardType = .decimalPad
            textField.clearButtonMode = .whileEditing
        }
        let ok = UIAlertAction(title: "OK", style: .default) { [unowned self] (_) in
            self.viewModel.addOption(name: alert.textFields![0].text ?? "empty", unitPrice: Double(alert.textFields![1].text ?? "0.0")!, belongTo: selectedCategory!, parent: selectedOption)
            self.updateOptionSnapshot()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
}


// MARK: Category CollectionView
extension MenuEditVC {
    func configureCategoryDataSource() -> UICollectionViewDiffableDataSource<CategorySection, Category> {
        let dataSource = UICollectionViewDiffableDataSource<CategorySection, Category>(collectionView: categoryCollectionView) { (collectionView, indexPath, category) -> UICollectionViewCell? in
            
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
extension MenuEditVC {
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
            snapshot.appendItems(viewModel.getAllOption(of: selectedCategory, at: PickItemState.enterCategory), toSection: .all)
        case .enterOption:
            snapshot.appendItems(viewModel.getAllOption(of: selectedOption, at: PickItemState.enterOption), toSection: .all)
        default:
            break
        }
        
        optionDataSource.apply(snapshot, animatingDifferences: false)
    }
}
