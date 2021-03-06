public enum City { case Austin, Mountain_View, Podunk }

//: basicGetCity (synchronously)

//: In real (non-pedagogical code), basicGetCity would be a static member of City

public func basicGetCity(of user: String) throws -> City {
    switch user {
    case "Rob":    return .Austin
    case "David":  return .Mountain_View
    case "John":   return .Podunk
    default: throw Errors.unknownUser
    }
}


//: In real code, there would be a Temperature structure and this would be a static member.

public func basicGetTemperature(in city: City) throws -> Int {
    switch city {
    case .Austin:        return 90
    case .Mountain_View: return 70
    default: throw Errors.unknownCity
    }
}

public func printForPlayground( city: City, for user: String) {
    printForPlayground( "\(user)'s city is \(city)")
}

public func printForPlayground( temperature: Int, for user: String) {
    printForPlayground( "temperature in \(user)'s city is \(temperature)")
}

public func printForPlayground( error: Error, for user: String) {
    printForPlayground( "error for \(user) is \(error)" )
}
