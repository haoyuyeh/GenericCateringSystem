//
//  HistoricalOrderVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/9.
//

import OSLog

class HistoricalOrderVCViewModel {
    // MARK: Properties
    private let logger = Logger(subsystem: "HistoricalOrders", category: "HistoricalOrderVCViewModel")
}

extension HistoricalOrderVCViewModel {
    func getAllHistoricalOrders(on date: Date, for type: OrderType) -> [Order] {
        let startDate = Calendar.current.startOfDay(for: date)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        
        let p0 = NSPredicate(format: "establishedDate >= %@ && establishedDate < %@", argumentArray: [startDate, endDate])
        let p1 = NSPredicate(format: "type == %d", type.rawValue)
        let p2 = NSPredicate(format: "currentState == %d || currentState == %d", argumentArray: [OrderState.paid, OrderState.orderDelivered])
        let p = NSCompoundPredicate(type: .and, subpredicates: [p0, p1, p2])
        
        return Helper.shared.fetchOrder(predicate: p)
    }
}
