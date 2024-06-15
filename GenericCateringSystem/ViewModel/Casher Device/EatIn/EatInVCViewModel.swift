//
//  EatInVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/7.
//

import OSLog

class EatInVCViewModel {
    // MARK: Properties
    private let logger = Logger(subsystem: "EatIn", category: "EatInVCViewModel")
}

extension EatInVCViewModel {
    func getAllTable() -> [Device] {
        return Helper.shared.fetchDevice(predicate: NSPredicate(format: "roll == %@", Roll.customer.rawValue))
    }
    
    func hasOngoingOrder(of table: Device?) -> (result: Bool, order: Order?) {
        let device = Helper.shared.fetchDevice(predicate: NSPredicate(format: "uuid == %@", table!.uuid! as CVarArg))
        let p1 = NSPredicate(format: "number == %@ AND currentState == %d", device[0].number ?? "nil", OrderState.eating.rawValue)
        let order = Helper.shared.fetchOrder(predicate: p1)
        logger.debug("device: \(device)")
        logger.debug("order: \(order)")
        if order.count > 0 {
            return (true, order[0])
        }else {
            return (false, nil)
        }
    }
}
