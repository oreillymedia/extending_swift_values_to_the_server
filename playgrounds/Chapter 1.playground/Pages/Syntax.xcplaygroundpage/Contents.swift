//: Playground - noun: a place where people can play

//: [Previous](@previous)

import Foundation


let aHost = "someMachine.com"
//: Uncomment the next line to see the error:
// aHost = "anotherMachine.com" // ILLEGAL — Cannot assign to value: 'aHost' is a 'let' constant

var aPath = "something"
aPath = "myDatabase" // OK

func combine(host: String, withPath path: String) -> String {
    return host + "/" + path
}
combine(host: "someMachine.com", withPath: "myDatabase")



//: [Next](@next)
