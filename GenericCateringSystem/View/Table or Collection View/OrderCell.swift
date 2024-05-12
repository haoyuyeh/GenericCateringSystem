//
//  OrderCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/8.
//
import OSLog
import CoreData
import UIKit

class OrderCell: UITableViewCell {
    // MARK: Properties
    private let logger = Logger(subsystem: "TakeOut", category: "OrderCell")

    /// cell's index path
    var indexPath: IndexPath?
    var order: Order?
    var delegate: OrderStatusChangedDelegate?
    
    // MARK: IBOutlet

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var number: UILabel!

    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var status: UILabel!
    
    @IBAction func statusBtnPressed(_ sender: UIButton) {
        switch Int(order!.currentState) {
        case OrderState.preparing.rawValue:
            sender.titleLabel?.text = "WaitingPickUp"
            sender.imageView?.image = UIImage(systemName: "box.truck.badge.clock")
            delegate?.statusChanged(to: .waitingPickUp, of: order!, at: indexPath!)
        case OrderState.waitingPickUp.rawValue:
            delegate?.statusChanged(to: .orderDelivered, of: order!, at: indexPath!)
            
        default:
            logger.error("order's status error. status = \(self.order!.currentState)")
        }
        
    }
    
}

// MARK: CellConfig
extension OrderCell: CellConfig {
    func configure<T>(with target: NSManagedObject, of cellType: T.Type) {
        order = (target as! Order)
        
        if cellType.self == TakeOutOrderVC.self {
            configTakeOutOrder(with: order!)
        }else if cellType.self == HistoricalOrderVC.self {
            configHistoricalOrder(with: order!)
        }else {
            logger.error("call from unknown view controller!!!")
        }
    }
    
    private func configTakeOutOrder(with target: Order) {
        switch Int(target.currentState) {
        case OrderState.preparing.rawValue:
            statusBtn.titleLabel?.text = "Preparing"
            statusBtn.imageView?.image = UIImage(systemName: "frying.pan")
        case OrderState.waitingPickUp.rawValue:
            statusBtn.titleLabel?.text = "WaitingPickUp"
            statusBtn.imageView?.image = UIImage(systemName: "box.truck.badge.clock")
            
        default:
            logger.error("wrong order current state")
        }
    
        switch Int(target.type) {
        case OrderType.walkIn.rawValue:
            name.text = "Walk-in"
            
        case OrderType.deliveryPlatform.rawValue:
            name.text = order!.platformName
            
        default:
            logger.error("error order type: \(self.order!.type)")
        }
        
        number.text = target.number
    }
    
    private func configHistoricalOrder(with target: Order) {
        
        switch Int(target.type) {
        case OrderType.eatIn.rawValue:
            name.text = "Eat-in"

        case OrderType.walkIn.rawValue:
            name.text = "Walk-in"
            
        case OrderType.deliveryPlatform.rawValue:
            name.text = order!.platformName
            
        default:
            logger.error("error order type: \(self.order!.type)")
        }
        
        number.text = target.number
        
        if Int(order!.currentState) == OrderState.orderNotFinished.rawValue {
            status.text = "Not Finished"
        }else {
            status.isHidden = true
        }
    }
}
