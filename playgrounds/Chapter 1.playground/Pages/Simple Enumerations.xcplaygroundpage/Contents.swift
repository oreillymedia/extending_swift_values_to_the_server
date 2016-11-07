//: [Previous](@previous)
//: # Simple Enumerations
import Foundation

enum Validity { case valid, invalid }

enum StatusCode: Int {
    case ok           = 200
    case created      = 201
    // more cases go here
    case badRequest   = 400
    case unauthorized = 401
}

func getRealValue(of e: StatusCode) -> String {
    return "real value is \(e.rawValue)"
}

getRealValue(of: /* StatusCode */.badRequest) // StatusCode is inferred by the compiler
//: [Next](@next)
