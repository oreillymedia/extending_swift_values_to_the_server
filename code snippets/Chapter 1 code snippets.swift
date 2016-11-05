//
//  Chapter 1 code snippets.swift
//  


//: This file contains the code examples from Chapter 1 of Extending Swift Values To The Server
//: Some of this code *does not compile,* because it is intended to instruct.
//: We will put playgrounds on this repository containing code youc can run.
//: The numbering scheme is <Chapter>.<Page>.<Sequence within page>
//: Rather than rearrange to exploit the wider margins here, I have kept the line breaks and indentation used in the book.


// Code 1.2.1

let aHost = "someMachine.com"
aHost = "anotherMachine.com" // ILLEGAL: can't change a constant



// Code 1.2.2

var aPath = "something"
aPath = "myDatabase" // OK



// Code 1.2.3

func combine(host: String, withPath path: String) -> String {
    return host + "/" + path
}



// Code 1.2.4

// returns "someMachine.com/myDatabase"
combine(host: aHost, withPath: aPath)



// Code 1.3.1

enum Validity { case valid, invalid }



// Code 1.3.2

enum StatusCode: Int {
    case ok = 200
    case created = 201
    … // more cases go here
    case badRequest = 400
    case unauthorized = 401
}



// Code 1.3.3

func printRealValue(of e: StatusCode) {
    print ("real value is", e.rawValue)
}



// Code 1.3.4

func lookup(user: String) -> (String, Int) {
    // compute n and sn
    return (n, sn)
}



// Code 1.4.1

let userInfo = lookup(user: "Washington")
print( "name:", userInfo.0, "serialNumber:", userInfo.1 )



// Code 1.4.2

let (name, serialNumber) = lookup(user: "Adams")
print( "name:", name, "serialNumber:", serialNumber )



// Code 1.4.3

func lookup(user: String)
    -> (name: String, serialNumber: Int)
{
    // compute n and sn
    return (n, sn)
}



// Code 1.4.4

let userInfo = lookup(user: "Washington")
print("name:",         userInfo.name,
      "serialNumber:", userInfo.serialNumber)



// Code 1.4.5

let second = lookup(user: "Adams")
second.name = "Gomez Adams" // ILLEGAL: u is a let
var anotherSecond = lookup(user: "Adams")
anotherSecond.name = "Gomez Adams" // Legal: x is a var
print(anotherSecond.name) // prints Gomez Adams



// Code 1.4.6

var first = lookup(user: "Washington")
var anotherFirst = first
first.name        // returns "George Washington"
anotherFirst.name // returns "George Washington" as expected
first.name = "George Jefferson"
first.name        // was changed, so returns "George Jefferson"
anotherFirst.name // returns "George Washington" because
                  // anotherFirst is an unchanged copy



// Code 1.5.1

enum  PegShape { case roundPeg,  squarePeg }
enum HoleShape { case roundHole, squareHole, triangularHole }

func howDoes( _ peg: PegShape,  fitInto hole: HoleShape )
    -> String
{
    switch (peg, hole) { // switches on a tuple
    case (.roundPeg, .roundHole):
        return "fits any orientation"
    case (.squarePeg, .squareHole):
        return "fits four ways"
    default:
        return "does not fit"
    }
}



// Code 1.5.2

9.0 |> sqrt // returns 3



// Code 1.5.3

send(compress(getImage()))



// Code 1.5.4

getImage() |> compress |> send



// Code 1.6.1

precedencegroup LeftFunctionalApply {
    associativity: left
    higherThan: AssignmentPrecedence
    lowerThan: TernaryPrecedence
}
infix operator |> : LeftFunctionalApply



// Code 1.6.2

func |> <In, Out> ( lhs: In,  rhs: (In) throws -> Out )
    rethrows -> Out {
    return try rhs(lhs)
}



// Code 1.7.1

func makeChannel()
    -> ( send: (String) -> Void,  receive: () -> String )
{
    var message: String = ""
    return (
        send:    { (s: String) -> Void   in message = s    },
        receive: { (_: Void  ) -> String in return message }
    )
}



// Code 1.7.2

protocol HTTP_Request_Protocol {
    var url: URL              {get}
    var requestString: String {get}
}



// Code 1.7.3

class Abstract_HTTP_Request {
    let url: URL // A constant instance variable
    init(url: URL) {  self.url = url  }
}
class Get_HTTP_Request:
    Abstract_HTTP_Request, HTTP_Request_Protocol
{
    var requestString: String { return "GET" }
}
class Post_HTTP_Request:
    Abstract_HTTP_Request, HTTP_Request_Protocol
{
    var requestString: String { return "POST" }
    var data: String
    init( url: URL,  data: String ) {
        self.data = data
        super.init(url: url)
    }
}



// Code 1.8.1

let aRequest: HTTP_Request_Protocol
    = Get_HTTP_Request(url: … /* some URL */)
aRequest.requestString // returns "GET"



// Code 1.8.2

struct TemperatureResponse {
    let city:   String
    let answer: Int
}
struct FavoriteFoodResponse {
    let city:   String
    let answer: String
}



// Code 1.9.1

protocol ResponseProtocol {
    associatedtype Answer
    var city:   String {get}
    var answer: Answer {get}
}
struct TemperatureResponse:  ResponseProtocol {
    let city:   String
    let answer: Int
}
struct FavoriteFoodResponse: ResponseProtocol {
    let city:   String
    let answer: String
}



// Code 1.9.2

var someResponse: ResponseProtocol // ILLEGAL



// Code 1.9.3

func handleResponse <SomeResponseType: ResponseProtocol>
    ( response: SomeResponseType )  { … }



// Code 1.10.1

private extension Int {
    var squared: Int { return self * self }
}



// Code 1.10.2

class City {
    let name: String
    init(name: String)  { self.name = name }
    func lookupCountry() -> String { … }
}
class State {
    let name: String
    init(name: String)  { self.name = name }
    func lookupCountry() -> String { … }
}


 1.11.1

extension City  { func lookupCountry() -> String { … } }
extension State { func lookupCountry() -> String { … } }
