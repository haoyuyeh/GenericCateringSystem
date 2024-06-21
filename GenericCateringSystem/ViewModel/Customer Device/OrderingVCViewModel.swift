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
    /// 1. check whether the new item exists in the order,
    /// if exists, add new quantity to existed one
    /// if not, add new item into order and sort the order
    /// 2. update the total sum of the order
    /// - Parameters:
    ///   - order:
    ///   - option:
    ///   - q:
    func addNewItem(currentOrder order: Order, selectedOption option: Option, quantity: Int) {
        let newItem = Item(context: PersistenceService.shared.persistentContainer.viewContext)
        newItem.uuid = UUID()
        // use option to trace back the correct item name and price
        (newItem.name, newItem.price) = Helper.shared.getNameAndUnitPrice(of: option)
        newItem.quantity = Int16(quantity)
        
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
        order.totalSum = Helper.shared.updateTotalSum(currentOrderedItems: currentOrderedItems)
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
}

// MARK: Catagories
extension OrderingVCViewModel {
    func getAllCategory() -> [Category] {
        // fetch all data
        return Helper.shared.fetchCategory(predicate: NSPredicate(value: true))
    }
}

// MARK: Helper Functions
extension OrderingVCViewModel {
    /// check if there is order in eating state under the tableNumber.
    /// - Returns: nil for no ongoing order
    func checkOngoingOrder(of table: Device) -> (result: Bool, order: Order?) {
        let outcome = Helper.shared.hasOngoingOrder(of: table)


        if outcome.result {
            if let items = outcome.order!.items {
                currentOrderedItems = items.allObjects as! [Item]
                currentOrderedItems = currentOrderedItems.sorted{
                    $0.name! < $1.name!
                }
            }else {
                currentOrderedItems = []
            }
            
        }
        return outcome
    }
    
    /// create a new one
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
