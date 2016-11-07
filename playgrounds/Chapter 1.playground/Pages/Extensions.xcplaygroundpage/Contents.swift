//: [Previous](@previous)
//: # Extensions
//: ## Example definitions
import Foundation

let a = 144
let b =  24
let c = 100
let d = 20
//: - -
//: ## Without extensions
class City1 {
    let name: String
    init(name: String) { self.name = name }
    
    func lookupCountry() -> String {
        switch name {
        case "Austin": return "United States"
        case "Quebec": return "Canada"
        default:       return "Undiscovered"
        }
    }
}
class State1 {
    let name: String
    init(name: String) { self.name = name }
    
    func lookupCountry() -> String {
        switch name {
        case "Texas":  return "United States"
        default:       return "Undiscovered"
        }
    }
}
//: - - -
//: With extensions
private extension Int {
    var squared: Int { return self * self }
}
(a/b).squared + (c/d).squared
//: - - -
//: ## Extensions let you group the lookup functions together:
class City2 {
    let name: String
    init(name: String) { self.name = name }
}
class State2 {
    let name: String
    init(name: String) { self.name = name }
}

extension City2  {
    func lookupCountry() -> String {
        switch name {
        case "Austin": return "US"
        case "London": return "UK"
        default:       return "Undiscovered"
        }
    }
}
extension State2 {
    func lookupCountry() -> String {
        switch name {
        case "Texas":  return "United States"
        default:       return "Undiscovered"
        }
    }
}

City2 (name: "Austin").lookupCountry()
State2(name: "Texas" ).lookupCountry()
