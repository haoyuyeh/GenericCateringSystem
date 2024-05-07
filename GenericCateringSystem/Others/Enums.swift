//
//  Enums.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/7.
//

// LogInVC
enum LogInState: String {
    case emptyName
    case emptyPassword
    case wrongPassword
    case success
}

//ConfigVC
enum Mode:String {
    case full
    case takeOut
}

/// only one device can be cashier, the rest are all client
enum Roll:String {
    case cashier
    case client
}

//MenuVC
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
}

enum PickItemState {
    case enterCategory
    case enterOption
    case endOfChoic
}

enum CategorySection {
    case all
}

enum OptionSection {
    case all
}

// MenuEditVC
enum DeleteObjectType {
    case category
    case option
}

// EatInVC
enum TableSection {
    case all
}
