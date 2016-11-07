//: [Previous](@previous)
//: # Closures
//: ## A closure (being a reference type) can implement shared mutable state
import Foundation

func makeChannel() -> ( send: (String) -> Void, receive: () -> String)
{
    var message: String = ""
    return (
        send:    { (s: String) -> Void   in  message = s    },
        receive: { (_: Void  ) -> String in  return message }
    )
}
//: - - -
let aChannel = makeChannel()

aChannel.send("Hello")
aChannel.receive()

aChannel.send("Goodbye")
aChannel.receive()
aChannel.receive()
//: [Next](@next)
