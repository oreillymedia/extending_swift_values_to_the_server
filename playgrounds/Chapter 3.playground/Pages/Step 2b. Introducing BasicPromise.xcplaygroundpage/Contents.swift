 //: [Previous](@previous)
//:# The BasicPromise class
import Foundation
//: A *BasicPromise* handles any type of Outcome, and doesn't help deal with about errors.
//: See *BasicPromise* in the *Sources* folder.
//: - - -
 //: ## First, the callback-style query functions:
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
//: - - -
//: ## Wrapping the callback-style queries to get query functions using *BasicPromises*
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
//: - - -
//: ## *BasicPromise* provides an elegant and readable way to program asynchrony (but not handling errors)
func printTemperatureIgnoringErrors(of user: String) {
    requestCityIgnoringErrors(of: user)
        .then { requestTemperatureIgnoringErrors(in: $0) }
        .then { printForPlayground(temperature: $0, for: user) }
}

asyncForPlayground {
    printTemperatureIgnoringErrors(of: "Rob")
}
//: [Next](@next)
