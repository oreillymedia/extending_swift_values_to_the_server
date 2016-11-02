/**
 Swift Package Manager
 */

/**
 4.3 Importing a Library in your Project
 */

// Code 4.3.1
import PackageDescription
let package = Package(
    name: "MyProject",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Pipes.git",
                 majorVersion: 0, minor: 1),
        ]
)

// Code 4.3.2
import Pipes

func sayHello(str: String) -> String {
    return "Hello, \(str)"
}

"Alice" |> sayHello |> print


/**
 4.5 Creating your Own Library
 */

// Code 4.5.1
precedencegroup LeftFunctionalApply {
    associativity: left
    higherThan: AssignmentPrecedence
    lowerThan: TernaryPrecedence
}

infix operator |> : LeftFunctionalApply

@discardableResult
public func |> <A, B> (
    x: A, 
    f: (A) throws -> B
) rethrows -> B 
{
    return try f(x)
}

// Code 4.5.3
import XCTest
@testable import Pipes

func double(a: Int) -> Int { return 2 * a }

class PipesTests: XCTestCase {
    func testDouble() { XCTAssertEqual(6 |> double, 12) }
}

// Code 4.5.4
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

/**
 4.6 Producing More Complex Projects
 */

// Code 4.6.1
import PackageDescription
let package = Package(
    name: "MyWebApp",
    targets: [
        Target(name: "A", dependencies: [.Target(name: "B")]),
        Target(name: "B", dependencies: [.Target(name: "C")]),
        Target(name: "C")]
)

// Code 4.6.2
let package = Package(
    name: "CSQLite",
    providers: [
        .Brew("sqlite"),
        .Apt("libsqlite3-dev")
    ]
)
