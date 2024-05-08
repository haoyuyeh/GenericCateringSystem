//
//  Order+CoreDataProperties.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/4/24.
//
//

import Foundation
import CoreData


extension Order {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order")
    }

    @NSManaged public var comments: String?
    
    /// possible state: ordering, preparing, etc
    @NSManaged public var currentState: Int16
    @NSManaged public var establishedDate: Date?
    // possibly useless
    @NSManaged public var isTakeOut: Bool
    /// order number: eat in order will use table number as order number
    @NSManaged public var number: String?
    @NSManaged public var totalSum: Double
    /**
     Eat-In = 0
     Walk-In = 1
     Delivery Platform = 2
     */
    @NSManaged public var type: Int16
    @NSManaged public var uuid: UUID?
    /// delivery platform's name
    @NSManaged public var platformName: String?
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for items
extension Order {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

extension Order : Identifiable {

}
