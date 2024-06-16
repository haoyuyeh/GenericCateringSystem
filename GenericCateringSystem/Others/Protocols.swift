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
    /// configure a cell which is resided in the view controller of classType with NSManagedObject
    /// - Parameters:
    ///   - target:
    ///   - classType:
    func configure<T>(with target: NSManagedObject, of classType: T.Type)
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
    func itemQuantityChanged(to num: Int, of index: IndexPath = IndexPath()) {}
}

// MARK: MenuEditVC
protocol DeleteModeDelegate {
    func isEnterDeleteMode(value: Bool)
}

protocol TotalSumDelegate {
    func totalSumChanged(to sum: Double)
}

// MARK: EatInVC
protocol EatInTableDelegate {
    func orderCompleted(at table: Device)
    func occupied(at table: Device)
    func released(at table: Device)
    func tableOccupied()
    func tableReleased()
}
extension EatInTableDelegate {
    func orderCompleted(at table: Device) {}
    func occupied(at table: Device) {}
    func released(at table: Device) {}
    func tableOccupied() {}
    func tableReleased() {}
}

// MARK: OrderCell
protocol OrderChangedDelegate {
    func statusChanged(to state: OrderState, of order: Order)
}


// MARK: CustomerOptionCell
protocol CustomerOptionCellDelegate {
    func addItem(of option: Option, quantity: Int)
}

// MARK: CustomerOptionCell
