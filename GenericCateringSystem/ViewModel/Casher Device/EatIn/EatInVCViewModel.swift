//
//  EatInVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/7.
//

import OSLog

class EatInVCViewModel {
    // MARK: Properties
    private let logger = Logger(subsystem: "Casher", category: "EatInVCViewModel")
}

extension EatInVCViewModel {
    func getAllTable() -> [Device] {
        return Helper.shared.fetchDevice(predicate: NSPredicate(format: "roll == %@", Roll.client.rawValue))
    }
    
    func hasOngoingOrder(of table: UUID?) -> (result: Bool, order: Order?) {
        let device = Helper.shared.fetchDevice(predicate: NSPredicate(format: "uuid == %@", table! as CVarArg))
        let p1 = NSPredicate(format: "number == %@ AND currentState == %d", device[0].number ?? "nil", OrderState.eating.rawValue)
        let order = Helper.shared.fetchOrder(predicate: p1)
        
        if order.count > 0 {
            return (true, order[0])
        }else {
            return (false, nil)
        }
    }
}
