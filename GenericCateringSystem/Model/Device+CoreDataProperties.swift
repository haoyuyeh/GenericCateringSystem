//
//  Device+CoreDataProperties.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/6/25.
//
//

import Foundation
import CoreData


extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device")
    }
    /// for customer devices to indicate whether the table is serving customers
    @NSManaged public var isOccupied: Bool
    @NSManaged public var name: String?
    /// for customer device, represent the table number
    @NSManaged public var number: String?
    @NSManaged public var password: String?
    /// for customer device, represent how many person the table can serve
    @NSManaged public var person: Int16
    /// cashier, customers, display, kitchen, etc
    @NSManaged public var roll: String?
    @NSManaged public var uuid: UUID?
    /// for kitchen device, it the roll of device is chef, it will contain all the items making by this device
    @NSManaged public var makeItems: NSSet?

}

// MARK: Generated accessors for makeItems
extension Device {

    @objc(addMakeItemsObject:)
    @NSManaged public func addToMakeItems(_ value: Option)

    @objc(removeMakeItemsObject:)
    @NSManaged public func removeFromMakeItems(_ value: Option)

    @objc(addMakeItems:)
    @NSManaged public func addToMakeItems(_ values: NSSet)

    @objc(removeMakeItems:)
    @NSManaged public func removeFromMakeItems(_ values: NSSet)

}

extension Device : Identifiable {

}
