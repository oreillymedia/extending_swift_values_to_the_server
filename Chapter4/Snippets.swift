// Code 4-1
precedencegroup LeftFunctionalApply {
    associativity: left
    higherThan: AssignmentPrecedence
    lowerThan: TernaryPrecedence
}
infix operator |> : LeftFunctionalApply

@discardableResult
public func |> <A, B> (
    x: A, f: (A) throws -> B
) rethrows -> B {
    return try f(x)
}

// Code 4-2
import XCTest
@testable import Pipes
func double(a: Int) -> Int { return 2 * a }
class PipesTests: XCTestCase {
    func testDouble() { XCTAssertEqual(6 |> double, 12) }
}

// Code 4-3
extension PipesTests {
    static var allTests : [
        ( String, (PipesTests) -> () throws -> Void )
    ]
    {
        return [
            ("testDouble", testDouble)
        ]
    }
}

// Code 4-4
import PackageDescription
let package = Package(
    name: "MyWebApp",
    targets: [
        Target(name: "A", dependencies: [.Target(name: "B")]),
        Target(name: "B", dependencies: [.Target(name: "C")]),
        Target(name: "C")]
)

// Code 4-5
let package = Package(
    name: "CSQLite",
    providers: [
        .Brew("sqlite"),
        .Apt("libsqlite3-dev")
    ]
)
