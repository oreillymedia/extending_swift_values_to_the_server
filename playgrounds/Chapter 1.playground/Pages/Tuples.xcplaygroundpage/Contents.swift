//: [Previous](@previous)
//: # Tuples
//: In order to prevent name collisions in this playground, various identifiers are suffixed with a digit
//: - - -
//: ## A tuple accessed by indices
func lookup1(user: String) -> (String, Int) {
    // compute n and sn
    let n: String
    switch user {
    case "Washington": n = "George Washington"
    case "Adams":      n = "John Adams"
    default:           n = "Anonymous"
    }
    let sn = user.characters.count
    return (n, sn)
}

let userInfo1 = lookup1(user: "Washington")
print( "name:", userInfo1.0, "serialNumber:", userInfo1.1)

let (name, serialNumber) = lookup1(user: "Adams")
print( "name:", name, "serialNumber:", serialNumber)
//: - - -
//: ## A tuple accessed by field names
func lookup2(user: String) -> (name: String, serialNumber: Int)
{
    let n: String
    switch user {
    case "Washington": n = "George Washington"
    case "Adams":      n = "John Adams"
    default:           n = "Anonymous"
    }
    let sn = user.characters.count
    return (n, sn)
}

let userInfo2 = lookup2(user: "Washington")
print("name:", userInfo2.name, "serialNumber:", userInfo2.serialNumber)
//: - - -
//: ## Changing a field in a tuple `var`
let second = lookup2(user: "Adams")
// Uncomment the next line to see the error:
// second.name = "Gomez Adams" // ILLEGAL: Cannot assign to property: 'second' is a 'let' constant
var anotherSecond = lookup2(user: "Adams")
anotherSecond.name = "Gomez Adams"
print(anotherSecond.name)
//: - - -
//: ## Tuple assignment copies the tuple
var first = lookup2(user: "Washington")
var anotherFirst = first
first.name
anotherFirst.name
first.name = "George Jefferson"
anotherFirst.name
//: - - -
//: ## Tuples and dictionaries:
enum  PegShape { case roundPeg,  squarePeg }
enum HoleShape { case roundHole, squareHole, triangularHole }

func howDoes(_ peg: PegShape, fitInto hole: HoleShape) -> String
{
    switch (peg, hole) { // switches on a tuple
    case ( .roundPeg,  .roundHole):  return "fits any orientation"
    case (.squarePeg, .squareHole):  return "fits four ways"
    default:                         return "does not fit"
    }
}
howDoes(.roundPeg, fitInto: .roundHole)
//: [Next](@next)
