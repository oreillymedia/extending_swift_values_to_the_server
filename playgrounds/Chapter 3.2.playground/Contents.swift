//: Playground - noun: a place where people can play

import Foundation
import Dispatch

enum City { case Austin, Mountain_View, Podunk }
enum Errors: String, Error { case unknownUser, unknownCity, errorWasNil }

//: Callback-style

func requestCity(
    of user: String,
    _ callback: @escaping (City?, Error?) -> Void
) {
    DispatchQueue.global(qos: .userInitiated).async {
        switch user {
        case "Rob":   callback(.Austin, nil)
        case "David": callback(.Mountain_View, nil)
        case "John":  callback(.Podunk, nil)
        default:      callback(nil, Errors.unknownUser)
        }
    }
}
func requestTemperature(
    in city: City,
    _ callback: @escaping (Int?, Error?)-> Void
) {
    DispatchQueue.global(qos: .userInitiated).async {
        switch city {
        case .Austin:        callback(90, nil)
        case .Mountain_View: callback(70, nil)
        default:             callback(nil, Errors.unknownCity)
        }
    }
}

func printCityOrError(for user: String) {
    requestCity(of: user) {
        // Outer callback:
        if let city = $0 {
            requestTemperature(in: city) {
                // Inner callback:
                if let temperature = $0 {
                    print("temperature for", user, "is", temperature)
                }
                else {
                    print("no temperature for", user, "error:", $1 ?? Errors.errorWasNil)
                }
            }
        }
        else {
            print("no city for", user, "error:", $1 ?? Errors.errorWasNil)
        }
    }
}

//: try it:
//: In the View menu, select 'Debug Area' and then 'Activate Console' to see the print output:

printCityOrError(for: "David")
printCityOrError(for: "John")
printCityOrError(for: "Marsha")


// A BasicPromise handles any type of Outcome, and doesn't help deal with about errors.
private var defaultQ: DispatchQueue = .main

public class BasicPromise<Outcome> {
    private typealias Consumer = (Outcome) -> Void
    private var outcomeIfKnown: Outcome?
    private var consumerAndQueueIfKnown: (consumer: Consumer, q: DispatchQueue)?
    
    
    private let racePrevention = DispatchSemaphore(value: 1)
    private func oneAtATime(_ fn: () -> Void) {
        defer { racePrevention.signal() }
        racePrevention.wait()
        fn()
    }
    
    internal static var defaultQueue: DispatchQueue {
        get { return defaultQ }
        set { defaultQ = newValue }
    }
    
    public init() {}
    
    
    
    public func fulfill(_ outcome: Outcome) -> Void
    {
        oneAtATime {
            if let (consumer, q) = self.consumerAndQueueIfKnown {
                q.async {
                    consumer(outcome)
                }
            }
            else {
                self.outcomeIfKnown = outcome
            }
        }
    }
    
    
    public func then(
        on q: DispatchQueue = BasicPromise.defaultQueue,
        execute consumer: @escaping (Outcome) -> Void
        )
    {
        oneAtATime {
            if let outcome = outcomeIfKnown {
                q.async { consumer(outcome) }
            }
            else {
                self.consumerAndQueueIfKnown = (consumer, q)
            }
        }
    }
    
    
    public func then<NewOutcome>(
        on q: DispatchQueue = BasicPromise.defaultQueue,
        execute transformer:
        @escaping (Outcome) -> NewOutcome
        )
        -> BasicPromise<NewOutcome>
    {
        let p = BasicPromise<NewOutcome>()
        then(on: q) { p.fulfill( transformer( $0 ) ) }
        return p
    }
    
    
    public func then<NewOutcome>(
        on q: DispatchQueue = BasicPromise.defaultQueue,
        execute asyncTransformer: @escaping (Outcome) -> BasicPromise<NewOutcome>
        ) -> BasicPromise<NewOutcome>
    {
        let p = BasicPromise<NewOutcome>()
        then(on: q) {
            asyncTransformer($0)
                .then(on: q) { p.fulfill($0) }
        }
        return p
    }
}



func requestCityIgnoringErrors(
    of user: String,
    callback: @escaping (City) -> Void
) {
    // Simulate the asynchrony of a web request
    DispatchQueue.global(qos: .userInitiated).async {
        switch user {
        case "Rob":   callback(.Austin)
        case "David": callback(.Mountain_View)
        case "John":  callback(.Podunk)
        default: abort()
        }
    }
}

func requestTemperatureIgnoringErrors(
    in city: City,
    callback: @escaping (Int) -> Void
    ) {
    // Simulate the asynchrony of a web request
    DispatchQueue.global(qos: .userInitiated).async {
        switch city {
        case .Austin:        callback(90)
        case .Mountain_View: callback(70)
        default: abort()
        }
    }
}



func requestCityIgnoringErrors(of user: String)
    -> BasicPromise<City>
{
    let promise = BasicPromise<City>()
    requestCityIgnoringErrors(of: user) { promise.fulfill($0) }
    return promise
}

// Also wrap the temperature request:
func requestTemperatureIgnoringErrors(in city: City)
    -> BasicPromise<Int>
{
    let promise = BasicPromise<Int>()
    requestTemperatureIgnoringErrors(in: city) { promise.fulfill($0) }
    return promise
}

func printTemperatureIgnoringErrors(of user: String) {
    requestCityIgnoringErrors(of: user)
        .then { requestTemperatureIgnoringErrors(in: $0) }
        .then { print("Temperature for", user, "is", $0) }
}

BasicPromise<City>.defaultQueue = DispatchQueue.global(qos: .userInitiated) // prevent deadlock below
BasicPromise<Int >.defaultQueue = DispatchQueue.global(qos: .userInitiated) // prevent deadlock below

printTemperatureIgnoringErrors(of: "Rob")
