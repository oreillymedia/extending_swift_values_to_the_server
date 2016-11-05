//: [Previous](@previous)

import Foundation

//: # Generic Protocols

//: First, without protocols:

struct TemperatureResponse1 {
    let city:   String
    let answer: Int
}
struct FavoriteFoodResponse1 {
    let city:   String
    let answer: String
}

//: Now, with protocols

protocol ResponseProtocol {
    associatedtype Answer
    
    var city:   String{get}
    var answer: Answer {get}
}

struct TemperatureResponse2: ResponseProtocol {
    let city:   String
    let answer: Int
}
struct FavoriteFoodResponse2: ResponseProtocol {
    let city:   String
    let answer: String
}

//: Uncomment the following line to see the error:
//: "Protocol 'ResponseProtocol' can only be used as a generic constraint because it has Self or associated type required"
// var someResponse: ResponseProtocol // ILLEGAL

func handleResponse <SomeResponseType: ResponseProtocol> ( response: SomeResponseType) -> String
{
    return "The response's city is \(response.city)."
}
handleResponse(response: TemperatureResponse2 (city: "San Jose",       answer: 70) )
handleResponse(response: FavoriteFoodResponse2(city: "San Francisco",  answer: "sourdough") )

//: [Next](@next)
