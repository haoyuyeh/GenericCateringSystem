//
//  ConfigVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/11/3.
//

import CoreData

class ConfigVCViewModel {
    
}

// MARK: Helpler Function
extension ConfigVCViewModel {
    func hasRoll(as predicate: NSPredicate) -> Bool {
        let fetchRequest: NSFetchRequest<Device> = Device.fetchRequest()
        fetchRequest.predicate = predicate
        var results: [Device] = []
        do {
            results = try PersistenceService.managedContext.fetch(fetchRequest)
            
        } catch  {
            print("fetch Device failed")
        }
        
        if results != [] {
            return true
        }else {
            return false
        }
    }
}

