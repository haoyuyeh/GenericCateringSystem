//
//  Order+CoreDataProperties.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/11/3.
//
//

import Foundation
import CoreData


extension Order {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order")
    }

    @NSManaged public var comments: String?
    /**
     for take-out orders, such as preparing, waiting, or etc.
     */
    @NSManaged public var currentState: Int16
    @NSManaged public var establishedDate: Date?
    @NSManaged public var isTakeOut: Bool
    @NSManaged public var number: String?
    @NSManaged public var totalSum: Double
    /**
     type of take-out, such as walk-in, uber, etc.
     */
    @NSManaged public var type: Int16
    @NSManaged public var uuid: UUID?
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
