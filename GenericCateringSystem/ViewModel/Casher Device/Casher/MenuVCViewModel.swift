//
//  MenuVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/11/5.
//

import OSLog
import CoreData

class MenuVCViewModel {
    // MARK: Properties
    private let logger = Logger(subsystem: "Cashier", category: "MenuVCViewModel")
    private var currentOrderedItems: [Item] = []
    
}

// MARK: Order Details
extension MenuVCViewModel {
    
}

// MARK: Ordered Item TableView
extension MenuVCViewModel {
    /// get counts of current ordered items
    /// - Returns: Int
    func getCurrentOrderedItemCounts() -> Int {
        return currentOrderedItems.count
    }
    
    /// get name of item at index position from current order
    /// - Parameter index:
    /// - Returns: item name
    func getItemName(at index: Int) -> String {
        return currentOrderedItems[index].name ?? "nil"
    }
    
    /// get quantiy of item at index position from current order
    /// - Parameter index:
    /// - Returns: quantity of item
    func getItemQuantity(at index: Int) -> Int {
        return Int(currentOrderedItems[index].quantity)
    }
    
    /// check whether the new item exists in the order,
    /// if exists, add new quantity to existed one
    /// if not, add new item into order and sort the order
    /// - Parameter newItem:
    func addNewItem(newItem: Item) {
        let isExisted = isItemExisted(newItem: newItem)
        if isExisted.result {
            currentOrderedItems[isExisted.itemIndex!].quantity += newItem.quantity
        }else {
            currentOrderedItems.append(newItem)
            currentOrderedItems = currentOrderedItems.sorted{
                $0.name! < $1.name!
            }
        }
    }
    /// check whether the new item exists in the order,
    /// return result and index of item if there is any
    /// - Parameter newItem:
    /// - Returns: (Bool, Int?) if item existed, return the index of item
    private func isItemExisted(newItem: Item) -> (result: Bool, itemIndex: Int?) {
        // check whether the new item exists in the order,
        if let existedItemIndex = currentOrderedItems.firstIndex(where: { item in
            item.name == newItem.name
        }){
            // if exists, return result and item index
            return (true, existedItemIndex)
        } else{
            return (false, nil)
        }
    }
    
    /// delete item at index position from order
    /// - Parameter index:
    func deleteItem(at index: Int) {
        currentOrderedItems.remove(at: index)
    }
    
    /// change the quantity of item at itemIndex position to newQuantity
    /// - Parameters:
    ///   - itemIndex:
    ///   - newQuantity:
    func changeQuantity(of itemIndex: Int, to newQuantity: Int) {
        currentOrderedItems[itemIndex].quantity = Int16(newQuantity)
    }
}

// MARK: Check Out
extension MenuVCViewModel {
    
}

// MARK: Catagories
extension MenuVCViewModel {
    func getAllCategory() -> [Category] {
        // fetch all data
        return fetchCategory(predicate: NSPredicate(value: true))
    }
}

// MARK: Options
extension MenuVCViewModel {
    func hasMoreOption(of targetUUID: UUID?) -> Bool {
        if let uuid = targetUUID {
            let option = fetchOption(predicate: NSPredicate(format: "uuid == %@", uuid as CVarArg))
            if option.isEmpty {
                return false
            }else {
                return true
            }
        }else {
            logger.error("option uuid is nil")
            return true
        }
    }
    
    func getAllOption(of targetUUID: UUID?, at state: PickItemState) -> [Option] {
        if let uuid = targetUUID {
            switch state {
            case .enterCategory:
                let category = fetchCategory(predicate: NSPredicate(format: "uuid == %@", uuid as CVarArg))
                return category[0].options?.allObjects as! [Option]
            default:
                let option = fetchOption(predicate: NSPredicate(format: "uuid == %@", uuid as CVarArg))
                return option[0].subOptions?.allObjects as! [Option]
            }
        }else {
            return []
        }
    }
    
    func getNameAndUnitPrice(of targetUUID: UUID?) -> (name:String, unitPrice:Double) {
        if let uuid = targetUUID {
            let options = fetchOption(predicate: NSPredicate(format: "uuid == %@", uuid as CVarArg))
            if options != [] {
                return generateItemNameAndUnitPrice(of: options[0])
            }else {
                logger.error("can't find an option match the uuid")
                return ("nil", 0.0)
            }
        }else {
            logger.error("uuid is nil")
            return ("nil", 0.0)
        }
    }
}

// MARK: Helper Functions
extension MenuVCViewModel {
    private func fetchCategory(predicate: NSPredicate) -> [Category] {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = predicate
        do {
            let results = try PersistenceService.managedContext.fetch(fetchRequest)
            return results
        } catch  {
            logger.error("fetch Category failed")
            return []
        }
    }
    
    private func fetchOption(predicate: NSPredicate) -> [Option] {
        let fetchRequest: NSFetchRequest<Option> = Option.fetchRequest()
        fetchRequest.predicate = predicate
        do {
            let results = try PersistenceService.managedContext.fetch(fetchRequest)
            return results
        } catch  {
            logger.error("fetch Option failed")
            return []
        }
    }
    
    private func generateItemNameAndUnitPrice(of option: Option) -> (name:String, unitPrice:Double) {
        var nameReversed: [String] = []
        var item = option
        var totalPrice = 0.0
        
        repeat {
            nameReversed.append(item.name ?? "nil")
            totalPrice += item.price
            item = item.ownedBy!
        }while item.ownedBy != nil
        
        nameReversed.reverse()
        
        var name = nameReversed[0] + " - "
        for i in 1 ... (nameReversed.count - 1) {
            name += nameReversed[i]
            name += ","
        }
        return (name, totalPrice)
    }
}
