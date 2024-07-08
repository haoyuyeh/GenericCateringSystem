//
//  HistoricalOrderDetailVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/9.
//

import OSLog

class HistoricalOrderDetailVCViewModel {
    // MARK: Properties
    private let logger = Logger(subsystem: "HistoricalOrders", category: "HistoricalOrderDetailVCViewModel")
}

extension HistoricalOrderDetailVCViewModel {
    func getAllItems(of order: Order) -> [Item] {
        return order.items?.allObjects as! [Item]
    }
    
    func updateNotes(to notes: String, of order: Order) {
        order.comments = notes
        PersistenceService.shared.saveContext()
    }
}
