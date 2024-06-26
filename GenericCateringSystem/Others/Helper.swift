//
//  Helper.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/4/25.
//

import OSLog
import CoreData

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
}

