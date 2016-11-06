import Foundation

public enum Result<FulfilledValue> {
    case fulfilled(FulfilledValue)
    case rejected(Error)
    
    public init( of body: () throws -> FulfilledValue ) {
        do { self = try .fulfilled( body() ) }
        catch { self = .rejected ( error ) }
    }
    
}

//: But it's more reusable to put the switch inside of Result in a member function:

extension Result {
    public func then <NewFulfilledValue> (
        execute body:
        (FulfilledValue) throws -> NewFulfilledValue
        ) -> Result<NewFulfilledValue>
    {
        switch self {
        case .rejected (let e):
            return .rejected(e)
        case .fulfilled(let r):
            do { return try .fulfilled( body(r) ) }
            catch { return .rejected ( error ) }
        }
    }
    
}


//: Adding in error handling to Result;

extension Result {
    public func recover(execute body: (Error) throws -> FulfilledValue)
        -> Result
    {
        switch self {
        case .fulfilled:
            return self
        case .rejected(let e):
            do    { return try .fulfilled( body(e)) }
            catch { return .rejected( error ) }
        }
    }
    public func `catch`(execute body: (Error) -> Void)
        -> Result
    {
        switch self {
        case .fulfilled: break
        case .rejected(let e): body(e)
        }
        return self
    }
}
