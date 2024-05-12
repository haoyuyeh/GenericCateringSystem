//
//  Helper.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/4/25.
//

import OSLog
import CoreData
import UIKit

class Helper {
    // MARK: Properties
    private let logger = Logger(subsystem: "GenericCateringSystem", category: "Helper")
    
    static let shared = Helper()
}

// MARK: Core Data
extension Helper {
    func fetchDevice(predicate: NSPredicate) -> [Device] {
        let fetchRequest: NSFetchRequest<Device> = Device.fetchRequest()
        fetchRequest.predicate = predicate
        do {
            let results = try PersistenceService.shared.persistentContainer.viewContext.fetch(fetchRequest)
            return results.sorted { $0.name! < $1.name! }
        } catch  {
            logger.error("fetch Device failed")
            return []
        }
    }
    
    func fetchOrder(predicate: NSPredicate) -> [Order] {
        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        fetchRequest.predicate = predicate
        do {
            let results = try PersistenceService.shared.persistentContainer.viewContext.fetch(fetchRequest)
            return results.sorted { $0.establishedDate! < $1.establishedDate! }
        } catch  {
            logger.error("fetch Order failed")
            return []
        }
    }
    
    func fetchCategory(predicate: NSPredicate) -> [Category] {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = predicate
        do {
            let results = try PersistenceService.shared.persistentContainer.viewContext.fetch(fetchRequest)
            return results.sorted { $0.name! < $1.name! }
        } catch  {
            logger.error("fetch Category failed")
            return []
        }
    }
    
    func fetchOption(predicate: NSPredicate) -> [Option] {
        let fetchRequest: NSFetchRequest<Option> = Option.fetchRequest()
        fetchRequest.predicate = predicate
        do {
            let results = try PersistenceService.shared.persistentContainer.viewContext.fetch(fetchRequest)
            return results.sorted { $0.name! < $1.name! }
        } catch  {
            logger.error("fetch Option failed")
            return []
        }
    }
}

// MARK: User Input Restraint
extension Helper {
    /// make sure the input will be digits only
    /// - Parameter input:
    /// - Returns: default value is "0"
    func digisGuarantee(input: String) -> String {
        if input.isMatch(pattern: "^[\\d]+$") {
           return input
        }else {
            return "0"
        }
    }
    
    /// checking if the name were existed in the database
    ///
    /// - Parameter id: log in ID
    /// - Returns: if exist, return true
    func isIDExist(checking id: String) -> Bool {
        let predicate = NSPredicate(format: "name == %@", id)
        
        if Helper.shared.fetchDevice(predicate: predicate) == [] {
            return false
        }else {
            return true
        }
    }
}

// MARK: Properties
extension Helper {
    func activityIndicator(style: UIActivityIndicatorView.Style, center: CGPoint? = nil) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: style)
        
        if let center = center {
            activityIndicator.center = center
        }
        
        return activityIndicator
    }
}
