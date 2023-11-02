//
//  Option+CoreDataProperties.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/10/21.
//
//

import Foundation
import CoreData


extension Option {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Option> {
        return NSFetchRequest<Option>(entityName: "Option")
    }

    @NSManaged public var name: String
    @NSManaged public var price: Double
    @NSManaged public var uuid: UUID
    @NSManaged public var category: Category
    @NSManaged public var ownedBy: Option?
    @NSManaged public var subOptions: NSSet?

}

// MARK: Generated accessors for subOptions
extension Option {

    @objc(addSubOptionsObject:)
    @NSManaged public func addToSubOptions(_ value: Option)

    @objc(removeSubOptionsObject:)
    @NSManaged public func removeFromSubOptions(_ value: Option)

    @objc(addSubOptions:)
    @NSManaged public func addToSubOptions(_ values: NSSet)

    @objc(removeSubOptions:)
    @NSManaged public func removeFromSubOptions(_ values: NSSet)

}

extension Option : Identifiable {

}
