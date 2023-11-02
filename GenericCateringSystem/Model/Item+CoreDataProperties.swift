//
//  Item+CoreDataProperties.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/10/21.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var name: String
    @NSManaged public var price: Double
    @NSManaged public var quantity: Int16
    @NSManaged public var uuid: UUID
    @NSManaged public var orderedBy: Order

}

extension Item : Identifiable {

}