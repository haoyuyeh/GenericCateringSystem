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
    private let logger = Logger(subsystem: "Table or Collection View", category: "OrderCell")

    var order: Order?
    var orderDelegate: OrderChangedDelegate?
    
    // MARK: IBOutlet

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var number: UILabel!
    
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var status: UILabel!
    
    // MARK: IBAction
    @IBAction func statusBtnPressed(_ sender: UIButton) {
        switch Int(order!.currentState) {
        case OrderState.preparing.rawValue:
            sender.titleLabel?.text = "WaitingPickUp"
            sender.imageView?.image = UIImage(systemName: "box.truck.badge.clock")
            orderDelegate?.statusChanged(to: .waitingPickUp, of: order!)
        case OrderState.waitingPickUp.rawValue:
            orderDelegate?.statusChanged(to: .orderDelivered, of: order!)
            
        default:
            logger.error("order's status error. status = \(self.order!.currentState)")
        }
    }
}

// MARK: CellConfig
extension OrderCell: CellConfig {
    func configure<T>(with target: NSManagedObject, of classType: T.Type) {
        order = (target as! Order)
        
        if classType.self == TakeOutOrderVC.self {
            configTakeOutOrder(with: order!)
        }else if classType.self == HistoricalOrderVC.self {
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
            statusBtn.imageView?.image = UIImage(systemName: "truck.box.badge.clock")
            
        default:
            logger.error("wrong order current state")
        }
    
        switch Int(target.type) {
        case OrderType.walkIn.rawValue:
            name.text = "Walk-in"
            
        case OrderType.deliveryPlatform.rawValue:
            name.text = target.platformName
            
        default:
            logger.error("error order type: \(target.type)")
        }
        
        number.text = target.number
    }
    
    private func configHistoricalOrder(with target: Order) {
        switch Int(target.type) {
        case OrderType.eatIn.rawValue:
            name.text = "Eat-in - Table #\(target.number ?? "nil")"
            
        case OrderType.walkIn.rawValue:
            name.text = "Walk-in #\(target.number ?? "nil")"
            
        case OrderType.deliveryPlatform.rawValue:
            name.text = "\(target.platformName ?? "nil") - \(target.number ?? "nil")"

        default:
            logger.error("error order type: \(target.type)")

        }
        number.text = target.establishedDate?.toString(format: nil, dateStyle: .omitted, timeStyle: .standard)
        
        
        
        
        let startOfToday = Calendar.current.startOfDay(for: Date())
        
        switch Int(target.currentState) {
        case OrderState.eating.rawValue, OrderState.ordering.rawValue, OrderState.preparing.rawValue, OrderState.waitingPickUp.rawValue:
            guard let date = target.establishedDate else {
                logger.error("\(target): establishedDate is nil")
                status.text = "Establied date not exist!"
                status.textColor = UIColor.systemBrown
                return
            }
            if  date  >= startOfToday {
                status.text = "Ongoing Orders"
                status.textColor = UIColor.systemYellow
            }else {
                target.currentState = Int16(OrderState.orderNotFinished.rawValue)
                PersistenceService.shared.saveContext()
                status.text = "Not Finished"
                status.textColor = UIColor.systemRed
            }
            
        case OrderState.orderNotFinished.rawValue:
            status.text = "Not Finished"
            status.textColor = UIColor.systemRed

        default:
            status.text = "Completed"
            status.textColor = UIColor.systemGreen
        }
    }
}
