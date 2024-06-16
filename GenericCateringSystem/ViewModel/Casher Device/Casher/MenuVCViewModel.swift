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
    var delegate: TotalSumDelegate?
}

// MARK: Order Details
extension MenuVCViewModel {
    
    /// determine the order number for the current walk-in order
    /// - Returns: order number
    func getWalkInOrderNumber() -> String {
        let predicate1 = NSPredicate(format: "type == %i", OrderType.walkIn.rawValue)
        let predicate2 = NSPredicate(format: "establishedDate >= %@", Calendar.current.startOfDay(for: Date()) as CVarArg)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        let walkInOrders = Helper.shared.fetchOrder(predicate: predicate)
        return String(walkInOrders.count + 1)
    }
}

// MARK: Ordered Item TableView
extension MenuVCViewModel {
    func getAllItems(of order: Order?) -> [Item] {
        if let order = order {
            var items = order.items?.allObjects as! [Item]
            
            items = items.sorted{
                $0.name! < $1.name!
            }
            
            return items
        }else {
            return []
        }
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
        delegate?.totalSumChanged(to: Helper.shared.updateTotalSum(currentOrderedItems: currentOrderedItems))
        saveAll()
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
        delegate?.totalSumChanged(to: Helper.shared.updateTotalSum(currentOrderedItems: currentOrderedItems))
        saveAll()
    }
    
    /// 1. change the quantity of item at itemIndex position to newQuantity
    /// 2. update total sum of the order
    /// - Parameters:
    ///   - itemIndex:
    ///   - newQuantity:
    func changeQuantity(of itemIndex: Int, to newQuantity: Int) {
        currentOrderedItems[itemIndex].quantity = Int16(newQuantity)
        delegate?.totalSumChanged(to: Helper.shared.updateTotalSum(currentOrderedItems: currentOrderedItems))
        saveAll()
    }
}

// MARK: Check Out
extension MenuVCViewModel {
    /// change the state of order to preparing and save the details of order
    /// - Parameters:
    ///   - order:
    ///   - t: order type
    ///   - pName:
    ///   - num:
    ///   - note:
    func completOrder(currentOrder order: Order, platformName pName: String, number num: String, comments note: String) {
        order.currentState = Int16(OrderState.preparing.rawValue)
        order.platformName = pName
        order.number = num
        order.comments = note
        logger.debug("complete order:\(order)\n")

        saveAll()
    }
}

// MARK: Catagories
extension MenuVCViewModel {
    func getAllCategory() -> [Category] {
        // fetch all data
        return Helper.shared.fetchCategory(predicate: NSPredicate(value: true))
    }
}

// MARK: Helper Functions
extension MenuVCViewModel {
    func addNewOrder(type: OrderType) -> Order {
        let currentOrder = Order(context: PersistenceService.shared.persistentContainer.viewContext)
        currentOrder.uuid = UUID()
        currentOrder.establishedDate = Date()
        currentOrder.currentState = Int16(OrderState.ordering.rawValue)
        currentOrder.isTakeOut = true
        currentOrder.type = Int16(type.rawValue)
        currentOrder.totalSum = 0.0
        saveAll()
        logger.debug("add order:\(currentOrder)\n")
        return currentOrder
    }
    
    /// calling this method means changing state or leaving vc.
    /// if there is any order having currentState as ordering, indicating the order is unfinished.
    /// then delete all of them from core data.
    func discardAll() {
        currentOrderedItems = []
        var orders = Helper.shared.fetchOrder(predicate: NSPredicate(format: "currentState == %i", OrderState.ordering.rawValue))
        while !orders.isEmpty {
            PersistenceService.shared.delete(object: orders.removeFirst())
        }
        saveAll()
    }
    
    func saveAll() {
        PersistenceService.shared.saveContext()
    }
}
