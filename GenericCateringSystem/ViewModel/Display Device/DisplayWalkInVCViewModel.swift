//
//  DisplayWalkInVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/18.
//

import OSLog

class DisplayWalkInVCViewModel {
    // MARK: Properties
    private let logger = Logger(subsystem: "Display", category: "DisplayWalkInVCViewModel")
    
    private var currentOrder: Order?
}

extension DisplayWalkInVCViewModel {
    func getCurrentWalkInOrderItems() -> [Item] {
        let start = Date().startOfDay
        let end = Date().endOfDay
        let p1 = NSPredicate(format: "establishedDate >= %@ && establishedDate <= %@", argumentArray: [start, end])
        let p2 = NSPredicate(format: "type == %d && currentState == %d", argumentArray: [OrderType.walkIn.rawValue, OrderState.ordering.rawValue])
        let comP = NSCompoundPredicate(type: .and, subpredicates: [p1, p2])
        let orders = Helper.shared.fetchOrder(predicate: comP)
        
        if orders.isEmpty {
            return []
        }else {
            currentOrder = orders[0]
            let items = currentOrder?.items?.allObjects as! [Item]
            logger.debug("\(self.currentOrder)\(items)")
            return items
        }
    }
    
    func updateTotalSum() -> Double {
        logger.debug("\(self.currentOrder)")
        guard currentOrder != nil else {
            return 0.0
        }
        return currentOrder!.totalSum
    }
}
