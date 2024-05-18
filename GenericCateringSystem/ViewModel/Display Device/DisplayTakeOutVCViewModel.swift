//
//  DisplayTakeOutVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/18.
//

import OSLog

class DisplayTakeOutVCViewModel {
    // MARK: Properties
    private let logger = Logger(subsystem: "Display", category: "DisplayTakeOutVCViewModel")
}

extension DisplayTakeOutVCViewModel {
    func getOrders( of type: OrderType, at state: OrderState) -> [Order] {
        let start = Date().startOfDay
        let end = Date().endOfDay
        let p1 = NSPredicate(format: "establishedDate >= %@ && establishedDate <= %@", argumentArray: [start, end])
        let p2 = NSPredicate(format: "type == %d && currentState == %d", argumentArray: [type.rawValue, state.rawValue])
        let comP = NSCompoundPredicate(type: .and, subpredicates: [p1, p2])
        
        
        return Helper.shared.fetchOrder(predicate: comP)
    }
}
