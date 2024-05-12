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
    var delegate: ShowMsgDelegate?
    
    init() {
        fetchAccounts()
    }
}

// MARK: Helper Function
extension AccountVCViewModel {
    func fetchAccounts() {
        accounts = Helper.shared.fetchDevice(predicate: NSPredicate(value: true))
    }
    
    func getAllAccount() -> [Device] {
        return accounts
    }
    
    func deleteAccount(at index: Int) {
        PersistenceService.shared.delete(object: accounts[index])
        accounts.remove(at: index)
        PersistenceService.shared.saveContext()
    }
    
    func saveChanges() {
        PersistenceService.shared.saveContext()
    }
}

// MARK: AccountCellDelegate
extension AccountVCViewModel: AccountCellDelegate {
    func idTFTextChanged(to newName: String, at indexPath: IndexPath) {
        guard newName.isMatch(pattern: "^[\\w\\s-]+$") else {
            delegate?.show(msg: "name can't be all whitespace or nil!!")
            return
        }
        
        guard !Helper.shared.isIDExist(checking: newName) else {
            delegate?.show(msg: "Duplicate account name!!!")
            return
        }
        
        accounts[indexPath.row].name = newName
    }
    
    func pwTFTextChanged(to newPw: String, at indexPath: IndexPath) {
        accounts[indexPath.row].password = newPw
    }
}
