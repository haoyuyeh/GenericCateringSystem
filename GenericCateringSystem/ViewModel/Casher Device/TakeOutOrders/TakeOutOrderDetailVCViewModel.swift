//
//  TakeOutOrderDetailVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/8.
//

import OSLog

class TakeOutOrderDetailVCViewModel {
    // MARK: Properties
    private let logger = Logger(subsystem: "TakeOut", category: "TakeOutOrderDetailVCViewModel")
}

// MARK: Helper
extension TakeOutOrderDetailVCViewModel {
    func getAllItems(of order: Order) -> [Item] {
        return order.items?.allObjects as! [Item]
    }
}
