//
//  TextField+Ext.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/11/4.
//

import UIKit

extension UITextField {
    /// check if the textfield's input matches the pattern.
    /// - Parameter pattern: regular expression is used
    /// - Returns:
    func isInputMatch(pattern: String) -> Bool {
        var text = self.text ?? ""
        // only trim the both end of given pattern
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.range(of: pattern, options: .regularExpression) != nil {
            return true
        }else {
            return false
        }
    }
    
    /// check if the textfield only inputs the numbers and at least one digi
    /// - Returns: Bool
    func hasNumbersOnly() -> Bool {
        let rex = "^[\\d]+$"
        
        var text = self.text ?? ""
        if text.range(of: rex, options: .regularExpression) != nil {
            return true
        }else {
            return false
        }
    }
}
