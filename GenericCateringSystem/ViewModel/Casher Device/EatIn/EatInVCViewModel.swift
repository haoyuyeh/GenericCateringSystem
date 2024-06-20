//
//  EatInVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/7.
//

import OSLog
import CoreData

class EatInVCViewModel {
    // MARK: Properties
    private let logger = Logger(subsystem: "EatIn", category: "EatInVCViewModel")
}

extension EatInVCViewModel {
    func getAllTable() -> [Device] {
        return Helper.shared.fetchDevice(predicate: NSPredicate(format: "roll == %@", Roll.customer.rawValue))
    }
    
    /// create a new order for eat-in
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
    
    func saveAll() {
        PersistenceService.shared.saveContext()
    }
}
