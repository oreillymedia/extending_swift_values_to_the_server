//
//  Chapter 2 code snippets.swift
//  
//
//  Created by David Ungar on 11/2/16.
//
//

//: This file contains the code examples from Chapter 1 of Extending Swift Values To The Server
//: Some of this code *does not compile,* because it is intended to instruct.
//: We will put playgrounds on this repository containing code youc can run.
//: The numbering scheme is <Chapter>.<Page>.<Sequence within page>
//: Rather than rearrange to exploit the wider margins here, I have kept the line breaks and indentation used in the book.


// Code 2.13.1

let headerFields: [String: String] = …



// Code 2.14.1

let contentType = headerFields["Content-Type"]



// Code 2.14.2

if contentType.hasPrefix("text") // ILLEGAL



// Code 2.14.3

let contentType: String
if let ct = headerFields["Content-Type"] {
    contentType = ct
}
else {
    contentType = "no contentType"
}



// Code 2.14.4

let contentType = headerFields["Content-Type"] ?? "none"



// Code 2.15.1

class TemperatureRequestClass {
    let city:      String
    var startTime: Date? = nil // an optional Date
    
    init(city: String) {
        self.city = city
    }
}



// Code 2.15.2

let request = TemperatureRequestClass(city: "Paris")


// Code 2.16.1

request.startTime = Date.now
sendToDB(request: request,  callback: receivedResponse)



// Code 2.16.2

func receivedResponse(temperature: Int) {
    let dbTime = Date.now.timeIntervalSince(request.startTime!)
    print("It took", dbTime,
          "seconds to discover that the temperature in",
          request.city, "is", temperature)
}



// Code 2.16.3

func sendToDB(
    request:  TemperatureRequestClass,
    callback: (Int) -> Void
) {
    … // Do lots of slow work to prepare to connection
    request.startTime = Date.now //The BUG!
    … // Send the request on the prepared connection
}



// Code 2.17.1

struct TemperatureRequestStruct {
    let city:      String
    var startTime: Date? = nil
    
    init(city: String) {
        self.city = city
    }
}



// Code 2.17.2

var request = TemperatureRequestStruct(city: "Paris")



// Code 2.17.3

func sendToDB(
    request:  TemperatureRequestStruct,
    callback: (Int) -> Void
) {
    … // Do lots of slow work to prepare to connection
    request.startTime = Date.now // ILLEGAL: will not compile!!
    … // Send the request on the prepared connection
}



// Code 2.17.4

var mutableRequest = request
mutableRequest.startTime = Date.now



// Code 2.18.1

struct TemperatureRequestStruct {
    …
    var startTime: Date? = nil
    mutating func clearStartTime() { startTime = nil }
}



// Code 2.19.1

let request1 = TemperatureRequestStruct(city: "Paris")
var request2 = request1   // makes a copy because is a struct

request1.clearStartTime() // ILLEGAL: cannot mutate a let
request2.clearStartTime() // OK, but does not change request1



// Code 2.19.2

struct TemperatureRequest {
    let city:      String
    let state:     String
    var startTime: Date? = nil

    init(city: String, state: String) {
        self.city  = city
        self.state = state
    }
    var cityAndState: String { return city + ", " + state }
}
struct OzoneRequest {
    let city:       String
    let state:      String
    var startTime:  Date? = nil
    
    init(city: String, state: String) {
        self.city  = city
        self.state = state
    }
    var cityAndState: String { return city + ", " + state }
}



// Code 2.20.1

protocol Request {
    var city:  String {get}
    var state: String {get}
}
extension Request {
    var cityAndState: String { return city + ", " + state }
}
struct TemperatureRequest: Request {
    let city:       String
    let state:      String
    var startTime:  Date? = nil
    
    init(city: String, state: String) {
        self.city  = city
        self.state = state
    }
}
struct OzoneRequest: Request {
    let city:       String
    let state:      String
    var startTime:  Date? = nil

    init(city: String, state: String) {
        self.city  = city
        self.state = state
    }
}



// Code 2.22.1

enum HTTP_Request_Kind {
    case get, post // other request types omitted for brevity
}



// Code 2.22.2

protocol HTTP_Request {
    static func == (a: Self, b: Self) -> Bool
}
struct Get:  HTTP_Request {...}
struct Post: HTTP_Request {...}
let someRequest: HTTP_Request = ... // ILLEGAL
let requests: [HTTP_Request] = ... // also ILLEGAL




// Code 2.22.3

enum HTTP_Request {
    case get  ( destination:  URL,
        headerFields: [String: String] )
    case post ( destination: URL,
        headerFields: [String: String],
        data: Data )
    // also delete, put, & patch
    
    func send(
        completionHandler:
        @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
        let s = URLSession()
        let r = URLRequest(url: someURL)
        switch self {
        case .get: // also delete
            s.dataTask(
                with: r,
                completionHandler: completionHandler )
             .resume()
        case .post(_, _, let data): // also put, patch
            s.uploadTask(
                with: r,
                from: data,
                completionHandler: completionHandler )
             .resume()
        }
    }
    static func  ==  ( lhs: HTTP_Request,  rhs: HTTP_Request )
        -> Bool
    {
        switch (lhs, rhs) {
        case let (.get(u1, h1), .get(u2, h2))
            where  u1 == u2  &&  h1 == h2:
            return true
        case let (.post(u1, h1, d1), .post (u2, h2, d2))
            where  u1 == u2  &&  h1 == h2  &&  d1 == d2:
            return true
        // also delete, put & patch
        default:
            return false
        }
    }
}



// Code 2.23.1

let requests: [HTTP_Request] = [
    .get (destination: url1, headerFields: [:]),
    .post(destination: url2, headerFields: [:], data: someData)
]



// Code 2.23.2

if  aRequest == anotherRequest




// Code 2.26.1

class User {
    let name:     String  // the User’s name can not change
    var location: String  // the User’s location can change
    
    init( name: String,  location: String ) {
        self.name     = name
        self.location = location
    }
}
