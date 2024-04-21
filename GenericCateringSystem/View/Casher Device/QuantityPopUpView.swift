//
//  QuantityPopUpView.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/4/21.
//

import UIKit

protocol QuantityPopUpViewDelegate {
    func addChoosedItem(quantity: Int)
}

class QuantityPopUpView: UIView {

    var delegate: QuantityPopUpViewDelegate?
    
    @IBOutlet weak var quantityTextField: UITextField!
    
    @IBAction func minusBtnPressed(_ sender: UIButton) {
        quantityTextField.text = String((Int(quantityTextField.text!) ?? 1) - 1)
    }
    
    @IBAction func plusBtnPressed(_ sender: UIButton) {
        quantityTextField.text = String((Int(quantityTextField.text!) ?? 1) + 1)
    }
    
    @IBAction func valueCheck(_ sender: UITextField) {
        var quantity = Int(quantityTextField.text!) ?? 1
        if quantity <= 0 {
            quantity = 1
        }
        quantityTextField.text = String(quantity)
    }
    
    @IBAction func doneBtnPressed(_ sender: UIButton) {
        delegate!.addChoosedItem(quantity: Int(quantityTextField.text!) ?? 1)
    }
}
