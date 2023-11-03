//
//  LogInVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/11/3.
//

import CoreData
import UIKit

class LogInVCViewModel {
    // MARK: Properties
    let iDFV = UIDevice.current.identifierForVendor?.uuidString
}
// MARK: Helper functions
extension LogInVCViewModel {
    
    /// fetching data of Device based on the predicate
    /// - Parameter predicate: critiria for filtering data
    /// - Returns: [Device]
    func fetchDevice(predicate: NSPredicate) -> [Device] {
        let fetchRequest: NSFetchRequest<Device> = Device.fetchRequest()
        fetchRequest.predicate = predicate
        do {
            let results = try PersistenceService.managedContext.fetch(fetchRequest)
            return results
        } catch  {
            print("fetch Device failed")
            return []
        }
    }
    
    /// checking if the name were existed in the database
    ///
    /// - Parameter id: log in ID
    /// - Returns: if exist, return true
    func isIDExist(checking id: String) -> Bool {
        let predicate = NSPredicate(format: "name == %@", id)
        
        if fetchDevice(predicate: predicate) == [] {
            return false
        }else {
            return true
        }
    }
    
    /// credential validation to decide whether it can be logged into the system
    /// - Parameters:
    ///   - id: log in ID
    ///   - pw: log in password
    /// - Returns: ( LogInState, Device? )
    func credentialValidate(ID id: String, PW pw:String) -> (state:LogInState, device: Device?) {
        let predicate = NSPredicate(format: "name == %@", id)
        let device = fetchDevice(predicate: predicate).first
        
        if device?.iDFV != self.iDFV {
            return (LogInState.wrongDevice, nil)
        }
        if device?.password != pw {
            return (LogInState.wrongPassword, nil)
        }
        return (LogInState.success, device)
    }
    
    /// add new device into database
    /// - Parameters:
    ///   - name: device name
    ///   - pw: password
    /// - Returns: Device
    func addNewDevice(deviceName name: String, PW pw: String) -> Device {
        let newDevice = Device(context: PersistenceService.managedContext)
        newDevice.uuid = UUID()
        newDevice.iDFV = self.iDFV!
        newDevice.name = name
        newDevice.password = pw
        PersistenceService.share.saveContext()
        
        return newDevice
    }
}
