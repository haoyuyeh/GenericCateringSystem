//
//  OrderDetailVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/6/16.
//

import OSLog
import CoreData

class OrderDetailVCViewModel {
    // MARK: Properties
    private let logger = Logger(subsystem: "Customer", category: "OrderDetailVCViewModel")
    
}

// MARK: Item Table View
extension OrderDetailVCViewModel {
    func getAllItems(currentOrder: Order?) -> [Item] {
        guard let currentOrder = currentOrder else {
            return []
        }
        return currentOrder.items?.allObjects as! [Item]
    }
    
    func saveAll() {
        PersistenceService.shared.saveContext()
    }
}
