//
//  Date+Ext.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/9.
//

import Foundation

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    /// represent 23:59:59 of the day
    var endOfDay:Date {
        var components = DateComponents()
        
        components.day = 1
        components.second = -1
        
        return Calendar.current.date(byAdding: components, to: self.startOfDay)!
    }
    
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)!
    }
    
    
    func toString(format: String?, dateStyle: FormatStyle.DateStyle = .numeric, timeStyle: FormatStyle.TimeStyle = .shortened) -> String {
        if let format = format {
            let formatter = DateFormatter()
            
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = format

            return formatter.string(from: self)
        }else {
            return self.formatted(date: dateStyle, time: timeStyle)
        }
    }
}
