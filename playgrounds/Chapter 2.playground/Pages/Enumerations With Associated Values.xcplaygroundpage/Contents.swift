//: [Previous](@previous)
//: # Enumerations with assocated values
import Foundation
import UIKit

// Work in progress; using a spin hack instead for now.
// import PlaygroundSupport

let someURL = URL(string: "http://ibm.com")! // needed for examples below
//: ---
//: A simple enumeration for comparison:
enum HTTP_Request_Kind {
    case get, post // other request types omitted for brevity
}
//: ## HTTP requests built from structures and protocols:

protocol HTTP_Request_Protocol {
    static func == (a: Self, b: Self) -> Bool
}
struct Get:  HTTP_Request_Protocol {
    let destination: URL
    let headerFields: [String: String]
    static func == (a: Get, b: Get) -> Bool {
        return a.destination == b.destination  && a.headerFields == b.headerFields
    }
}
struct Post: HTTP_Request_Protocol {
    let destination: URL
    let headerFields: [String: String]
    let data: Data
    static func == (a: Post, b: Post) -> Bool {
        return a.destination == b.destination  && a.headerFields == b.headerFields  &&  a.data == b.data
    }
}
//: The problem with this approach is that you cannot use a generic protocol as a type:
// Next two statements are illegal; try uncommenting to see the error
// let someRequest: HTTP_Request_Protocol = Get(url: someURL, headerFields: [:]) // ILLEGAL
// let requests: [HTTP_Request_Protocol] = [] // also ILLEGAL

//: - - -
//: ## Solution: HTTP requests built using an enumeration with associated values

enum HTTP_Request {
    case get  ( destination: URL, headerFields: [String: String] )
    case post ( destination: URL, headerFields: [String: String], data: Data )
    // also delete, put, & patch
    
    var destinationAndHeaders: (URL, [String: String]) {
        switch self {
        case let .get(d, h), let .post(d, h, _):
            return (d, h)
        }
    }
    
    static var hackToAvoidOptimizationWhileSpinning = 0.0
    
    func send(
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
        ) {
        let (destination, headers) = destinationAndHeaders
        let s = URLSession(configuration: .default)
        var r = URLRequest(url: destination)
        for (name, value) in headers {
            r.setValue( value, forHTTPHeaderField: name )
        }
        var noResponseYet = true
        func spinPlaygroundTillResponse () {
            while noResponseYet {
                HTTP_Request.hackToAvoidOptimizationWhileSpinning += 1.0
            }
        }
        // PlaygroundPage.current.needsIndefiniteExecution = true
        let completionHandlerForPlayground: (Data?, URLResponse?, Error?) -> Void = {
            completionHandler($0, $1, $2)
            // PlaygroundPage.current.needsIndefiniteExecution = false
            noResponseYet = false
        }
        switch self {
        case .get: // also delete
            s.dataTask(
                with: r,
                completionHandler: completionHandlerForPlayground )
                .resume()
        case .post(_, _, let data): // also put, patch
            s.uploadTask(
                with: r,
                from: data,
                completionHandler: completionHandlerForPlayground )
                .resume()
        }
        spinPlaygroundTillResponse()
    }
    static func == ( lhs: HTTP_Request, rhs: HTTP_Request )
        -> Bool
    {
        switch (lhs, rhs) {
        case let (.get(u1, h1), .get(u2, h2))
            where u1 == u2 && h1 == h2:
            return true
        case let (.post(u1, h1, d1), .post (u2, h2, d2))
            where u1 == u2 && h1 == h2 && d1 == d2:
            return true
        // also delete, put & patch
        default:
            return false
        }
    }
}
//: - - -
//: Create a request, send it, and show the response:
let request2 = HTTP_Request.get(destination: someURL, headerFields: [:])

request2.send {
    data, response, error in
    printForPlayground("error", error ?? "none", "response", response ?? "none", "data", data.flatMap {String(data: $0, encoding: .utf8)} ?? "none")
}
whatWasPrinted
//: - - -
//: Demonstration of comparing two requests
let request3 = HTTP_Request.post(destination: someURL, headerFields: [:], data: Data())

request2 == request3
//: - - -
//: Or an array of hetergenous requests:
let requests: [HTTP_Request] = [request2, request3]
//: [Next](@next)
