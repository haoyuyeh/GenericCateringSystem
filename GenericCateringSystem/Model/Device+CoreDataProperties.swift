//
//  Device+CoreDataProperties.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/10/21.
//
//

import Foundation
import CoreData


extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device")
    }

    @NSManaged public var iDFV: String
    @NSManaged public var isOccupied: Bool
    @NSManaged public var mode: Int16
    @NSManaged public var name: String
    @NSManaged public var number: String?
    @NSManaged public var password: String
    @NSManaged public var person: Int16
    @NSManaged public var roll: Int16
    @NSManaged public var uuid: UUID

}

extension Device : Identifiable {

}
