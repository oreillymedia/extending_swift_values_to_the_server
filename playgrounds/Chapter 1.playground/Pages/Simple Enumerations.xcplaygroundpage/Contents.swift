//: [Previous](@previous)

import Foundation

//: # Simple Enumerations

enum Validity { case valid, invalid }

enum StatusCode: Int {
    case ok           = 200
    case created      = 201
    // more cases go here
    case badRequest   = 400
    case unauthorized = 401
}

func printRealValue(of e: StatusCode) {
    print ("real value is", e.rawValue)
}

printRealValue(of: /* StatusCode */.badRequest) // StatusCode is inferred by the compiler


//: [Next](@next)
