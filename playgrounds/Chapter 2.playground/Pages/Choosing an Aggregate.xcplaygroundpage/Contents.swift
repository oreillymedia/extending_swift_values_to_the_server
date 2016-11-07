//: [Previous](@previous)
//: # Choosing an Aggregate
import Foundation
//: ## Classes provide shared state
//: Example: modeling a user as a class provides shared state for the location
class User {
    let name: String // the User’s name can not change
    var location: String // the User’s location can change
    init( name: String, location: String ) {
        self.name = name
        self.location = location
    }
}
//: Changing the location in reference1 affects reference2:
let reference1 = User(name: "Joe", location: "Akron")
let reference2 = reference1

reference2.location

reference1.location = "Dayton"

reference2.location // was Akron, now is Dayton