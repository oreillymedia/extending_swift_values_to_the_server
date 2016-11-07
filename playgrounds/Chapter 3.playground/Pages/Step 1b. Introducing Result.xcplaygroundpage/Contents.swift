//: [Previous](@previous)
//# The *Result* enumeration
import Foundation
//: Refer to *Result* from the Sources folder.
//: See [How to look at code in Sources](How%20to%20look%20at%20code%20in%20Sources).
//: - - -
//: ## Just to get a sense of the enumeration, try a *getTemperature* that takes a Result:
func getTemperature( fromCityResult aResult: Result<City> )
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
getTemperature(fromCityResult: aResult)

let anotherResult = Result<City> { try basicGetCity(of: "Mabel") }
getTemperature(fromCityResult:  anotherResult)
//: - - -
//: ## But it's more reusable to put the switch inside of Result in a member function.
//: (See the *then* method in the *Result* file in *Sources*.)

//: And then the composition gets easy to read:

func printTemperature(for user: String) {
    whatWasPrinted = "" // because errors do not print anything
    Result { try basicGetCity(of: user) }
        .then { try basicGetTemperature(in: $0) }
        .then { printForPlayground(temperature: $0, for: user) }
}

printTemperature(for: "David")
whatWasPrinted

printTemperature(for: "Bert")
whatWasPrinted
//: - - -
//: ## Using *recover* to situate unknown users in Austin:
func printTemperatureOrErrorAssumingAustin(for user: String) {
    // Type inference allows omission of <City> after Result below:
    Result { try basicGetCity(of: user) }
        .recover { _ in .Austin }
        .then { try basicGetTemperature(in: $0) }
        .catch { printForPlayground(error: $0, for: user) }
        .then {
            printForPlayground(temperature: $0, for: user) }
}
printTemperatureOrErrorAssumingAustin(for: "David")
whatWasPrinted

printTemperatureOrErrorAssumingAustin(for: "Manny")
whatWasPrinted

printTemperatureOrErrorAssumingAustin(for: "John")
whatWasPrinted
