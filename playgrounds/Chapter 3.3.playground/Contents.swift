//: Playground - noun: a place where people can play

import UIKit

import Foundation
import Dispatch

enum City { case Austin, Mountain_View, Podunk }
enum Errors: String, Error { case unknownUser, unknownCity, errorWasNil }


enum Result<FulfilledValue> {
    case fulfilled(FulfilledValue)
    case rejected(Error)
    
    init( of body: () throws -> FulfilledValue ) {
        do { self = try .fulfilled( body() ) }
        catch { self = .rejected ( error ) }
    }
    
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



// A BasicPromise handles any type of Outcome, and doesn't help deal with about errors.
private var defaultQ: DispatchQueue = .main

class BasicPromise<Outcome> {
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
    
    init() {}
    
    
    
    func fulfill(_ outcome: Outcome) -> Void
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
    
    
    func then(
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
    
    
    func then<NewOutcome>(
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
    
    
    func then<NewOutcome>(
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






func requestCity(of user: String) -> BasicPromise<Result<City>>
{
    let promise = BasicPromise<Result<City>>()
    // Simulate the asynchrony of a web request
    DispatchQueue.global(qos: .userInitiated).async {
        switch user {
        case "Rob":
            promise.fulfill(.fulfilled(.Austin))
        case "David":
            promise.fulfill(.fulfilled(.Mountain_View))
        case "John":
            promise.fulfill(.fulfilled(.Podunk))
        default:
            promise.fulfill(.rejected(Errors.unknownUser))
        }
    }
    return promise
}
func requestTemperature(in city: City)
    -> BasicPromise<Result<Int>>
{
    let promise = BasicPromise<Result<Int>>()
    // Simulate the asynchrony of a web request
    DispatchQueue.global(qos: .userInitiated).async {
        switch city {
        case .Austin:        promise.fulfill(.fulfilled(90))
        case .Mountain_View: promise.fulfill(.fulfilled(70))
        default:             promise.fulfill(.rejected(Errors.unknownCity))
        }
    }
    return promise
}


func printCityOrErrorUsingBasicPromise(for user: String) {
    let myQ = DispatchQueue.global(qos: .userInitiated)
    requestCity(of: user)
        .then(on: myQ) {
            cityResult -> BasicPromise<Result<Int>> in
            switch cityResult {
            case let .rejected(err):
                let bp = BasicPromise<Result<Int>>()
                bp.fulfill(.rejected(err))
                return bp
            case let .fulfilled(city):
                return requestTemperature(in: city)
            }
        }
        .then(on: myQ) {
            $0.then { print( "Temperature for", user, "is", $0) }
            $0.catch { print( "No temperature for", user, "error:", $0) }
    }
}

printCityOrErrorUsingBasicPromise(for: "Rob")
printCityOrErrorUsingBasicPromise(for: "John")
printCityOrErrorUsingBasicPromise(for: "Jane")





func firstly<FulfilledValue>(
    execute body: () throws -> Promise<FulfilledValue>
    ) -> Promise<FulfilledValue>
{
    do {
        return try body()
    } catch {
        return Promise(error: error)
    }
}




struct Promise<FulfilledValue> {
    fileprivate let basicPromise: BasicPromise< Result< FulfilledValue > >
}


extension Promise {
    fileprivate init(
        basedOn basis: BasicPromise< Result<FulfilledValue> > = BasicPromise()
        )
    {
        basicPromise = basis
    }
    
    // Following PromiseKit's convention, the initializer and static method also supply the fulfill and reject routines for the created Promise:
     init(
        resolvers: (
        _ fulfill: @escaping (FulfilledValue ) -> Void,
        _ reject:  @escaping (Error          ) -> Void
        ) throws -> Void
        )
    {
        self.init()
        func fulfillBasic(_ r: Result< FulfilledValue >) {
            basicPromise.fulfill(r)
        }
        do {
            try resolvers(
                { fulfillBasic(.fulfilled($0)) },
                { fulfillBasic(.rejected($0)) }
            )
        }
        catch {
            fulfillBasic(.rejected(error))
        }
    }
    
    typealias PendingTuple = (promise: Promise, fulfill: (FulfilledValue) -> Void, reject: (Error) -> Void)
    
    static func pending() -> PendingTuple {
        var fulfill: ((FulfilledValue) -> Void)!
        var reject:  ((Error) -> Void)!
        let promise = Promise { fulfill = $0; reject = $1 }
        return (promise, fulfill, reject)
    }
    
    init(value: FulfilledValue) {
        self.init {
            fulfill, reject in
            fulfill(value)
        }
    }
    init(error: Error) {
        self.init {
            fulfill, reject in
            reject(error)
        }
    }
    
}

// Two implementations of then are needed, depending upon whether the body is synchronous or asynchronous:
extension Promise {
    
    func then<NewFulfilledValue>(
        on q: DispatchQueue  = BasicPromise<Void>.defaultQueue,
        execute body: @escaping (FulfilledValue) throws -> NewFulfilledValue
        ) -> Promise<NewFulfilledValue>
    {
        let newBasicPromise = basicPromise.then(on: q) {
            $0.then(execute: body)
        }
        return Promise<NewFulfilledValue>(basedOn: newBasicPromise)
    }
    
    
    func then<NewFulfilledValue>(
        on q: DispatchQueue  = BasicPromise<Void>.defaultQueue,
        execute body: @escaping (FulfilledValue) throws -> Promise<NewFulfilledValue>
        ) -> Promise<NewFulfilledValue>
    {
        return Promise<NewFulfilledValue> {
            fulfill, reject in
            _ = basicPromise.then(on: q) {
                result -> Void in
                _ = result
                    .catch { (e: Error) -> Void in reject(e) }
                    .then  {
                        do    {
                            try body($0)
                                .then( on: q, execute: fulfill)
                                .catch(on: q, execute: reject )
                        }
                        catch { reject(error) }
                }
            }
        }
    }
}

// Catch and recover handle errors. The latter allows an error to be turned back into success:
extension Promise {
    @discardableResult
    func `catch`(
        on q: DispatchQueue  = BasicPromise<Void>.defaultQueue,
        execute body: @escaping (Error) -> Void
        ) -> Promise
    {
        let newBasicPromise = basicPromise.then(on: q) {
            outcome -> Result<FulfilledValue>  in
            outcome.catch(execute: body)
            return outcome
        }
        return Promise(basedOn: newBasicPromise)
    }
    
    func recover(
        on q: DispatchQueue  = BasicPromise<Void>.defaultQueue,
        execute body: @escaping (Error) throws -> Promise
        ) -> Promise
    {
        let (newPromise, fulfill, reject) = Promise.pending()
        _ = basicPromise.then(on: q) {
            switch $0 {
            case let .fulfilled(r): fulfill(r)
            case let .rejected(e):
                do {
                    _ = try body(e)
                        .then (on: q, execute: fulfill)
                        .catch(on: q, execute: reject )
                }
                catch { reject(error) }
            }
        }
        return newPromise
    }
    
    func recover(
        on q: DispatchQueue  = BasicPromise<Void>.defaultQueue,
        execute body: @escaping (Error) throws -> FulfilledValue
        ) -> Promise
    {
        let (newPromise, fulfill, reject) = Promise.pending()
        _ = basicPromise.then(on: q) {
            $0
                .recover( execute: body    )
                .then   ( execute: fulfill )
                .catch  ( execute: reject  )
        }
        return newPromise
    }
}

// Tap and always provide points to observe a chain of results no matter whether things are failing or succeeding:
extension Promise {
    func tap(
        on q: DispatchQueue  = BasicPromise<Void>.defaultQueue,
        execute body: @escaping (Result<FulfilledValue>) -> Void
        ) -> Promise
    {
        let newBasicPromise = basicPromise.then(on: q) {
            outcome -> Result<FulfilledValue> in
            body(outcome)
            return outcome
        }
        return Promise(basedOn: newBasicPromise)
    }
    
    func always(
        on q: DispatchQueue  = BasicPromise<Void>.defaultQueue,
        execute body: @escaping () -> Void
        )
        -> Promise
    {
        return tap(on: q) { _ in body() }
    }
}


func requestCity(of user: String) -> Promise<City> {
    // obtain a new Promise & fulfill & reject functions
    let (promise, fulfill, reject) = Promise<City>.pending()
    DispatchQueue.global(qos: .userInitiated).async {
        switch user {
        case "Rob":   fulfill(.Austin)
        case "David": fulfill(.Mountain_View)
        case "John":  fulfill(.Podunk)
        default:      reject(Errors.unknownUser)
        }
    }
    return promise
}

func requestTemperature(in city: City) -> Promise<Int> {
    // obtain a new Promise & fulfill & reject functions
    let (promise, fulfill, reject) = Promise<Int>.pending()
    DispatchQueue.global(qos: .userInitiated).async {
        switch city {
        case .Austin:        fulfill(90)
        case .Mountain_View: fulfill(70)
        default:             reject(Errors.unknownCity)
        }
    }
    return promise
}


func printCityOrError(for user: String) {
    let myQ = DispatchQueue.global(qos: .userInitiated)
    requestCity(of: user)
        .then (on: myQ) { requestTemperature(in: $0 ) }
        .then (on: myQ) { print("Temperature for", user, "is", $0 ) }
        .catch(on: myQ) { print("No temperature for", user, "error:", $0 ) }
}

printCityOrError(for: "David")
printCityOrError(for: "John")
printCityOrError(for: "Linda")