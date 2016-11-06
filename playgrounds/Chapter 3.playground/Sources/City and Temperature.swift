public enum City { case Austin, Mountain_View, Podunk }

//: basicGetCity (synchronously)

public func basicGetCity(of user: String) throws -> City {
    switch user {
    case "Rob":    return .Austin
    case "David":  return .Mountain_View
    case "John":   return .Podunk
    default: throw Errors.unknownUser
    }
}

public func basicGetTemperature(in city: City) throws -> Int {
    switch city {
    case .Austin:        return 90
    case .Mountain_View: return 70
    default: throw Errors.unknownCity
    }
}
