//
//  AccountVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/11/4.
//

import CoreData

class AccountVCViewModel {
    // MARK: Property
    var accounts: [Device] = []
    
    init() {
        fetchAccounts()
    }
}

// MARK: Helper Function
extension AccountVCViewModel {
    func fetchAccounts() {
        let fetchRequest: NSFetchRequest<Device> = Device.fetchRequest()
        do {
            let results = try PersistenceService.managedContext.fetch(fetchRequest)
            accounts = results
        } catch  {
            print("fetch Device failed at \(AccountVCViewModel.self)")
        }
    }
    
    func getAccountCount() -> Int {
        return accounts.count
    }
    
    func getAccount(at index: Int) -> Device {
        return accounts[index]
    }
    
    func deleteAccount(at index: Int) {
        PersistenceService.managedContext.delete(accounts[index])
        accounts.remove(at: index)
        PersistenceService.share.saveContext()
    }
    
    func saveChanges() {
        PersistenceService.share.saveContext()
    }
}

// MARK: AccountCellDelegate
extension AccountVCViewModel: AccountCellDelegate {
    func idTFTextChanged(to newName: String, at indexPath: IndexPath) {
        accounts[indexPath.row].name = newName
    }
    
    func pwTFTextChanged(to newPw: String, at indexPath: IndexPath) {
        accounts[indexPath.row].password = newPw
    }
}
