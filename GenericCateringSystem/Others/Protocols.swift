//
//  Protocols.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/9.
//

import Foundation
import CoreData

// MARK: Common
protocol CellConfig {
    func configure<T>(with target: NSManagedObject, of cellType: T.Type)
}

protocol ShowMsgDelegate {
    func show(msg: String)
}

protocol TextFieldChangedDelegate {
    func noteChanged(to notes: String, of order: Order)
    func idChanged(to newName: String, at indexPath: IndexPath)
    func pwChanged(to newPw: String, at indexPath: IndexPath)
    func itemQuantityChanged(to num: Int, of index: IndexPath)
}

extension TextFieldChangedDelegate {
    func noteChanged(to notes: String, of order: Order) {}
    func idChanged(to newName: String, at indexPath: IndexPath) {}
    func pwChanged(to newPw: String, at indexPath: IndexPath) {}
    func itemQuantityChanged(to num: Int, of index: IndexPath) {}
}

// MARK: MenuEditVC
protocol DeleteModeDelegate {
    func isEnterDeleteMode(value: Bool)
}

// MARK: EatInVC
protocol EatInTableDelegate {
    func orderCompleted(at table: UUID)
    func occupied(at table: UUID)
    func released(at table: UUID)
    func tableOccupied()
    func tableReleased()
}
extension EatInTableDelegate {
    func orderCompleted(at table: UUID) {}
    func occupied(at table: UUID) {}
    func released(at table: UUID) {}
    func tableOccupied() {}
    func tableReleased() {}
}

// MARK: OrderCell
protocol OrderChangedDelegate {
    func statusChanged(to state: OrderState, of order: Order)
}





// MARK: EatInVC




// MARK: EatInVC
