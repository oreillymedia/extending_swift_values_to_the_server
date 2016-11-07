//: [Previous](@previous)

import Foundation



//: Callback-style

func requestCity(
    of user: String,
    _ callback: @escaping (City?, Error?) -> Void
    ) {
    DispatchQueue.global(qos: .userInitiated).async {
        do    { callback( try basicGetCity(of: user), nil) }
        catch { callback( nil, error)                  }
    }
}
func requestTemperature(
    in city: City,
    _ callback: @escaping (Int?, Error?)-> Void
    ) {
    DispatchQueue.global(qos: .userInitiated).async {
        do    { callback( try basicGetTemperature(in: city), nil) }
        catch { callback( nil, error )                        }
    }
}

func printCityOrError(for user: String) {
    requestCity(of: user) {
        // Outer callback:
        if let city = $0 {
            requestTemperature(in: city) {
                // Inner callback:
                if let temperature = $0 {
                    show("temperature for", user, "is", temperature)
                }
                else {
                    show("no temperature for", user, "error:", $1 ?? Errors.missing)
                }
            }
        }
        else {
            show("no city for", user, "error:", $1 ?? Errors.missing)
        }
    }
}

//: try it:
//: In the View menu, select 'Debug Area' and then 'Activate Console' to see the print output:

executeSoThatShowWorksAsynchronously {
    printCityOrError(for: "David")
}
executeSoThatShowWorksAsynchronously {
    printCityOrError(for: "John")
}
executeSoThatShowWorksAsynchronously {
    printCityOrError(for: "Marsha")
}




//: [Next](@next)
