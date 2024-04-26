//
//  Option+CoreDataProperties.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/4/26.
//
//

import Foundation
import CoreData


extension Option {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Option> {
        return NSFetchRequest<Option>(entityName: "Option")
    }

    @NSManaged public var name: String?
    @NSManaged public var price: Double
    @NSManaged public var uuid: UUID?
    @NSManaged public var category: Category?
    @NSManaged public var parent: Option?
    @NSManaged public var children: NSSet?

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
