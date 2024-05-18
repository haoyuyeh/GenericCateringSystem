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
}

extension DisplayWalkInVCViewModel {
    func getCurrentWalkInOrderItems() -> [Item] {
        let start = Date().startOfDay
        let end = Date().endOfDay
        let p1 = NSPredicate(format: "establishedDate >= %@ && establishedDate <= %@", argumentArray: [start, end])
        let p2 = NSPredicate(format: "type == %d && currentState == %d", argumentArray: [OrderType.walkIn.rawValue, OrderState.ordering.rawValue])
        let comP = NSCompoundPredicate(type: .and, subpredicates: [p1, p2])
        let orders = Helper.shared.fetchOrder(predicate: comP)
        
        logger.debug("orders' count:\(orders.count)\n\(orders)")
        if orders.isEmpty {
            return []
        }else {
            return orders[0].items?.allObjects as! [Item]
        }
    }
}
