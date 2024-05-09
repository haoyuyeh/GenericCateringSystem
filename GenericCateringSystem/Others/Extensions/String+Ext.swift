//
//  String+Ext.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/4/26.
//

/**
 "^[\\w\\s]+$" : cannot be an empty string or only all whitespaces
 "^[\\d]+$" : only inputs the numbers and at least one digi
 */

import Foundation

extension String {
    /// check if the string matches the pattern.
    /// - Parameter pattern: regular expression is used
    /// - Returns:
    func isMatch(pattern: String) -> Bool {
        // only trim the both end of given string
        let text = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.range(of: pattern, options: .regularExpression) != nil {
            return true
        }else {
            return false
        }
    }
    
    func toDate(format: String) -> Date? {
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format

        return formatter.date(from: self)
    }
}
