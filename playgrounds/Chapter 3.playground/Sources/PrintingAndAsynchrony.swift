import Foundation

//: Awful hack to get routines that print (asynchronously) to work in iPad playgrounds
//: There is a better way, but I haven't implemented it yet.

fileprivate var contentsOfShow = ""
fileprivate let shown = DispatchSemaphore(value: 0)


public func show(_ thingsToPrint: Any..., separator: String = " ", terminator: String = "") {
    contentsOfShow =
        (
            thingsToPrint
                .map {"\($0)"}
                .joined(separator: separator)
            )
            + terminator
    shown.signal()
}

var doSomethingToPreventOptimization = 0

public func executeSoThatShowWorksAsynchronously( _ fn: @escaping () throws -> Void ) -> String {
    let q = DispatchQueue(label: "executeSoThatShowWorksAsynchronously", qos: .userInteractive)
    q.async {
        do { try fn() }
        catch { show( "error: ", error) }
    }
    shown.wait()
    return contentsOfShow
}
