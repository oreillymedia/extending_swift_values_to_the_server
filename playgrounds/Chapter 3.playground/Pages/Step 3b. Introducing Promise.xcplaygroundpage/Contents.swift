//: [Previous](@previous)
//: # The *Promise* structure
//: *Promise* packages up a *BasicPromise* whose outcome is a *Result* to provide convenient asynchrony with error handling.
//: It is defined in the *Sources* folder.
//:(See [How to look at code in Sources](How%20to%20look%20at%20code%20in%20Sources).)
import Foundation
//: - - -
//: ## Query functions that return a *Promise*
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
//: - - -
//: ## *Promises* chain together so easily:
func printCityOrError(for user: String) {
    let myQ = DispatchQueue.global(qos: .userInitiated)
    requestCity(of: user)
        .then (on: myQ) { requestTemperature(in: $0 ) }
        .then (on: myQ) { printForPlayground(temperature: $0, for: user) }
        .catch(on: myQ) { printForPlayground(error: $0, for: user) }
}
//: - - -
//: And they work:
asyncForPlayground {
    printCityOrError( for: "David" )
}
asyncForPlayground {
    printCityOrError( for: "John"  )
}
asyncForPlayground {
    printCityOrError( for: "Linda" )
}
