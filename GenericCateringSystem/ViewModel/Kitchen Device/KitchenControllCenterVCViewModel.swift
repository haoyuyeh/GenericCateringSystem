//
//  KitchenControllCenterVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/6/23.
//

import OSLog
import CoreData

class KitchenControllCenterVCViewModel {
    // MARK: Properties
    private let logger = Logger(subsystem: "Kitchen", category: "KitchenControllCenterVCViewModel")
    
    private var targets: [AnyHashable] = []
}

extension KitchenControllCenterVCViewModel {
    func getAllOrders() -> [AnyHashable] {
        let startDate = Date().startOfDay
        let p1 = NSPredicate(format: "establishedDate >= %@", startDate as CVarArg)
        let p2 = NSPredicate(format: "currentState == %i || currentState == %i", argumentArray: [Int16(OrderState.eating.rawValue), Int16(OrderState.preparing.rawValue)])
        let p = NSCompoundPredicate(type: .and, subpredicates: [p1, p2])
        let orders = Helper.shared.fetchOrder(predicate: p)
    }
}
