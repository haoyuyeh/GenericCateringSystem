//
//  MenuVCViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/11/5.
//

import CoreData

class MenuVCViewModel {
    private var currentOrderedItems: [Item] = []
    
}

// MARK: Order Details
extension MenuVCViewModel {
    
}

// MARK: Ordered Item TableView
extension MenuVCViewModel {
    /// get counts of current ordered items
    /// - Returns: Int
    func getCurrentOrderedItemCounts() -> Int {
        return currentOrderedItems.count
    }
    
    /// get name of item at index position from current order
    /// - Parameter index:
    /// - Returns: item name
    func getItemName(at index: Int) -> String {
        return currentOrderedItems[index].name ?? "nil"
    }
    
    /// get quantiy of item at index position from current order
    /// - Parameter index:
    /// - Returns: quantity of item
    func getItemQuantity(at index: Int) -> Int {
        return Int(currentOrderedItems[index].quantity)
    }
    
    /// check whether the new item exists in the order,
    /// if exists, add new quantity to existed one
    /// if not, add new item into order and sort the order
    /// - Parameter newItem:
    func addNewItem(newItem: Item) {
        let isExisted = isItemExisted(newItem: newItem)
        if isExisted.result {
            currentOrderedItems[isExisted.itemIndex!].quantity += newItem.quantity
        }else {
            currentOrderedItems.append(newItem)
            currentOrderedItems = currentOrderedItems.sorted{
                $0.name! < $1.name!
            }
        }
    }
    /// check whether the new item exists in the order,
    /// return result and index of item if there is any
    /// - Parameter newItem:
    /// - Returns: (Bool, Int?) if item existed, return the index of item
    func isItemExisted(newItem: Item) -> (result: Bool, itemIndex: Int?) {
        // check whether the new item exists in the order,
        if let existedItemIndex = currentOrderedItems.firstIndex(where: { item in
            item.name == newItem.name
        }){
            // if exists, return result and item index
            return (true, existedItemIndex)
        } else{
            return (false, nil)
        }
    }
    
    /// delete item at index position from order
    /// - Parameter index:
    func deleteItem(at index: Int) {
        currentOrderedItems.remove(at: index)
    }
    
    /// change the quantity of item at itemIndex position to newQuantity
    /// - Parameters:
    ///   - itemIndex:
    ///   - newQuantity:
    func changeQuantity(of itemIndex: Int, to newQuantity: Int) {
        currentOrderedItems[itemIndex].quantity = Int16(newQuantity)
    }
}

// MARK: Check Out
extension MenuVCViewModel {
    
}

// MARK: Catagories
extension MenuVCViewModel {
    
}

// MARK: Options
extension MenuVCViewModel {
    
}
