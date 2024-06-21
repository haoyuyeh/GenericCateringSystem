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
        saveAll()
    }
    
    func checkOut(order: Order) {
        order.currentState = Int16(OrderState.paid.rawValue)
        saveAll()
    }
    
    func updateNotes(of order: Order, to notes: String) {
        order.comments = notes
        saveAll()
    }
    
    private func updateTotalSum(of order: Order) -> Double {
        var sum = 0.0
        for item in currentOrderedItems {
            sum += item.price * Double(item.quantity)
        }
        // update to core data
        order.totalSum = sum
        
        return sum
    }
}

// MARK: Ordered Item TableView
extension TableOrderDetailVCViewModel {
    func getAllItems(of order: Order) -> [Item] {
        if let items = order.items {
            currentOrderedItems = items.allObjects as! [Item]
            currentOrderedItems = currentOrderedItems.sorted { $0.name! <= $1.name! }
        }else {
            currentOrderedItems = []
        }
        
        return currentOrderedItems
    }
    
    /// 1. delete item at index position and coredata from order
    /// 2. update total sum of the order
    /// - Parameter index:
    func deleteItem(at index: Int) {
        let deletedItem = currentOrderedItems.remove(at: index)
        let order = deletedItem.orderedBy
        PersistenceService.shared.delete(object: deletedItem)
        delegate?.totalSumChanged(to: updateTotalSum(of: order!))
        saveAll()
    }
    
    /// 1. change the quantity of item at itemIndex position to newQuantity
    /// 2. update total sum of the order
    /// - Parameters:
    ///   - itemIndex:
    ///   - newQuantity:
    func changeQuantity(of itemIndex: Int, to newQuantity: Int) {
        let order = currentOrderedItems[itemIndex].orderedBy

        currentOrderedItems[itemIndex].quantity = Int16(newQuantity)
        delegate?.totalSumChanged(to: updateTotalSum(of: order!))
        saveAll()
    }
    
    func saveAll() {
        PersistenceService.shared.saveContext()
    }
}
