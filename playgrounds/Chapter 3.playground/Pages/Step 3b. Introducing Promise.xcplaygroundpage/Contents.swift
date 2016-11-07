//: [Previous](@previous)

import Foundation

//: See [Promise](Promise)


func requestCity(of user: String) -> Promise<City> {
    // obtain a new Promise & fulfill & rejectfunctions
    let (promise, fulfill, reject) = Promise<City>.pending()
    DispatchQueue.global(qos: .userInitiated).async {
        do    { fulfill( try basicGetCity(of: user) ) }
        catch { reject( error ) }
    }
    return promise
}

func requestTemperature(in city: City) -> Promise<Int> {
    // obtain a new Promise & fulfill & reject functions
    let (promise, fulfill, reject) = Promise<Int>.pending()
    DispatchQueue.global(qos: .userInitiated).async {
        do    { fulfill( try basicGetTemperature(in: city) ) }
        catch { reject( error ) }
    }
    return promise
}


func showCityOrError(for user: String) {
    let myQ = DispatchQueue.global(qos: .userInitiated)
    requestCity(of: user)
        .then (on: myQ) { requestTemperature(in: $0 ) }
        .then (on: myQ) { show(temperature: $0, for: user) }
        .catch(on: myQ) { show(error: $0, for: user) }
}

executeSoThatShowWorksAsynchronously {
    showCityOrError( for: "David" )
}
executeSoThatShowWorksAsynchronously {
    showCityOrError( for: "John"  )
}
executeSoThatShowWorksAsynchronously {
    showCityOrError( for: "Linda" )
}


//: [Next](@next)
