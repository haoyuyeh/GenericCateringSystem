//
//  OrderingVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/19.
//

import OSLog
import CoreData

class OrderingVCViewModel {
    // MARK: Properties
    private let logger = Logger(subsystem: "Customer", category: "OrderingVCViewModel")
    
    private var currentOrderedItems: [Item] = []
}

// MARK: Ordered Item TableView
extension OrderingVCViewModel {
    func getCurrentOrderedItems() -> [Item] {
        return currentOrderedItems
    }
    
    /// 1. check whether the new item exists in the order,
    /// if exists, add new quantity to existed one
    /// if not, add new item into order and sort the order
    /// 2. update the total sum of the order
    /// - Parameters:
    ///   - order:
    ///   - option:
    ///   - q:
    func addNewItem(currentOrder order: Order, selectedOption option: Option) {
        let newItem = Item(context: PersistenceService.shared.persistentContainer.viewContext)
        newItem.uuid = UUID()
        // use option to trace back the correct item name and price
        (newItem.name, newItem.price) = Helper.shared.getNameAndUnitPrice(of: option)
        newItem.quantity = 1
        
        let isExisted = isItemExisted(newItem: newItem)
        if isExisted.result {
            currentOrderedItems[isExisted.itemIndex!].quantity += newItem.quantity
            PersistenceService.shared.delete(object: newItem)
        }else {
            newItem.orderedBy = order
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
    
    /// 1. delete item at index position and coredata from order
    /// 2. update total sum of the order
    /// - Parameter index:
    func deleteItem(at index: Int) {
        
        let deletedItem = currentOrderedItems.remove(at: index)
        PersistenceService.shared.delete(object: deletedItem)
    }
    
    /// 1. change the quantity of item at itemIndex position to newQuantity
    /// 2. update total sum of the order
    /// - Parameters:
    ///   - itemIndex:
    ///   - newQuantity:
    func changeQuantity(of itemIndex: Int, to newQuantity: Int) {
        currentOrderedItems[itemIndex].quantity = Int16(newQuantity)
    }
}

// MARK: Confirm Order
extension OrderingVCViewModel {
    
    /// call when customer confirm ordering, this will save all changes to core data
    /// - Parameters:
    ///   - order:
    ///   - note:
    func confirmOrder(currentOrder order: Order, comments note: String) {
        
        if let oldNote = order.comments {
            order.comments = oldNote + "\n" + note
        }else {
            order.comments = note
        }

        saveAll()
    }
}

// MARK: Catagories
extension OrderingVCViewModel {
    func getAllCategory() -> [Category] {
        // fetch all data
        return Helper.shared.fetchCategory(predicate: NSPredicate(value: true))
    }
}

// MARK: Options
//extension OrderingVCViewModel {
//    func hasChildrenOption(of targetUUID: UUID?) -> Bool {
//        if let uuid = targetUUID {
//            let option = Helper.shared.fetchOption(predicate: NSPredicate(format: "uuid == %@", uuid as CVarArg))[0]
//            let children = option.children?.allObjects as! [Option]
//            if children.isEmpty {
//                return false
//            }else {
//                return true
//            }
//        }else {
//            /**
//             return true will keep the state of pickItemState in enterOption,
//             therefore, user can sense the error
//             */
//            logger.error("option uuid is nil")
//            return true
//        }
//    }
//    
//    /// This function will retrieve all sub-options of given option or root options of given category
//    /// - Parameters:
//    ///   - targetUUID:
//    ///   - state: option or category
//    /// - Returns:
//    func getAllOption(of targetUUID: UUID?, at state: PickItemState) -> [Option] {
//        if let uuid = targetUUID {
//            switch state {
//            case .enterCategory:
//                // get all options which do not have parent and under this category
//                let category = Helper.shared.fetchCategory(predicate: NSPredicate(format: "uuid == %@", uuid as CVarArg))[0]
//                return Helper.shared.fetchOption(predicate: NSPredicate(format: "category == %@ AND parent == nil", category))
//            default:
//                let option = Helper.shared.fetchOption(predicate: NSPredicate(format: "uuid == %@", uuid as CVarArg))
//                return option[0].children?.allObjects as! [Option]
//            }
//        }else {
//            return []
//        }
//    }
//}

// MARK: Helper Functions
extension OrderingVCViewModel {
    /// 
    /// - Parameter tableNumber:
    /// - Returns:
    func addNewOrder(at tableNumber: String) -> Order {
        let currentOrder = Order(context: PersistenceService.shared.persistentContainer.viewContext)
        
        currentOrder.uuid = UUID()
        currentOrder.establishedDate = Date()
        currentOrder.currentState = Int16(OrderState.eating.rawValue)
        currentOrder.isTakeOut = false
        currentOrder.number = tableNumber
        currentOrder.type = Int16(OrderType.eatIn.rawValue)
        currentOrder.totalSum = 0.0
        saveAll()
        
        return currentOrder
    }

    func clearCurrentOrderedItems() {
        currentOrderedItems = []
    }
    
    func saveAll() {
        PersistenceService.shared.saveContext()
    }
}
