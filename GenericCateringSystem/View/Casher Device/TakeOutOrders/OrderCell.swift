//
//  OrderCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/8.
//
import OSLog
import UIKit

protocol OrderStatusChangedDelegate {
    func statusChanged(to state: OrderState, of order: Order, at indexPath: IndexPath)
}



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
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    required init?(coder: NSCoder) {
        status = OrderState.preparing
        super.init(coder: coder)
    }
}
