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
}
// MARK: Helper functions
extension LogInVCViewModel {
    
    /// credential validation to decide whether it can be logged into the system
    /// - Parameters:
    ///   - id: log in ID
    ///   - pw: log in password
    /// - Returns: ( LogInState, Device? )
    func credentialValidate(ID id: String, PW pw:String) -> (state:LogInState, device: Device?) {
        let predicate = NSPredicate(format: "name == %@", id)
        let device = Helper.shared.fetchDevice(predicate: predicate).first
        
        if device?.password != pw {
            return (LogInState.wrongPassword, nil)
        }else {
            return (LogInState.success, device)
        }
    }
    
    /// add new device into database
    /// - Parameters:
    ///   - name: device name
    ///   - pw: password
    /// - Returns: Device
    func addNewDevice(deviceName name: String, PW pw: String) -> Device {
        let newDevice = Device(context: PersistenceService.shared.persistentContainer.viewContext)
        newDevice.uuid = UUID()
        newDevice.name = name
        newDevice.password = pw
        PersistenceService.shared.saveContext()
        
        return newDevice
    }
}
