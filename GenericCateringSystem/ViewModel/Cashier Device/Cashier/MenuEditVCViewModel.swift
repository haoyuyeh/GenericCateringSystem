//
//  MenuEditVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/4/25.
//

import OSLog
import CoreData

class MenuEditVCViewModel {
    // MARK: Properties
    private let logger = Logger(subsystem: "Cashier", category: "MenuEditVCViewModel")
}

// MARK: Catagories
extension MenuEditVCViewModel {
    func getAllCategory() -> [Category] {
        // fetch all data
        return Helper.shared.fetchCategory(predicate: NSPredicate(value: true))
    }
    
    /// This function will create a core data object and validate the name of category
    /// - Parameter name:
    func addCategory(name: String) {
        let newCategory = Category(context: PersistenceService.shared.persistentContainer.viewContext)
        newCategory.uuid = UUID()
        if name.isMatch(pattern: "^[\\w\\s-]+$") {
            newCategory.name = name
        }else {
            newCategory.name = "empty"
        }
    }
    
    func deleteCategory(targets: [NSManagedObject]) {
        for target in targets {
            PersistenceService.shared.delete(object: target)
        }
    }
}

// MARK: Options
extension MenuEditVCViewModel {
    /// This function will retrieve all sub-options of given option or root options of given category
    /// - Parameters:
    ///   - targetUUID:
    ///   - state: option or category
    /// - Returns: 
    func getAllOption(of targetUUID: UUID?, at state: PickItemState) -> [Option] {
        if let uuid = targetUUID {
            switch state {
            case .enterCategory:
                // get all options which do not have parent and under this category
                let category = Helper.shared.fetchCategory(predicate: NSPredicate(format: "uuid == %@", uuid as CVarArg))[0]
                return Helper.shared.fetchOption(predicate: NSPredicate(format: "category == %@ && parent == nil", category))
            default:
                let option = Helper.shared.fetchOption(predicate: NSPredicate(format: "uuid == %@", uuid as CVarArg))
                return option[0].children?.allObjects as! [Option]
            }
        }else {
            return []
        }
    }
    
    /// This function will create a core data object and validate the name of option
    /// - Parameters:
    ///   - name:
    ///   - unitPrice:
    ///   - category: which the option is belonged to
    ///   - option: parent option
    func addOption(name: String, unitPrice: Double, belongTo category: Category, parent option: Option?) {
        let newOption = Option(context: PersistenceService.shared.persistentContainer.viewContext)
        
        newOption.uuid = UUID()
        if name.isMatch(pattern: "^[\\w\\s-]+$") {
            newOption.name = name
        }else {
            newOption.name = "empty"
        }
        newOption.price = unitPrice
        newOption.category = category
        if option == nil {
            newOption.parent = nil
        }else {
            newOption.parent = option
        }
    }
    
    func deleteOption(targets: [NSManagedObject]) {
        for target in targets {
            PersistenceService.shared.delete(object: target)
        }
    }
}

// MARK: Helper
extension MenuEditVCViewModel {
    func discardAll() {
        PersistenceService.shared.resetContext()
    }
    
    func saveAll() {
        PersistenceService.shared.saveContext()
    }
}
