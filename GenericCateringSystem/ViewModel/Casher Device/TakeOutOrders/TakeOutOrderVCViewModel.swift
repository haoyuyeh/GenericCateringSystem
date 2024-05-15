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
    func getAllTakeOutOrders(with type: OrderType) -> [Order] {
        let today = Date()
        let startDate = Calendar.current.startOfDay(for: today)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        
        let p0 = NSPredicate(format: "establishedDate >= %@ && establishedDate < %@", argumentArray: [startDate, endDate])
        let p1 = NSPredicate(format: "type == %d", type.rawValue)
        let p2 = NSPredicate(format: "currentState == %d || currentState == %d", argumentArray: [OrderState.preparing.rawValue, OrderState.waitingPickUp.rawValue])
        let comP = NSCompoundPredicate(type: .and, subpredicates: [p0, p1, p2])
        let orders = Helper.shared.fetchOrder(predicate: comP)

        switch type {
        case .walkIn:
            return orders.sorted{ $0.number! <= $1.number! }
            
        case .deliveryPlatform:
            return orders.sorted{ $0.platformName! <= $1.platformName! }
            
        default :
            return []
        }
    }
    
    func updateOrderState(to state: OrderState, of order: Order) {
        order.currentState = Int16(state.rawValue)
        PersistenceService.shared.saveContext()
    }
}
