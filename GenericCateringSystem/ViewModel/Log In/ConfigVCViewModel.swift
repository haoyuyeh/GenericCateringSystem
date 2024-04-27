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
        let results: [Device] = Helper.shared.fetchDevice(predicate: predicate)
        
        if results != [] {
            return true
        }else {
            return false
        }
    }
}

