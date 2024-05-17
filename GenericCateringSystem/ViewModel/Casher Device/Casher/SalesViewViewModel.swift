//
//  SalesViewViewModel.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/16.
//

import OSLog

class SalesViewViewModel {
    // MARK: Properties
    private var logger = Logger(subsystem: "Casher", category: "SalesViewViewModel")
    
    static let shared = SalesViewViewModel()
}

extension SalesViewViewModel {
    func getBarChartData(for interval: SalesInterval, startDate: Date = Date(), endDate: Date = Date()) -> [SalesData] {
        let start = getStartDate(for: interval, date: startDate)
        let end = endDate.endOfDay
        let p1 = NSPredicate(format: "establishedDate >= %@ && establishedDate <= %@", argumentArray: [start, end])
        let p2 = NSPredicate(format: "currentState == %d || currentState == %d", argumentArray: [OrderState.paid.rawValue, OrderState.orderDelivered.rawValue])
        let comP = NSCompoundPredicate(type: .and, subpredicates: [p1, p2])
        let data = Helper.shared.fetchOrder(predicate: comP)
        var returnData: [SalesData] = []
        
        data.forEach { order in
            returnData.append(SalesData(id: order.uuid!, date: (order.establishedDate?.toString(format: "dd/MM/yy"))!, type: getTypeStr(type: Int(order.type), platform: order.platformName), sum: order.totalSum))
        }
        
        return getFinalData(data: returnData)
    }
    
    private func getStartDate(for interval: SalesInterval, date: Date) -> Date {
        switch interval {
        case .today, .interval:
            return date.startOfDay
            
        case .weekly:
            // .weekday from 1-7
            let weekday = Calendar.current.component(.weekday, from: date) - 1
            let firstDayOfWeek = Calendar.current.date(byAdding: .day, value: -weekday, to: date)!
            return firstDayOfWeek.startOfDay
            
        case .monthly:
            return date.startOfMonth.startOfDay
        }
    }
    
    private func getTypeStr(type: Int, platform: String?) -> String {
        switch type {
        case OrderType.eatIn.rawValue:
            return "Eat-In"
            
        case OrderType.walkIn.rawValue:
            return "Walk-In"

        case OrderType.deliveryPlatform.rawValue:
            return platform!.capitalized
        default:
            logger.error("unknown order type!")
            return "nil"
        }
    }
    
    private func getFinalData(data: [SalesData]) -> [SalesData] {
        var finalData: [SalesData] = []
        
        data.forEach { data in
            if let index =  finalData.firstIndex(where: { fData in
                if fData.date == data.date && fData.type == data.type {
                    return true
                }else {
                    return false
                }
            }) {
                finalData[index].sum += data.sum
            }else {
                finalData.append(data)
            }
        }
        
        return finalData
    }
    
    func getSales(of date: String, from data: [SalesData]) -> Double {
        var sum = 0.0
        data.forEach { data in
            if data.date == date {
                sum += data.sum
            }
        }
        
        return sum
    }
}
