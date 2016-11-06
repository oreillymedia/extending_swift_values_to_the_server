//: [Previous](@previous)


import Foundation


//: See the Sources








func requestCity(of user: String) -> BasicPromise<Result<City>>
{
    let promise = BasicPromise<Result<City>>()
    // Simulate the asynchrony of a web request
    DispatchQueue.global(qos: .userInitiated).async {
        switch user {
        case "Rob":
            promise.fulfill(.fulfilled(.Austin))
        case "David":
            promise.fulfill(.fulfilled(.Mountain_View))
        case "John":
            promise.fulfill(.fulfilled(.Podunk))
        default:
            promise.fulfill(.rejected(Errors.unknownUser))
        }
    }
    return promise
}
func requestTemperature(in city: City)
    -> BasicPromise<Result<Int>>
{
    let promise = BasicPromise<Result<Int>>()
    // Simulate the asynchrony of a web request
    DispatchQueue.global(qos: .userInitiated).async {
        switch city {
        case .Austin:        promise.fulfill(.fulfilled(90))
        case .Mountain_View: promise.fulfill(.fulfilled(70))
        default:             promise.fulfill(.rejected(Errors.unknownCity))
        }
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





//: See Promise.swift


func requestCity(of user: String) -> Promise<City> {
    // obtain a new Promise & fulfill & reject functions
    let (promise, fulfill, reject) = Promise<City>.pending()
    DispatchQueue.global(qos: .userInitiated).async {
        switch user {
        case "Rob":   fulfill(.Austin)
        case "David": fulfill(.Mountain_View)
        case "John":  fulfill(.Podunk)
        default:      reject(Errors.unknownUser)
        }
    }
    return promise
}

func requestTemperature(in city: City) -> Promise<Int> {
    // obtain a new Promise & fulfill & reject functions
    let (promise, fulfill, reject) = Promise<Int>.pending()
    DispatchQueue.global(qos: .userInitiated).async {
        switch city {
        case .Austin:        fulfill(90)
        case .Mountain_View: fulfill(70)
        default:             reject(Errors.unknownCity)
        }
    }
    return promise
}


func printCityOrError(for user: String) {
    let myQ = DispatchQueue.global(qos: .userInitiated)
    requestCity(of: user)
        .then (on: myQ) { requestTemperature(in: $0 ) }
        .then (on: myQ) { print("Temperature for", user, "is", $0 ) }
        .catch(on: myQ) { print("No temperature for", user, "error:", $0 ) }
}

printCityOrError(for: "David")
printCityOrError(for: "John")
printCityOrError(for: "Linda")

