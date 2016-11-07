import Foundation

//: Awful hack to get routines that print (asynchronously) to work in iPad playgrounds
//: There is a better way, but I haven't implemented it yet.

//: Factor out the printing
public var whatWasPrinted = ""
public func printForPlayground(_ elements: Any..., separator: String = " ", terminator: String = "\n") {
    whatWasPrinted = (
        elements
            .map {"\($0)"}
            .joined(separator: separator)
        )
        + terminator
}


var doSomethingToPreventOptimization = 0

public func asyncForPlayground( _ fn: @escaping () throws -> Void ) -> String {
    let q = DispatchQueue(label: "executeSoThatShowWorksAsynchronously", qos: .userInteractive)
    let done = DispatchSemaphore(value: 0)
    q.async {
        do { try fn() }
        catch { printForPlayground( "error: ", error) }
        done.signal()
    }
    done.wait()
    return whatWasPrinted
}

