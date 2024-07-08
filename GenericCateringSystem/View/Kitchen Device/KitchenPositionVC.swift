//
//  KitchenPositionVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/6/23.
//
import OSLog
import UIKit

class KitchenPositionVC: UIViewController {
    // MARK: Properties
    private let logger = Logger(subsystem: "Kitchen", category: "KitchenPositionVC")
    
    private var viewModel = KitchenPositionVCViewModel()
    var currentDevice: Device?

}
