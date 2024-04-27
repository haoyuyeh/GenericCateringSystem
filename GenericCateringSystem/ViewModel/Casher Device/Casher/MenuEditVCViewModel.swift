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
        let newCategory = Category(context: PersistenceService.share.persistentContainer.viewContext)
        newCategory.uuid = UUID()
        if name.isMatch(pattern: "^[\\w\\s]+$") {
            newCategory.name = name
        }else {
            newCategory.name = "empty"
        }
//        PersistenceService.share.saveContext()
    }
    
    func deleteCategory(targets: [UUID]) {
        for target in targets {
            let category = Helper.shared.fetchCategory(predicate: NSPredicate(format: "uuid == %@", target as CVarArg))[0]
            PersistenceService.share.delete(object: category)
            logger.debug("category number in database: \(Helper.shared.fetchCategory(predicate: NSPredicate(value: true)))")
        }
    }
}

// MARK: Options
extension MenuEditVCViewModel {
    func getAllOption(of targetUUID: UUID?, at state: PickItemState) -> [Option] {
        if let uuid = targetUUID {
            switch state {
            case .enterCategory:
                // get all options which do not have parent and under this category
                let category = Helper.shared.fetchCategory(predicate: NSPredicate(format: "uuid == %@", uuid as CVarArg))[0]
                return Helper.shared.fetchOption(predicate: NSPredicate(format: "category == %@ AND parent == nil", category))
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
    func addOption(name: String, unitPrice: Double, belongTo category: UUID, parent option: UUID?) {
        let newOption = Option(context: PersistenceService.share.persistentContainer.viewContext)
        
        newOption.uuid = UUID()
        if name.isMatch(pattern: "^[\\w\\s]+$") {
            newOption.name = name
        }else {
            newOption.name = "empty"
        }
        newOption.price = unitPrice
        newOption.category = Helper.shared.fetchCategory(predicate: NSPredicate(format: "uuid  == %@", category as CVarArg))[0]
        if option == nil {
            newOption.parent = nil
        }else {
            newOption.parent = Helper.shared.fetchOption(predicate: NSPredicate(format: "uuid == %@", option! as CVarArg))[0]
        }
                PersistenceService.share.saveContext()
    }
    
    func deleteOption(targets: [UUID]) {
        for target in targets {
            let option = Helper.shared.fetchOption(predicate: NSPredicate(format: "uuid == %@", target as CVarArg))[0]
            PersistenceService.share.delete(object: option)
            logger.debug("option number in database: \(Helper.shared.fetchOption(predicate: NSPredicate(value: true)))")
        }
    }
}


