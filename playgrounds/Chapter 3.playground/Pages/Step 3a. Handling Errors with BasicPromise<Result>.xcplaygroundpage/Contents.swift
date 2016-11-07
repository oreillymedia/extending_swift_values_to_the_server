//: [Previous](@previous)
//: # Handling Errors with *BasicPromise* of a *Result*
import Foundation
//: - - -
//: ## Query functions that use a *Result* outcome for *BasicPromise*
//: (*Result* and *BasicPromise* are in *Sources*;
//: see [How to look at code in Sources](How%20to%20look%20at%20code%20in%20Sources).)
func requestCity(of user: String) -> BasicPromise<Result<City>>
{
    let promise = BasicPromise<Result<City>>()
    // Simulate the asynchrony of a web request
    DispatchQueue.global(qos: .userInitiated).async {
        promise.fulfill(  Result { try basicGetCity(of: user) }  )
    }
    return promise
}
func requestTemperature(in city: City)
    -> BasicPromise<Result<Int>>
{
    let promise = BasicPromise<Result<Int>>()
    // Simulate the asynchrony of a web request
    DispatchQueue.global(qos: .userInitiated).async {
        promise.fulfill(  Result { try basicGetTemperature(in: city) }  )
    }
    return promise
}
//: - - -
//: ## Using the queries is a bit awkward
func printCityOrErrorUsingBasicPromise(for user: String) {
    let myQ = DispatchQueue.global(qos: .userInitiated)
    requestCity(of: user)
        .then(on: myQ) {
            cityResult -> BasicPromise<Result<Int>> in
            switch cityResult {
            case let .rejected(err):
                let bp = BasicPromise<Result<Int>>()
                bp.fulfill(.rejected(err))
                return bp
            case let .fulfilled(city):
                return requestTemperature(in: city)
            }
        }
        .then(on: myQ) {
            $0.then { printForPlayground(temperature: $0, for: user) }
            $0.catch { printForPlayground(error: $0, for: user) }
    }
}
//: - - -
//: ## But they work!
asyncForPlayground {
    printCityOrErrorUsingBasicPromise(for: "Rob")
}
asyncForPlayground {
    printCityOrErrorUsingBasicPromise(for: "John")
}
asyncForPlayground { printCityOrErrorUsingBasicPromise(for: "Jane")
}


