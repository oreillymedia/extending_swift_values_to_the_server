//: [Previous](@previous)

import Foundation

//: A simple enumeration:

enum HTTP_Request_Kind {
    case get, post // other request types omitted for brevity
}

let someURL = URL(string: "http://ibm.com")! // needed for examples below


//: HTTP requests built with a generic protocol and structures:

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

//: Next two statements are illegal; try uncommenting to see the error
// let someRequest: HTTP_Request_Protocol = Get(url: someURL, headerFields: [:]) // ILLEGAL
// let requests: [HTTP_Request_Protocol] = [] // also ILLEGAL


//: HTTP requests built with an enumeration with associated values:

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
    
    func send(
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
        ) {
        let (destination, headers) = destinationAndHeaders
        let s = URLSession(configuration: .default)
        var r = URLRequest(url: destination)
        for (name, value) in headers {
            r.setValue( value, forHTTPHeaderField: name )
        }
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

let request2 = HTTP_Request.get(destination: someURL, headerFields: [:])
var keepSpinning = true
DispatchQueue.global(qos: .userInitiated).async {
    
    request2.send {
        data, response, error in
        print("error", error ?? "none", "response", response ?? "none", "data", data.flatMap {String(data: $0, encoding: .utf8)} ?? "none")
        keepSpinning = false
    }
}
while keepSpinning {}

let request3 = HTTP_Request.post(destination: someURL, headerFields: [:], data: Data())

request2 == request3
//: [Next](@next)
