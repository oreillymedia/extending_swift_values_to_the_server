//: [Previous](@previous)

import Foundation

func makeChannel() -> ( send: (String) -> Void, receive: () -> String)
{
    var message: String = ""
    return (
        send:    { (s: String) -> Void   in  message = s    },
        receive: { (_: Void  ) -> String in  return message }
    )
}

let aChannel = makeChannel()

aChannel.send("Hello")
aChannel.receive()

aChannel.send("Goodbye")
aChannel.receive()


//: [Next](@next)
