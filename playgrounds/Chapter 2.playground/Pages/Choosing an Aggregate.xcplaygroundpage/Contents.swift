//: [Previous](@previous)

import Foundation

class User {
    let name: String // the User’s name can not change
    var location: String // the User’s location can change
    init( name: String, location: String ) {
        self.name = name
        self.location = location
    }
}

let reference1 = User(name: "Joe", location: "Akron")
let reference2 = reference1

reference2.location

reference1.location = "Dayton"

reference2.location


//: [Next](@next)
