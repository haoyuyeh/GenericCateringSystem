//
//  TakeOutOrderVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/8.
//

import OSLog

class TakeOutOrderVCViewModel {
    // MARK: Properties
    private let logger = Logger(subsystem: "TakeOut", category: "TakeOutOrderVCViewModel")
}

// MARK: Helper
extension TakeOutOrderVCViewModel {
    func getAllTakeOutOrders() -> [Order] {
        return Helper.shared.fetchOrder(predicate: NSPredicate(format: "type == 1 || type == 2"))
    }
    
    func updateOrderState(to state: OrderState, of order: Order) {
        order.currentState = Int16(state.rawValue)
        PersistenceService.shared.saveContext()
    }
}
