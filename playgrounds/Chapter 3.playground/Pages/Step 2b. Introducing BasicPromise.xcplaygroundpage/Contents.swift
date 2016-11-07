 //: [Previous](@previous)

import Foundation

// A BasicPromise handles any type of Outcome, and doesn't help deal with about errors.
//: See BasicPromise.swift


func requestCityIgnoringErrors(
    of user: String,
    callback: @escaping (City) -> Void
    ) {
    // Simulate the asynchrony of a web request
    DispatchQueue.global(qos: .userInitiated).async {
        callback( try! basicGetCity(of: user) )
    }
}

func requestTemperatureIgnoringErrors(
    in city: City,
    callback: @escaping (Int) -> Void
    ) {
    // Simulate the asynchrony of a web request
    DispatchQueue.global(qos: .userInitiated).async {
    callback( try! basicGetTemperature(in: city) )
    }
}



func requestCityIgnoringErrors(of user: String)
    -> BasicPromise<City>
{
    let promise = BasicPromise<City>()
    requestCityIgnoringErrors(of: user) { promise.fulfill($0) }
    return promise
}

// Also wrap the temperature request:
func requestTemperatureIgnoringErrors(in city: City)
    -> BasicPromise<Int>
{
    let promise = BasicPromise<Int>()
    requestTemperatureIgnoringErrors(in: city) { promise.fulfill($0) }
    return promise
}

func printTemperatureIgnoringErrors(of user: String) {
    requestCityIgnoringErrors(of: user)
        .then { requestTemperatureIgnoringErrors(in: $0) }
        .then { show(temperature: $0, for: user) }
}

BasicPromise<City>.defaultQueue = DispatchQueue.global(qos: .userInitiated) // prevent deadlock below
BasicPromise<Int >.defaultQueue = DispatchQueue.global(qos: .userInitiated) // prevent deadlock below

executeSoThatShowWorksAsynchronously {
    printTemperatureIgnoringErrors(of: "Rob")
}

//: [Next](@next)
