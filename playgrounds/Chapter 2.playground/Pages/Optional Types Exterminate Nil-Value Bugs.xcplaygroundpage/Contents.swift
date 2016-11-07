import Foundation
//: # Optional Types
//: ## Optional Types and Dictionaries
let headerFields: [String: String] = ["Content-Type": "text"]
let contentType1 = headerFields["Content-Type"]
let aString: String = "foo"
let anOptionalString: String? = "bar"
type(of: contentType1) == type(of: aString)
type(of: contentType1) == type(of: anOptionalString)

//: Next line is illegal, uncomment it to see the error:
// Value of optional type 'String?' not unwrapped; did you mean to use '!' or '?'?
// if contentType1.hasPrefix("text") {} // ILLEGAL
//: ## if-let
let contentType2: String
if let ct = headerFields["Content-Type"] {
    contentType2 = ct
}
else {
    contentType2 = "no contentType"
}

contentType2
//: - - -
//: ## ?? for nil-coalescing
headerFields["Content-Type"] ?? "none"

let emptyHeaderFields: [String: String] = [:]
emptyHeaderFields["Content-Type"] ?? "none"

//: [Next](@next)
