//
//  Chapter 2 code snippets.swift
//  
//
//  Created by David Ungar on 11/2/16.
//
//

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
    let city: String
    var startTime: Date? = nil // an optional Date
    init(city: String) {
        self.city = city
    }
}

// Code 2.16.1

request.startTime = Date.now
sendToDB(request: request,  callback: receivedResponse)

// Code 2.16.2

func receivedResponse(temperature: Int) {
    let dbTime = Date.now.timeIntervalSince( request.startTime! )
    print("It took", dbTime,
          "seconds to discover that the temperature in",
          request.city, "is", temperature)
}

// Code 2.16.3

func sendToDB(
    request: TemperatureRequestClass,
    callback: (Int) -> Void
) {
    … // Do lots of slow work to prepare to connection
    request.startTime = Date.now //The BUG!
    … // Send the request on the prepared connection
}

// Code 2.17.1

struct TemperatureRequestStruct {
    let city: String
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

