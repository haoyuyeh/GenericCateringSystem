//
//  Item+CoreDataProperties.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/6/16.
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
     unit price = sum( all options' unit price )
     */
    @NSManaged public var price: Double
    @NSManaged public var quantity: Int16
    @NSManaged public var uuid: UUID?
    /// indicate how many portions are served
    @NSManaged public var served: Int16
    @NSManaged public var orderedBy: Order?

}

extension Item : Identifiable {

}
