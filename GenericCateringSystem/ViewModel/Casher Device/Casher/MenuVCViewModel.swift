//
//  MenuVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/11/5.
//

import OSLog
import CoreData

protocol TotalSumDelegate {
    func totalSumChanged(to sum: Double)
}

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
    
    /// get unit price of item at index position from current order
    /// - Parameter index:
    /// - Returns:
    func getItemUnitPrice(at index: Int) -> String {
        return "$\(String(currentOrderedItems[index].price))"
    }
    
    /// get quantiy of item at index position from current order
    /// - Parameter index:
    /// - Returns: quantity of item
    func getItemQuantity(at index: Int) -> String {
        return String(currentOrderedItems[index].quantity)
    }
    
    /// 1. check whether the new item exists in the order,
    /// if exists, add new quantity to existed one
    /// if not, add new item into order and sort the order
    /// 2. update the total sum of the order
    /// - Parameters:
    ///   - order:
    ///   - option:
    ///   - q:
    func addNewItem(currentOrder order: Order, selectedOption option: UUID) {
        let newItem = Item(context: PersistenceService.shared.persistentContainer.viewContext)
        newItem.uuid = UUID()
        newItem.orderedBy = order
        // use option to trace back the correct item name and price
        (newItem.name, newItem.price) = getNameAndUnitPrice(of: option)
        newItem.quantity = 1
        
        let isExisted = isItemExisted(newItem: newItem)
        if isExisted.result {
            currentOrderedItems[isExisted.itemIndex!].quantity += newItem.quantity
            PersistenceService.shared.delete(object: newItem)
        }else {
            currentOrderedItems.append(newItem)
            currentOrderedItems = currentOrderedItems.sorted{
                $0.name! < $1.name!
            }
        }
        
        delegate?.totalSumChanged(to: updateTotalSum())
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
            logger.debug("item is existed at \(existedItemIndex)")
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
        delegate?.totalSumChanged(to: updateTotalSum())
    }
    
    /// 1. change the quantity of item at itemIndex position to newQuantity
    /// 2. update total sum of the order
    /// - Parameters:
    ///   - itemIndex:
    ///   - newQuantity:
    func changeQuantity(of itemIndex: Int, to newQuantity: Int) {
        currentOrderedItems[itemIndex].quantity = Int16(newQuantity)
        delegate?.totalSumChanged(to: updateTotalSum())
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
    func completOrder(currentOrder order: Order, type t: Int, platformName pName: String, number num: String, comments note: String) {
        order.currentState = Int16(OrderState.preparing.rawValue)
        order.type = Int16(t)
        order.platformName = pName
        order.number = num
        order.comments = note
        
        PersistenceService.shared.saveContext()
    }
}

// MARK: Catagories
extension MenuVCViewModel {
    func getAllCategory() -> [Category] {
        // fetch all data
        return Helper.shared.fetchCategory(predicate: NSPredicate(value: true))
    }
}

// MARK: Options
extension MenuVCViewModel {
    func hasChildrenOption(of targetUUID: UUID?) -> Bool {
        if let uuid = targetUUID {
            let option = Helper.shared.fetchOption(predicate: NSPredicate(format: "uuid == %@", uuid as CVarArg))[0]
//            logger.debug("\(option)")
            let children = option.children?.allObjects as! [Option]
            if children.isEmpty {
                return false
            }else {
                return true
            }
        }else {
            /**
             return true will keep the state of pickItemState in enterOption,
             therefore, user can sense the error
             */
            logger.error("option uuid is nil")
            return true
        }
    }
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
                return Helper.shared.fetchOption(predicate: NSPredicate(format: "category == %@ AND parent == nil", category))
            default:
                let option = Helper.shared.fetchOption(predicate: NSPredicate(format: "uuid == %@", uuid as CVarArg))
                return option[0].children?.allObjects as! [Option]
            }
        }else {
            return []
        }
    }
    
    /// the data structure of option is link-list like
    /// therefore, use the targetUUID to retrieve the whole name and price of the picked item
    /// - Parameter targetUUID:
    /// - Returns:
    func getNameAndUnitPrice(of targetUUID: UUID?) -> (name:String, unitPrice:Double) {
        if let uuid = targetUUID {
            let options = Helper.shared.fetchOption(predicate: NSPredicate(format: "uuid == %@", uuid as CVarArg))
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
    
    func addNewOrder() -> Order {
        let currentOrder = Order(context: PersistenceService.shared.persistentContainer.viewContext)
        currentOrder.uuid = UUID()
        currentOrder.establishedDate = Date()
        currentOrder.currentState = Int16(OrderState.ordering.rawValue)
        currentOrder.isTakeOut = true
        
        return currentOrder
    }
}

// MARK: Helper Functions
extension MenuVCViewModel {
    func discardAll() {
        currentOrderedItems = []
        PersistenceService.shared.resetContext()
    }
    
    func saveAll() {
        PersistenceService.shared.saveContext()
    }
    
    private func updateTotalSum() -> Double {
        var sum = 0.0
        for item in currentOrderedItems {
            sum += item.price * Double(item.quantity)
        }
        // update to core data
        currentOrderedItems[0].orderedBy?.totalSum = sum
        
        return sum
    }
    
    /// use the end node to back track the whole name and price
    /// - Parameter option:
    /// - Returns:
    private func generateItemNameAndUnitPrice(of option: Option) -> (name:String, unitPrice:Double) {
        var nameReversed: [String] = []
        var item: Option? = option
        var totalPrice = 0.0
        
        repeat {
            nameReversed.append(item!.name ?? "nil")
            totalPrice += item!.price
            item = item!.parent
        }while item != nil
        
        nameReversed.reverse()
        
        var count = 0, name = ""
        
        while count < nameReversed.count {
            switch count {
            case 0:
                name = nameReversed[count] + " - "
            case 1...:
                name += nameReversed[count]
                name += ","
            default:
                break
            }
            count += 1
        }
        return (name, totalPrice)
    }
}
