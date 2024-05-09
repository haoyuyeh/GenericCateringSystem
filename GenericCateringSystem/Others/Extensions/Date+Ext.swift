//
//  Date+Ext.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/9.
//

import Foundation

extension Date {
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
