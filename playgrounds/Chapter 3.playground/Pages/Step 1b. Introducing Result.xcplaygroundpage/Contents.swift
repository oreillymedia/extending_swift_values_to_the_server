//: [Previous](@previous)

import Foundation

//: This page automatically imports City, Temperature, Errors, and Result from the Sources folder.
//: See [How to look at code in Sources](How%20to%20look%20at%20code%20in%20Sources)


//: This version of basicGetTemperature takes a Result and directly switches on it:

func getTemperatureFromCity( aResult: Result<City> )
    -> Result<Int>
{
    switch aResult {
    case let .fulfilled(city):
        return Result<Int> { try basicGetTemperature(in: city) }
    case let .rejected(err):
        return Result<Int>.rejected(err)
    }
}


let aResult = Result<City> { try basicGetCity(of: "David") }
getTemperatureFromCity(aResult: aResult)

let anotherResult = Result<City> { try basicGetCity(of: "Mabel") }
getTemperatureFromCity(aResult: anotherResult)

//: But it's more reusable to put the switch inside of Result in a member function:

//: See Result.swift

//: And then the composition gets easy to read:

func printTemperature(for user: String) {
    Result { try basicGetCity(of: user) }
        .then { try basicGetTemperature(in: $0) }
        .then { show(temperature: $0, for: user) }
}

printTemperature(for: "David")
printTemperature(for: "Bert") // This invocation does not print anything


func printTemperatureOrErrorAssumingAustin(for user: String) {
    // Type inference allows omission of <City> after Result below:
    Result { try basicGetCity(of: user) }
        .recover { _ in .Austin }
        .then { try basicGetTemperature(in: $0) }
        .catch { show(error: $0, for: user) }
        .then {
            show(temperature: $0, for: user) }
}

//: In the View menu, select 'Debug Area' and then 'Activate Console' to see the print output:


executeSoThatShowWorksAsynchronously {
    printTemperatureOrErrorAssumingAustin(for: "David") // prints 70; that's where David is
}
executeSoThatShowWorksAsynchronously {
    printTemperatureOrErrorAssumingAustin(for: "Manny") // prints 90; assuming Austin
}
executeSoThatShowWorksAsynchronously {
    printTemperatureOrErrorAssumingAustin(for: "John")  // prints error; no temp
}
