//
//  Enums.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/7.
//

// MARK: Cell Section
enum AccountSection {
    case all
}

enum ItemSection {
    case all
}

enum CategorySection {
    case all
}

enum OptionSection {
    case all
}

enum TableSection {
    case all
}

enum OrdersSection {
    case eatIn
    case walkIn
    case deliveryPlatform
}

// MARK: LogInVC
enum LogInState: String {
    case emptyName
    case emptyPassword
    case wrongPassword
    case success
}

// MARK: ConfigVC
enum Mode:String {
    case full
    case takeOut
}

/// only one device can be cashier, the rest are all client
enum Roll:String {
    case cashier
    case client
}

// MARK: MenuVC
enum OrderType: Int {
    case eatIn
    case walkIn
    case deliveryPlatform
}

enum OrderState: Int {
    // for eat in orders
    case eating
    case paid
    // for take out orders
    case ordering
    case preparing
    case waitingPickUp
    case orderDelivered
    
    case orderNotFinished
}

enum PickItemState {
    case enterCategory
    case enterOption
    case endOfChoic
}

// MARK: MenuEditVC
enum DeleteObjectType {
    case category
    case option
}

