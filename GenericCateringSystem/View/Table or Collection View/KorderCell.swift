//
//  KorderCell.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/6/23.
//
import OSLog
import UIKit
import CoreData

class KorderCell: UITableViewCell {
    // MARK: Properties
    private let logger = Logger(subsystem: "Table or Collection View", category: "KorderCell")
    
    
    // MARK: IBOutlet
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var reminder: UILabel!
}

extension KorderCell: CellConfig {
    func configure<T>(with target: NSManagedObject, of classType: T.Type) {
        let order = (target as! Order)
        let currentTime = Date(), interval: TimeInterval
        
        title.text = order.number
        subTitle.text = "Ordered at \(order.establishedDate?.toString(format: "HH:mm:ss") ?? "nil")"
        if let date = order.establishedDate {
            interval = currentTime.distance(to: date)
        }
        reminder.text = String(format: "%d mins passed", round(interval/60))
    }
}
