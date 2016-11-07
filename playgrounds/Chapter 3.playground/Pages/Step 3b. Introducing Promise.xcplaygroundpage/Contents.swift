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


func printCityOrError(for user: String) {
    let myQ = DispatchQueue.global(qos: .userInitiated)
    requestCity(of: user)
        .then (on: myQ) { requestTemperature(in: $0 ) }
        .then (on: myQ) { show("Temperature for",    user, "is",     $0 ) }
        .catch(on: myQ) { show("No temperature for", user, "error:", $0 ) }
}

executeSoThatShowWorksAsynchronously {
    printCityOrError( for: "David" )
}
executeSoThatShowWorksAsynchronously {
    printCityOrError( for: "John"  )
}
executeSoThatShowWorksAsynchronously {
    printCityOrError( for: "Linda" )
}


//: [Next](@next)
