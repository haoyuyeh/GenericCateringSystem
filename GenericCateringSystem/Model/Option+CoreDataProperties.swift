//
//  Option+CoreDataProperties.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/6/23.
//
//

import Foundation
import CoreData


extension Option {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Option> {
        return NSFetchRequest<Option>(entityName: "Option")
    }

    @NSManaged public var name: String?
    /// it's unit price of this option
    @NSManaged public var price: Double
    @NSManaged public var uuid: UUID?
    @NSManaged public var category: Category?
    @NSManaged public var children: NSSet?
    @NSManaged public var parent: Option?
    /// if the options don't have parent, meaning they are main items
    /// therefore, they will be assign to a device to make it
    @NSManaged public var madeBy: Device?

}

// MARK: Generated accessors for children
extension Option {

    @objc(addChildrenObject:)
    @NSManaged public func addToChildren(_ value: Option)

    @objc(removeChildrenObject:)
    @NSManaged public func removeFromChildren(_ value: Option)

    @objc(addChildren:)
    @NSManaged public func addToChildren(_ values: NSSet)

    @objc(removeChildren:)
    @NSManaged public func removeFromChildren(_ values: NSSet)

}

extension Option : Identifiable {

}
