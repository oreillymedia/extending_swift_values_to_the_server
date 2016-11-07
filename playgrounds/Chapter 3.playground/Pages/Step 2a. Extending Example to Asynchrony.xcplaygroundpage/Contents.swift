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

func showCityOrError(for user: String) {
    requestCity(of: user) {
        // Outer callback:
        if let city = $0 {
            requestTemperature(in: city) {
                // Inner callback:
                if let temperature = $0 {
                    show(temperature: temperature, for: user)
                }
                else {
                    show(error: $1 ?? Errors.missing, for: user)
                }
            }
        }
        else {
            show(error: $1 ?? Errors.missing, for: user) }
    }
}

//: try it:

executeSoThatShowWorksAsynchronously {
    showCityOrError(for: "David")
}
executeSoThatShowWorksAsynchronously {
    showCityOrError(for: "John")
}
executeSoThatShowWorksAsynchronously {
    showCityOrError(for: "Marsha")
}




//: [Next](@next)
