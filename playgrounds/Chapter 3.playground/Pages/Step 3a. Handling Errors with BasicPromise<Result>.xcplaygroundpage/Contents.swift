//: [Previous](@previous)


import Foundation


//: See the Sources








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
            $0.then { print( "Temperature for", user, "is", $0) }
            $0.catch { print( "No temperature for", user, "error:", $0) }
    }
}

printCityOrErrorUsingBasicPromise(for: "Rob")
printCityOrErrorUsingBasicPromise(for: "John")
printCityOrErrorUsingBasicPromise(for: "Jane")






