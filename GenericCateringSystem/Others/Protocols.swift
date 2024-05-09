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
    func configure(target: NSManagedObject)
}

// MARK: MenuEditVC
/// Tell the category cell how to display itself
protocol CategoryDeleteModeDelegate {
    func isEnterDeleteMode(value: Bool)
}
/// Tell the option cell how to display itself
protocol OptionDeleteModeDelegate {
    func isEnterDeleteMode(value: Bool)
}

// MARK: EatInVC
protocol TableStateChangedDelegate {
    func occupied(at table: UUID)
    func released(at table: UUID)
    func tableOccupied()
    func tableReleased()
}

// MARK: TableOrderDetailVC
protocol CheckOutDelegate {
    func orderCompleted(at table: UUID)
}

// MARK: OrderCell
protocol OrderStatusChangedDelegate {
    func statusChanged(to state: OrderState, of order: Order, at indexPath: IndexPath)
}

// MARK: ItemCell
protocol ItemQuantityDelegate {
    func itemQuantityChanged(to num: Int, of index: IndexPath)
}





// MARK: EatInVC




// MARK: EatInVC
