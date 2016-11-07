//: [Previous](@previous)
//: # Structures Isolate Mutation
//: ## Classes can invite bugs
import Foundation

//: To see the results easier in a playground, we'll change the callbacks to return what was printed in the text



class TemperatureRequestClass {
    let city: String
    var startTime: Date? = nil // an optional Date
    init(city: String) {  self.city = city  }
    
    //: This playground departs from the text by putting this function inside the class
    func receivedResponse(temperature: Int) {
        let dbTime = Date().timeIntervalSince( startTime! )
        printForPlayground("It took", dbTime,
              "seconds to discover that the temperature in",
              city, "is", temperature)
    }
    
}

func dummySend(request: TemperatureRequestClass) {}

var dummy = 0

func sendToDB1( request: TemperatureRequestClass,  callback: @escaping (Int) -> Void )
{
    // Do lots of slow work to prepare to connection
    for i in 0 ..< 10000 {
        dummy = i
    }
    // Comment the next line out to see the true send time
    request.startTime = Date() //The BUG!
    
    // Send the request on the prepared connection
    asyncForPlayground { callback(70) }
}



//: In order to see the print output, you need to
//: go to the View menu, select "Debug Area", then "Activate Console"

let request1 = TemperatureRequestClass (city: "Paris")
request1.startTime = Date()
sendToDB1(request: request1, callback: request1.receivedResponse)
//: Because of the bug, the elapsed time is too small below:
whatWasPrinted
//: - - -
//: ## Now, use a structure
struct TemperatureRequestStruct {
    let city: String
    var startTime: Date? = nil
    init(city: String) {  self.city = city  }
    
    //: This playground departs from the text by putting this function inside the structure
    func receivedResponse(temperature: Int) {
        let dbTime = Date().timeIntervalSince( startTime! )
        printForPlayground("It took", dbTime,
              "seconds to discover that the temperature in",
              city, "is", temperature)
    }
    
}

func sendToDB2( request: TemperatureRequestStruct,  callback: @escaping (Int) -> Void )
{
    
    // Do lots of slow work to prepare to connection
    for i in 0 ..< 10000 {
        dummy = i
    }
    // Comment the next line out to see the true send time
    // But with a structure the next line will not compile.
    // Uncomment the next line to see the error: Cannot assign to property: 'request' is a 'let' constant
    // request.startTime = Date() // The BUG!, but ILLEGAL with a structure
    
    // Send the request on the prepared connection
    asyncForPlayground { callback(60) }
}

var request2 = TemperatureRequestStruct(city: "London")
request2.startTime = Date()
sendToDB2(request: request2, callback: request2.receivedResponse)
//: The elapsed time is right:
whatWasPrinted
//: - - -
//: ## Trying the quick fix:
func sendToDB3( request: TemperatureRequestStruct,  callback: @escaping (Int) -> Void )
{
    // Do lots of slow work to prepare to connection
    for i in 0 ..< 10000 {
        dummy = i
    }
    // Quick fix:
    var mutableRequest = request
    mutableRequest.startTime = Date() // Cannot hurt anything because mutableRequest is a copy
    
    // Send the request on the prepared connection
    callback(80)
}

var request3 = TemperatureRequestStruct (city: "Rome")
request3.startTime = Date()
sendToDB3(request: request3, callback: request3.receivedResponse)
//: The elapsed time is still right:
whatWasPrinted
//: - - -
//: ## Mutating Methods
extension TemperatureRequestStruct {
    // Delete 'mutating' below to see the error:
    // "Cannot assign to property: 'self' is immutable"
    mutating func clearStartTime() { startTime = nil }
}

var r = TemperatureRequestStruct(city: "Athens")
r.startTime = Date()
let request4 = r
var request5 = request4 // makes a copy because is a struct
// Uncomment next line to see the error: "Cannot use mutating member on immutable value: 'request4' is a 'let' constant
// request4.clearStartTime() // ILLEGAL: cannot mutate a let
request5.clearStartTime() // OK, but does not change request4
request4.startTime
request5.startTime
//: - - -
//: ## Default Implementations with Protocol Extensions
struct TemperatureRequest1 {
    let city: String
    let state: String
    var startTime: Date? = nil
    init(city: String, state: String) {
        self.city  = city
        self.state = state
    }
    var cityAndState: String { return city + ", " + state }
}
struct OzoneRequest1 {
    let city: String
    let state: String
    var startTime: Date? = nil
    init(city: String, state: String) {
        self.city  = city
        self.state = state
    }
    var cityAndState: String { return city + ", " + state }
}

TemperatureRequest1(city: "NY",      state: "NY").cityAndState
OzoneRequest1      (city: "Athens",  state: "GA").cityAndState









