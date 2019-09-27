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
    @IBOutlet weak var meButton: UIButton!
   
    @IBOutlet weak var displayAspectRatio: NSLayoutConstraint!
    
    private var userIsTypingDigits = false
    private var errorOccurred = false
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
    
    override func viewDidAppear(_ animated: Bool) {
        deviceOrientationNotificationsObserver()
    }
    
    @IBAction func acButtonPressed(_ sender: UIButton) {
        errorOccurred = false
        brain.setOperand(operand: 0.0)
        displayValue = 0.0
    }
    
    @IBAction private func digitButtonPressed(_ sender: UIButton) {
        pressingAnimation(button: sender)
        if errorOccurred == false {
            guard let digit = sender.currentTitle else { return }
            //If user just started to type - first digit he typed will replace default 0. Else it will append to current display value
            if userIsTypingDigits == false {
                if digit == "." {
                    displayLabel.text = "0" + digit
                } else {
                    displayLabel.text = digit
                }
            } else {
                guard let currentDisplayText = displayLabel.text else { return }
                displayLabel.text = currentDisplayText + digit
            }
            userIsTypingDigits = true
        }
    }
    
    @IBAction private func operationButtonPressed(_ sender: UIButton) {
        pressingAnimation(button: sender)
        if userIsTypingDigits {
            userIsTypingDigits = false
            brain.setOperand(operand: displayValue)
        }
        
        guard let symbol = sender.currentTitle else { return }
        brain.performOperation(operationSymbol: symbol)
        
        let result = brain.result
        if result.isNaN {
            displayLabel.text = "Error"
            errorOccurred = true
        } else {
            guard let resultInDouble = Double(floatingPointOptimization(number: result)) else { return }
            displayValue = resultInDouble
        }
        
        if brain.memmorizedValue != 0.0 && !brain.memmorizedValue.isNaN {
            meButton.backgroundColor = UIColor(red: 1.00339, green: 0.832369, blue: 0.473283, alpha: 1)
        } else {
            meButton.backgroundColor = UIColor(red: 0.754102, green: 0.75412, blue: 0.754111, alpha: 1)
        }
    }
    
    //Button animation on tap
    private func pressingAnimation(button: UIButton) {
        let originalColor = button.backgroundColor
        UIButton.animate(withDuration: 0.2, animations: {
            button.transform = CGAffineTransform(scaleX: 0.97, y: 0.96)
            button.backgroundColor = UIColor.lightGray
        }) { finish in
            UIButton.animate(withDuration: 0.2, animations: {
                button.transform = CGAffineTransform.identity
                button.backgroundColor = originalColor
            })
        }
    }
    
    //Displaying floating point only if remainder != 0
    private func floatingPointOptimization(number: Double) -> String {
        var outputDisplayValue = ""
        let stringNumber = String(number)
        let separator = "."
        let separatedValue = stringNumber.components(separatedBy: separator)
        if separatedValue.count == 2 {
            let leftSide = separatedValue[0]
            let rightSide = separatedValue[1]
            if Int(rightSide) == 0 {
                outputDisplayValue = leftSide
            } else {
                outputDisplayValue = String(number)
            }
        } else {
            outputDisplayValue = "Error"
        }
        return outputDisplayValue
    }
}

//MARK: Orientation Changes

extension CalculatorViewController {
    func sizeClass() -> (UIUserInterfaceSizeClass, UIUserInterfaceSizeClass) {
        return (self.traitCollection.horizontalSizeClass, self.traitCollection.verticalSizeClass)
    }
    
    func deviceOrientationNotificationsObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(deviceOrientationChanged), name: ORIENTATION_CHANGED, object: nil)
    }
    
    @objc func deviceOrientationChanged() {
        if UIDevice.current.orientation.isLandscape {
            displayAspectRatio.constant = 400
        } else {
            displayAspectRatio.constant = 0
        }
    }
}

