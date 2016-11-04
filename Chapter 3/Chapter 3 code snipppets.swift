//
//  Chapter 3 snipppets.swift
//  
//
//  Created by David Ungar on 11/2/16.
//
//


// Code 3.31.1

enum City { case Austin, Mountain_View, Podunk }
enum Errors: String, Error { case unknownUser, unknownCity }

func getCity(of user: String) throws -> City {
    switch user {
    case "Rob":   return .Austin
    case "David": return .Mountain_View
    case "John":  return .Podunk
    default:      throw Errors.unknownUser
    }
}
func getTemperature(in city: City) throws -> Int {...}


// Code 3.31.2

do {
    let city        = try getCity(of: user)
    let temperature = try getTemperature(in: city)
    print("temperature:", temperature)
}
catch { print("error:", error) }


// Code 3.32.1

enum Result<FulfilledValue> {
    case fulfilled(FulfilledValue)
    case rejected(Error)
}


// Code 3.32.2

extension Result {
    init( of body:  () throws -> FulfilledValue  ) {
        do    { self = try .fulfilled( body() ) }
        catch { self =     .rejected ( error  ) }
    }
}




// Code 3.32.3

let aResult = Result<City> { try getCity(of: "David") }




// Code 3.32.4

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


// Code 3.32.5

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
            do    { return try .fulfilled( body(r) ) }
            catch { return     .rejected ( error   ) }
        }
    }
}


// Code 3.33.1

Result    { try getCity(of: user)      }
    .then { try getTemperature(in: $0) }
    .then { print("temperature:",  $0) }



// Code 3.33.2

extension Result {
    func recover(execute body: (Error) throws -> FulfilledValue)
        -> Result
    {
        switch self {
        case .fulfilled:
            return self
        case .rejected(let e):
            do    { return try .fulfilled( body(e)) }
            catch { return     .rejected(  error  ) }
        }
    }
    func `catch`(execute body: (Error) -> Void)
        -> Result
    {
        switch self {
        case .fulfilled:       break
        case .rejected(let e): body(e)
        }
        return self
    }
}



// Code 3.34.1

// [NOTE: TO O'REILLY: 'catch' should be black below

// Type inference allows omission of <City> after Result below:
Result       { try getCity(of: user)      }
    .recover { _ in .Austin               }
    .then    { try getTemperature(in: $0) }
    .catch   { print("error:",        $0) }
    .then    { print("temperature:",  $0) }


// Code 3.35.1

func requestCity(
    of user: String,
    _ callback: @escaping (City?, Error?) -> Void
) {
    DispatchQueue.global(qos: .userInitiated).async {
        switch user {
        case "Rob":   callback(.Austin,        nil)
        case "David": callback(.Mountain_View, nil)
        case "John":  callback(.Podunk,        nil)
        default:      callback(nil, Errors.unknownUser)
        }
    }
}
func requestTemperature(
    in city: City,
    _ callback: @escaping (Int?, Error?)-> Void
) {...}



// Code 3.35.2

requestCity(of: user) {
    // Outer callback:
    if let city = $0 {
        requestTemperature(in: city) {
            // Inner callback:
            if let temperature = $0 {
                print("temperature:", temperature)
            }
            else {
                print("error:", $1)
            }
        }
    }
    else {
        print("error:", $1)
    }
}


// Code 3.37.1

let aBasicPromise = BasicPromise<Int>()


// Code 3.37.2

aBasicPromise.fulfill(17)


// Code 3.37.3

aBasicPromise
    .then {
        // asynchronous request returning a BasicPromise
    }
    .then { print($0) }


// Code 3.37.4

func then(
    on q: DispatchQueue = BasicPromise.defaultQueue,
    execute consumer:
        @escaping (Outcome)
        -> Void
)



// Code 3.38.1

func then<NewOutcome> (
    on q: DispatchQueue = BasicPromise.defaultQ,
    execute transformer:
        @escaping (Outcome)
        -> NewOutcome
) -> BasicPromise<NewOutcome>


// Code 3.38.2

func then<NewOutcome>(
    on q: DispatchQueue = BasicPromise.defaultQ,
    execute asyncTransformer:
        @escaping (Outcome)
        -> BasicPromise<NewOutcome>
) -> BasicPromise<NewOutcome>


// Code 3.38.3

func requestCityIgnoringErrors(
    of user: String,
    @escaping callback: (City) -> Void
) {
    // Simulate the asynchrony of a web request
    DispatchQueue.global(qos: .userInitiated).async {
        switch user {
        case "Rob":   callback(.Austin)
        case "David": callback(.Mountain_View)
        case "John":  callback(.Podunk)
        default:      abort()
        }
    }
}



// Code 3.39.1

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
{…}



// Code 3.39.2

requestCityIgnoringErrors(of: user)
    .then { requestTemperatureIgnoringErrors(in: $0) }
    .then { print("Temperature is", $0) }


// Code 3.40.1

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
{…}


// Code 3.40.2

//[NOTE TO O'REILLY 'catch' below should be black]

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
        $0.then  { print( "Temperature is", $0) }
        $0.catch { print( "error: ", $0) }
}


// Code 3.41.1

struct Promise<FulfilledValue> {
    let basicPromise: BasicPromise<Result<FulfilledValue>>
}


// Code 3.41.2

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


// Code 3.41.3

//[NOTE TO O'REILLY 'catch' below should be black]

requestCity(of: user)
    .then (on: myQ) { requestTemperature(in:  $0 ) }
    .then (on: myQ) { print("Temperature is", $0 ) }
    .catch(on: myQ) { print("error:",         $0 ) }


// Code 3.42.1

//[NOTE TO O'REILLY 'catch' below should be black]

Result { try getCity(of: user) }
    .then  { try getTemperature(in: $0) }
    .then  { print("temperature:",  $0) }
    .catch { print("error:",        $0) }

