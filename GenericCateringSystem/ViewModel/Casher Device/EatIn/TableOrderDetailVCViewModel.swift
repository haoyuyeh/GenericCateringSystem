//
//  TableOrderDetailVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/7.
//

import OSLog

class TableOrderDetailVCViewModel {
    // MARK: Properties
    private let logger = Logger(subsystem: "EatIn", category: "EatInVCViewModel")
    private var currentOrderedItems: [Item] = []
    var delegate: TotalSumDelegate?
}

// MARK: Helper
extension TableOrderDetailVCViewModel {
    func discount(for order: Order?, rate: Double) {
        order?.totalSum = (order?.totalSum ?? 0.0) * rate
    }
    
    func checkOut(order: Order) {
        order.currentState = Int16(OrderState.paid.rawValue)
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
}

// MARK: Ordered Item TableView
extension TableOrderDetailVCViewModel {
    func getAllItems(of order: Order) -> [Item] {
        currentOrderedItems = order.items?.allObjects as! [Item]
        
        return currentOrderedItems
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
