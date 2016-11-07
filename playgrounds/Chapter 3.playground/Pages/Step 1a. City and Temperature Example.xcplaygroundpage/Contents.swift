//: [Previous](@previous)

import Foundation

//: preliminaries:

//: This page automatically imports City, Temperature and Errors from the Sources folder.
//: See [How to look at code in Sources](How%20to%20look%20at%20code%20in%20Sources)





//: try basicGetCity:

try basicGetCity(of: "David")

do    { try basicGetCity(of: "Joe") }
catch { "\(error): no city for Joe"      }



//: Synchronous composition with exceptions:

func showTemperatureOrError(for user: String) {
    do {
        let city        = try basicGetCity(of: user)
        let temperature = try basicGetTemperature(in: city)
        show(temperature: temperature, for: user)
    }
    catch {
        show(error: error, for: user)
    }
}


executeSoThatShowWorksAsynchronously {
    showTemperatureOrError(for: "Rob")
}
executeSoThatShowWorksAsynchronously {
    showTemperatureOrError(for: "Jane")
}






//: [Next](@next)
