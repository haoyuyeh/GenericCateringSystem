//
//  Device+CoreDataProperties.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/11/3.
//
//

import Foundation
import CoreData


extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device")
    }
    // possibly useless
    @NSManaged public var isOccupied: Bool
    /**
     full : eat in and take out
     takeOut : take out only
     */
    @NSManaged public var mode: String?
    @NSManaged public var name: String?
    /// for customer device, represent the table number
    @NSManaged public var number: String?
    @NSManaged public var password: String?
    /// for customer device, represent how many person the table can serve
    @NSManaged public var person: Int16
    /// host or customers
    @NSManaged public var roll: String?
    @NSManaged public var uuid: UUID?

}

extension Device : Identifiable {

}
