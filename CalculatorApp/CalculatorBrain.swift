//
//  CalculatorBrain.swift
//  CalculatorApp
//
//  Created by Jaroslav Stupinskyi on 21.03.19.
//  Copyright © 2019 Jaroslav Stupinskyi. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var accumulator = 0.0
    private var accumulatorValueChanged = false
    var memmorizedValue = 0.0
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    //Types of available operations and their raw values
    private enum Operations {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case AddValueToMemmory
        case GetMemmorizedValue
        case RemoveValueFromMemmory
        case Equals
    }
    
    //Kinds of operation symbols and their assignment to operation type
    private var operations: [String: Operations] = [
        "AC": .Constant(0.0),
        "√": .UnaryOperation(sqrt),
        "±": .UnaryOperation({ -$0 }),
        "+": .BinaryOperation({ $0 + $1 }),
        "-": .BinaryOperation({ $0 - $1 }),
        "×": .BinaryOperation({ $0 * $1 }),
        "÷": .BinaryOperation({ $0 / $1 }),
        "%": .BinaryOperation({ $0.truncatingRemainder(dividingBy: $1) }),
        "=": .Equals,
        "M+": .AddValueToMemmory,
        "ME": .GetMemmorizedValue,
        "M-": .RemoveValueFromMemmory
    ]
    
    func setOperand(operand: Double) {
        accumulator = operand
        accumulatorValueChanged = true
    }
    
    func performOperation(operationSymbol: String) {
        guard let operation = operations[operationSymbol] else { return }
        switch operation {
        case .Constant(let value):
            accumulator = value
        case .UnaryOperation(let function):
            accumulator = function(accumulator)
        case .BinaryOperation(let function):
            executePendingBinaryOperation()
            //When operation sign is depressed pending operation is initialized with current accumulator value as it's first operand. Operation executes if another operation sign is depressed
            pendingBinaryOperation = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
        case .Equals:
            executePendingBinaryOperation()
        case .AddValueToMemmory:
            memmorizedValue = accumulator
        case .GetMemmorizedValue:
            memmorizedValue != 0.0 ? accumulator = memmorizedValue : nil
        case .RemoveValueFromMemmory:
            memmorizedValue == accumulator ? memmorizedValue = 0.0 : nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: ((Double, Double) -> Double)
        var firstOperand: Double
    }
    
    private func executePendingBinaryOperation() {
        if pendingBinaryOperation != nil {
            accumulator = pendingBinaryOperation!.binaryFunction(pendingBinaryOperation!.firstOperand, accumulator)
            pendingBinaryOperation = nil
        }
    }
}
