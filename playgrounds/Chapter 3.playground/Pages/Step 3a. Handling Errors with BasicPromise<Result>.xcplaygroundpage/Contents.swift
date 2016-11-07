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


func showCityOrErrorUsingBasicPromise(for user: String) {
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
            $0.then { show(temperature: $0, for: user) }
            $0.catch { show(error: $0, for: user) }
    }
}

executeSoThatShowWorksAsynchronously {
    showCityOrErrorUsingBasicPromise(for: "Rob")
}
executeSoThatShowWorksAsynchronously {
    showCityOrErrorUsingBasicPromise(for: "John")
}
executeSoThatShowWorksAsynchronously { showCityOrErrorUsingBasicPromise(for: "Jane")
}






