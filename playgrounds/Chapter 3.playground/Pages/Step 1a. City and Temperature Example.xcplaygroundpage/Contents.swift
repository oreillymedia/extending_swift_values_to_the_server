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

func printTemperatureOrError(for user: String) {
    do {
        let city        = try basicGetCity(of: user)
        let temperature = try basicGetTemperature(in: city)
        show("temperature for", user, "is:", temperature)
    }
    catch {
        show("no temperature for", user, "error:", error)
    }
}

//: Mac: the View menu, select 'Debug Area' and then 'Activate Console' to see the print output:
//: iPad: tap "Run My Code" on the bottom right of the screen, XXXXX

executeSoThatShowWorksAsynchronously {
    printTemperatureOrError(for: "Rob")
}
executeSoThatShowWorksAsynchronously {
    printTemperatureOrError(for: "Jane")
}






//: [Next](@next)
