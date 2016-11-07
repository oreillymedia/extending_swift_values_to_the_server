import Foundation

//: Awful hack to get routines that print (asynchronously) to work in iPad playgrounds
//: There is a better way, but I haven't implemented it yet.

public var whatWasPrinted = ""
fileprivate let printed = DispatchSemaphore(value: 0)


public func printForPlayground(_ thingsToPrint: Any..., separator: String = " ", terminator: String = "") {
    whatWasPrinted =
        (
            thingsToPrint
                .map {"\($0)"}
                .joined(separator: separator)
            )
            + terminator
    printed.signal()
}

public func asyncForPlayground( _ fn: @escaping () throws -> Void ) -> String {
    let q = DispatchQueue(label: "asyncForPlayground", qos: .userInteractive)
    q.async {
        do { try fn() }
        catch { printForPlayground( "error: ", error) }
    }
    printed.wait()
    return whatWasPrinted
}
