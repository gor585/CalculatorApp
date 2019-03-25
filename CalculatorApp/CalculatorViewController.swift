//
//  ViewController.swift
//  CalculatorApp
//
//  Created by Jaroslav Stupinskyi on 20.03.19.
//  Copyright © 2019 Jaroslav Stupinskyi. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var displayLabel: UILabel!
    
    private var userIsTypingDigits = false
    
    private var brain = CalculatorBrain()
    
    private var displayValue: Double {
        //Getting current display label text as Double
        get {
            guard let text = displayLabel.text else { return 0.0 }
            return Double(text)!
        }
        //Setting display label text with newValue
        set {
            displayLabel.text = floatingPointOptimization(number: newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction private func digitButtonPressed(_ sender: UIButton) {
        pressingAnimation(button: sender)
        guard let digit = sender.currentTitle else { return }
        //If user just started to type - first digit he typed will replace default 0. Else it will append to current display value
        if userIsTypingDigits == false {
            displayLabel.text = digit
        } else {
            guard let currentDisplayText = displayLabel.text else { return }
            displayLabel.text = currentDisplayText + digit
        }
        userIsTypingDigits = true
    }
    
    
    @IBAction private func operationButtonPressed(_ sender: UIButton) {
        pressingAnimation(button: sender)
        if userIsTypingDigits {
            userIsTypingDigits = false
            brain.setOperand(operand: displayValue)
        }
        
        guard let symbol = sender.currentTitle else { return }
        brain.performOperation(operationSymbol: symbol)
        
        guard let result = Double(floatingPointOptimization(number: brain.result)) else { return }
        displayValue = result
    }
    
    //Button animation on tap
    private func pressingAnimation(button: UIButton) {
        UIButton.animate(withDuration: 0.2, animations: {
            button.transform = CGAffineTransform(scaleX: 0.97, y: 0.96)
        }) { finish in
            UIButton.animate(withDuration: 0.2, animations: {
                button.transform = CGAffineTransform.identity
            })
        }
    }
    
    //Displaying floating point only if remainder != 0
    private func floatingPointOptimization(number: Double) -> String {
        let stringNumber = String(number)
        let separator = "."
        let separatedValue = stringNumber.components(separatedBy: separator)
        let rightSide = separatedValue[0]
        let leftSide = separatedValue[1]
        if Int(leftSide) == 0 {
            return rightSide
        } else {
            return String(number)
        }
    }
}

