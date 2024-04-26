//
//  String+Ext.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/4/26.
//

import Foundation

extension String {
    /// check if the string matches the pattern.
    /// - Parameter pattern: regular expression is used
    /// - Returns:
    func isMatch(pattern: String) -> Bool {
        // only trim the both end of given pattern
        let text = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.range(of: pattern, options: .regularExpression) != nil {
            return true
        }else {
            return false
        }
    }
}
