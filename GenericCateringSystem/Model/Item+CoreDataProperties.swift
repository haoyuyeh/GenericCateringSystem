//
//  Item+CoreDataProperties.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/6/23.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var name: String?
    /**
     the unit price of this item
     unit price = sum( all connected options' unit price )
     */
    @NSManaged public var price: Double
    @NSManaged public var quantity: Int16
    
    @NSManaged public var uuid: UUID?
    @NSManaged public var establisedDate: Date?
    /// indicate how many portions are served at chef side
    @NSManaged public var chefServed: Int16
    /// indicate if all portions of this item being made at chef side
    @NSManaged public var chefComplete: Bool
    /// indicate how many portions are served at kitchen distribute side
    @NSManaged public var distributeServed: Int16
    /// indicate if all portions of this item being distributed at kitchen distribute side
    @NSManaged public var distributeComplete: Bool
    /// indicate how many portions are served at table side
    @NSManaged public var tableServed: Int16
    /// indicate if all portions of this item being served at table side
    @NSManaged public var tableComplete: Bool
    @NSManaged public var orderedBy: Order?

}

extension Item : Identifiable {

}
