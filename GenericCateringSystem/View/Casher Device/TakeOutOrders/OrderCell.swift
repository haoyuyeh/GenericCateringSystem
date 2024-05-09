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
    
    private var status: OrderState {
        didSet {
            switch status {
            case .preparing:
                statusBtn.titleLabel?.text = "Preparing"
                statusBtn.imageView?.image = UIImage(systemName: "frying.pan")
                delegate?.statusChanged(to: status, of: order!, at: indexPath!)
                
            case .waitingPickUp:
                statusBtn.titleLabel?.text = "WaitingPickUp"
                statusBtn.imageView?.image = UIImage(systemName: "box.truck.badge.clock")
                delegate?.statusChanged(to: status, of: order!, at: indexPath!)

            case .orderDelivered:
                delegate?.statusChanged(to: status, of: order!, at: indexPath!)
            default:
                logger.error("order's status error. status = \(self.status.rawValue)")
            }
        }
    }
    
    // MARK: IBOutlet

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var statusBtn: UIButton!
    
    // MARK: IBAction

    @IBAction func statusBtnPressed(_ sender: UIButton) {
        switch status {
        case .preparing:
            status = .waitingPickUp
        case .waitingPickUp:
            status = .orderDelivered
        default:
            logger.error("order's status error. status = \(self.status.rawValue)")
        }
    }
    
    required init?(coder: NSCoder) {
        status = OrderState.preparing
        super.init(coder: coder)
    }
}

// MARK: CellConfig
extension OrderCell: CellConfig {
    func configure(target: NSManagedObject) {
        let target = target as! Order
        
        order = target
        switch order!.type {
        case 1:
            name.text = "Walk-in"
        case 2:
            name.text = order!.platformName
        default:
            logger.error("error order type: \(self.order!.type)")
        }
        number.text = order!.number
    }
}
