//: [Previous](@previous)
//: # Custom Operators
//: - - -
//: ## Infrastructure for the examples
import Foundation

func sqrt(_ x: Double) -> Double {
    return x.squareRoot()
}

struct Image {
    let name: String
}

func getImage() -> Image {
    return Image(name: "image as of \(Date())" )
}

struct CompressedImage {
    let original: Image
}

func compress(_ image: Image) -> CompressedImage {
    return CompressedImage(original: image)
}

func send(_ compressedImage: CompressedImage) -> String {
    return "sent compressed image named \(compressedImage.original.name)"
}
//: - - -
//: ## Define the operator
precedencegroup LeftFunctionalApply { associativity: left
    higherThan: AssignmentPrecedence lowerThan: TernaryPrecedence
}
infix operator |> : LeftFunctionalApply

func |> <In, Out> ( lhs: In, rhs: (In) throws -> Out ) rethrows -> Out {
    return try rhs(lhs)
}
//: - - -
//: ## Try it out
9.0 |> sqrt

getImage() |> compress |> send
//: [Next](@next)
