//
//  ExtTextField.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2023/11/4.
//

import UIKit

extension UITextField {
    /// check if the textfield inputs any character except all whitespaces
    /// - Returns: bool
    func nameValidate() -> Bool {
        let rex = "^[\\w\\s]+$"
        
        var text = self.text ?? ""
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.range(of: rex, options: .regularExpression) != nil {
            return true
        }else {
            return false
        }
    }
    
    /// check if the textfield only inputs the numbers and at least one digi
    /// - Returns: Bool
    func numbersValidate() -> Bool {
        let rex = "^[\\d]+$"
        
        var text = self.text ?? ""
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.range(of: rex, options: .regularExpression) != nil {
            return true
        }else {
            return false
        }
    }
}
