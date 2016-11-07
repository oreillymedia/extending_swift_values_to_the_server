//: [Previous](@previous)
//: # City and Temperature Running Example
import Foundation
//: This page automatically imports City, Temperature and Errors from the Sources folder.
//: See [How to look at code in Sources](How%20to%20look%20at%20code%20in%20Sources).
//: - - -
try basicGetCity(of: "David")

do    { try basicGetCity(of: "Joe") }
catch { "\(error): no city for Joe"      }
//: - - -
//: Synchronous composition with exceptions:

func printTemperatureOrError(for user: String) {
    do {
        let city        = try basicGetCity(of: user)
        let temperature = try basicGetTemperature(in: city)
        printForPlayground(temperature: temperature, for: user)
    }
    catch {
        printForPlayground(error: error, for: user)
    }
}

printTemperatureOrError(for: "Rob")
whatWasPrinted

printTemperatureOrError(for: "Jane")
whatWasPrinted
//: [Next](@next)
