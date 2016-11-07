//: [Previous](@previous)
//: # Basic example with asynchrony using callbacks
import Foundation
//: ## Callback-style request functions:
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
//: - - -
//: ## Nested callbacks get messy:
func printCityOrError(for user: String) {
    requestCity(of: user) {
        // Outer callback:
        if let city = $0 {
            requestTemperature(in: city) {
                // Inner callback:
                if let temperature = $0 {
                    printForPlayground(temperature: temperature, for: user)
                }
                else {
                    printForPlayground(error: $1 ?? Errors.missing, for: user)
                }
            }
        }
        else {
            printForPlayground(error: $1 ?? Errors.missing, for: user) }
    }
}
//: - - -
//: ## But they do work:
// (*asyncForPlayground* returns *whatWasPrinted*. See *PrintingAndAsynchrony* in *Sources.)
asyncForPlayground {
    printCityOrError(for: "David")
}
asyncForPlayground {
    printCityOrError(for: "John")
}
asyncForPlayground {
    printCityOrError(for: "Marsha")
}
//: [Next](@next)
