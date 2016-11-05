//: Playground - noun: a place where people can play


//: Chapter 3 starts with a synchronous version of the city/temperature example. Here is an executable implementation.

import Foundation

//: preliminaries:

enum City { case Austin, Mountain_View, Podunk }
enum Errors: String, Error { case unknownUser, unknownCity }

//: getCity (synchronously)

func getCity(of user: String) throws -> City {
    switch user {
    case "Rob":    return .Austin
    case "David":  return .Mountain_View
    case "John":   return .Podunk
    default: throw Errors.unknownUser
    }
}

//: try getCity:

try getCity(of: "David")

do    { try getCity(of: "Joe") }
catch { "\(error): no city for Joe"      }


func getTemperature(in city: City) throws -> Int {
    switch city {
    case .Austin:        return 90
    case .Mountain_View: return 70
    default: throw Errors.unknownCity
    }
}

//: Synchronous composition with exceptions:

func printTemperatureOrError(for user: String) {
    do {
        let city = try getCity(of: user)
        let temperature = try getTemperature(in: city)
        print("temperature for", user, "is:", temperature)
    }
    catch {
        print("no temperature for", user, "error:", error)
    }
}

//: In the View menu, select 'Debug Area' and then 'Activate Console' to see the print output:

printTemperatureOrError(for: "Rob")
printTemperatureOrError(for: "Jane")

//: Introducing the Result enumeration:

enum Result<FulfilledValue> {
    case fulfilled(FulfilledValue)
    case rejected(Error)
    
    init( of body: () throws -> FulfilledValue ) {
        do { self = try .fulfilled( body() ) }
        catch { self = .rejected ( error ) }
    }
}

//: This version of getTemperature takes a Result and directly switches on it:

func getTemperatureFromCity( aResult: Result<City> )
    -> Result<Int>
{
    switch aResult {
    case let .fulfilled(city):
        return Result<Int> { try getTemperature(in: city) }
    case let .rejected(err):
        return Result<Int>.rejected(err)
    }
}


let aResult = Result<City> { try getCity(of: "David") }
getTemperatureFromCity(aResult: aResult)

let anotherResult = Result<City> { try getCity(of: "Mabel") }
getTemperatureFromCity(aResult: anotherResult)

//: But it's more reusable to put the switch inside of Result in a member function:

extension Result {
    func then <NewFulfilledValue> (
        execute body:
        (FulfilledValue) throws -> NewFulfilledValue
        ) -> Result<NewFulfilledValue>
    {
        switch self {
        case .rejected (let e):
            return .rejected(e)
        case .fulfilled(let r):
            do { return try .fulfilled( body(r) ) }
            catch { return .rejected ( error ) }
        }
    }
}

//: And then the composition gets easy to read:

func printTemperature(for user: String) {
    Result { try getCity(of: user) }
        .then { try getTemperature(in: $0) }
        .then { print("temperature where", user, "is: ", $0) }
}

printTemperature(for: "David")
printTemperature(for: "Bert") // This invocation does not print anything

//: Adding in error handling to Result;

extension Result {
    func recover(execute body: (Error) throws -> FulfilledValue)
        -> Result
    {
        switch self {
        case .fulfilled:
            return self
        case .rejected(let e):
            do    { return try .fulfilled( body(e)) }
            catch { return .rejected( error ) }
        }
    }
    func `catch`(execute body: (Error) -> Void)
        -> Result
    {
        switch self {
        case .fulfilled: break
        case .rejected(let e): body(e)
        }
        return self
    }
}

func printTemperatureOrErrorAssumingAustin(for user: String) {
    // Type inference allows omission of <City> after Result below:
    Result { try getCity(of: user) }
        .recover { _ in .Austin }
        .then { try getTemperature(in: $0) }
        .catch { print("error for", user, "(assuning Austin if unknown)", $0) }
        .then {
            print("temperature for", user,
                  "is (assuming Austin if unknown) is", $0)
    }
}

printTemperatureOrErrorAssumingAustin(for: "David") // prints 70; that's where David is
printTemperatureOrErrorAssumingAustin(for: "Manny") // prints 90; assuming Austin
printTemperatureOrErrorAssumingAustin(for: "John")  // prints error; no temperature for Podunk

