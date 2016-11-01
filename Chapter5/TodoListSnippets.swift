/**
 Basic example using only Strings
 */

// Code 5-1
import SwiftyJSON
func handleGetStringItems(
    request:         RouterRequest,
    response:        RouterResponse,
    callNextHandler: @escaping () -> Void
) throws {
    response.send( json: JSON(itemStrings) )
    callNextHandler()
}

// Code 5-2
func handleAddStringItem(
    request:         RouterRequest,
    response:        RouterResponse,
    callNextHandler: @escaping () -> Void
) {
    // If there is a body that holds JSON, get it.
    guard case let .json(jsonBody)? = request.body
    else {
        response.status(.badRequest)
        callNextHandler()
        return
    }
    let item = jsonBody["item"].stringValue
    
    itemStringsLock.wait()
    itemStrings.append(item)
    itemStringsLock.signal()
    
    response.send("Added '\(item)'\n")
    callNextHandler()
}

// Code 5-3
router.get ("/v1/string/item", handler: handleGetStringItems)
router.post("/v1/string/item", handler: handleAddStringItem)

/**
 Test your code with:
 
 $ curl -H "Content-Type: application/json" \
        -X POST \
        -d '{"item":"Reticulate Splines"}' \
        localhost:8090/v1/string/item
 
 $ curl localhost:8090/v1/string/item
 */


/**
 Deploying your Application to Bluemix
 */

import CloudFoundryEnv
do {
    let appEnv = try CloudFoundryEnv.getAppEnv()
    let port: Int = appEnv.port
    Kitura.addHTTPServer(onPort: port, with: router)
} catch CloudFoundryEnvError.InvalidValue {
    print("Oops, something went wrong... Server did not start!")
}

/**
 Basic example using only Dictionary
 */

// Code 
var itemDictionaries = [[String: Any]]()
let itemDictionariesLock = DispatchSemaphore(value: 1)

// Code 5-3
func handleGetItemDictionaries(
    request:         RouterRequest,
    response:        RouterResponse,
    callNextHandler: @escaping () -> Void
) throws {
    response.send(json: JSON(itemDictionaries))
    callNextHandler()
}
func handleAddItemDictionary(
    request:         RouterRequest,
    response:        RouterResponse,
    callNextHandler: @escaping () -> Void
) {
    guard
        case let .json(jsonBody)? = request.body,
        let title = jsonBody["title"].string
    else {
        response.status(.badRequest)
        callNextHandler()
        return
    }

    itemDictionariesLock.wait()
    itemDictionaries.append( [  "id": UUID().uuidString,
                                "title": title ] )
    itemDictionariesLock.signal()

    response.send("Added '\(title)'\n")
    callNextHandler()
}

// Code 5-4
router.get ("/v1/dictionary/item",
            handler: handleGetItemDictionaries)
router.post("/v1/dictionary/item",
            handler: handleAddItemDictionary)

/**
 Move to a Structure
 */

// Code 5-5
struct Item {
    let id:    UUID
    let title: String
}
var itemStructs = [Item]()
let itemStructsLock = DispatchSemaphore(value: 1)

// Code 5-6
enum ItemError: String, Error { case malformedJSON }
extension Item {
    init ( json: JSON ) throws {
        guard
            let d = json.dictionary,
            let title = d["title"]?.string
        else {
            throw ItemError.malformedJSON
        }
        id = UUID()
        title = title
    }
    var dictionary: [String: Any] {
        return ["id":    id.uuidString as Any,
                "title": title as Any]
    }
}


// Code 5-7
func handleGetItemStructs(
    request:         RouterRequest,
    response:        RouterResponse,
    callNextHandler: @escaping () -> Void
) throws {
    response.send( json: JSON(itemStructs.dictionary) )
    callNextHandler()
}
func handleAddItemStruct(
    request:         RouterRequest,
    response:        RouterResponse,
    callNextHandler: @escaping () -> Void
) {
    guard case let .json(jsonBody)? = request.body
    else {
        response.status(.badRequest)
        callNextHandler()
        return
    }
    do {
        let item = try Item(json: jsonBody)
        
        itemStructsLock.wait()
        itemStructs.append(item)
        itemStructsLock.signal()
        
        response.send("Added '\(item)'\n")
        callNextHandler()
    }
    catch {
        response.status(.badRequest)
        let err = error.localizedDescription
        response.send(err)
        callNextHandler()
    }
}

// Code 5-8
router.get ("/v1/struct/item", handler: handleGetItemStructs)
router.post("/v1/struct/item", handler: handleAddItemStruct)

/**
 $ curl -H "Content-Type: application/json" \
        -X POST \
        -d '{"title":"Finish book!"}' localhost:8090/v1/struct/item
 Added 'Item(id: 054879B8-B798-4462-AF0B-79B20F9617F4,
 title: "Herd llamas")'
 
 $ curl localhost:8090/v1/item_struct
 [
    {
        "id" : "054879B8-B798-4462-AF0B-79B20F9617F4",
        "title" : Finish book!
    }
 ]
 */


/** 
 Adding Authentication
 */

// Code 5-9
let credentials = Credentials()
let facebookCredentialsPlugin = CredentialsFacebookToken()
credentials.register(facebookCredentialsPlugin)
router.all("/v1/*/item", middleware: credentials)

/**
 Connecting to the Database
 */

// Code 
.Package(url: "https://github.com/davidungar/miniPromiseKit",
         majorVersion: 4, minor: 1)

// Code 5-10
extension URLSession {
    func dataTaskPromise(with url: URL) -> Promise<Data> {
        return Promise { fulfill, reject in
            let dataTask =
                URLSession(configuration: .default).dataTask(
                with: url) {
                    data, response, error in
                    if let d = data { fulfill(d) }
                    else { reject(error!) }
            }
            dataTask.resume()
        }
    }
}

// Code 5-11
let queue = DispatchQueue(label: "com.todolist.controller",
                          qos: .userInitiated,
                          attributes: .concurrent)

// Code 5-12
func getAllItems() -> Promise<[Item]> {
    return firstly {
        URLSession().dataTaskPromise(with: url)
    }
    .then(on: queue) { dataResult in
        return try dataToItems(data: dataResult)
    }
}

// Code 5-13
func addItem(item: Item) -> Promise<Item> {
    return Promise { fulfill, reject in
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = try JSONSerialization.data(
            withJSONObject: item.dictionary,
            options: [])
        let dataTask = session.dataTask(with: request) {
            data, response, error in
            if let error = error { reject(error) }
            fulfill(item)
        }
        dataTask.resume()
    }
}

// Code 5-14
func handleGetCouchDBItems(
    request:         RouterRequest,
    response:        RouterResponse,
    callNextHandler: @escaping () -> Void
) throws {
    firstly {
        getAllItems()
    }
    .then(on: queue) {
        response.send(json: JSON(items.dictionary))
    }
    .catch(on: queue) {
        response.status(.badRequest)
        response.send(error.localizedDescription)
    }
    .always(on: queue) {
        callNextHandler()
    }
}

// Code 5-15
func handleAddCouchDBItem(
    request:         RouterRequest,
    response:        RouterResponse,
    callNextHandler: @escaping () -> Void
) {
    firstly { () -> Promise<Item> in
        guard case let .json(jsonBody)? = request.body
        else {
            throw ItemError.malformedJSON
        }
        let item = try Item(json: jsonBody)
        return addItem(item: item)
    }
    .then(on: queue) { item in
        response.send("Added \(item.title)")
    }
    .catch(on: queue) { error in
        response.status(.badRequest)
        response.send(error.localizedDescription)
    }
    .always(on: queue) {
        callNextHandler()
    }
}

// Code 5-16
router.get ( "/v1/couch/item", handler: handleGetCouchDBItems )
router.post( "/v1/couch/item", handler: handleAddCouchDBItem )

/**
 $ curl -H "Content-Type: application/json" \
        -X POST \
        -d '{"title":"Finish book!"}' localhost:8090/v1/struct/item
 Added 'Item(id: 054879B8-B798-4462-AF0B-79B20F9617F4,
        title: "Herd llamas")'
 
 $ curl localhost:8090/v1/item_struct
 [
    {
        "id" : "054879B8-B798-4462-AF0B-79B20F9617F4",
        "title" : Finish book!
    }
 ]
 */
