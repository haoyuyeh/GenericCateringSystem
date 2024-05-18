//
//  PersistenceService.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/10/21.
//
import OSLog
import CoreData

class PersistenceService {
    // MARK: Properties
    private let logger = Logger(subsystem: "Others", category: "PersistenceService")
    // singleton
    static let shared = PersistenceService()
    
    // MARK: - Core Data stack

    var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "GenericCateringSystem") // same as project name
        
        // turn on persistent history tracking
        let description = container.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    // MARK: - Core Data Saving support

    func saveContext() {
        if PersistenceService.shared.persistentContainer.viewContext.hasChanges {
            do {
                try PersistenceService.shared.persistentContainer.viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                logger.error("save failed: \(nserror)")
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    /// discard all unsaved changes
    func resetContext() {
        PersistenceService.shared.persistentContainer.viewContext.rollback()
    }
    
    func delete(object: NSManagedObject) {
        PersistenceService.shared.persistentContainer.viewContext.delete(object)
    }
}
