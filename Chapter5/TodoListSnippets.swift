/**
 5. Writing a To-Do List with Kitura
 */

/**
 5.1 Server and Routers
 */

// Code 5.1.1
let router = Router()

// Code 5.1.2
Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()

// Code 5.1.3
router.get("/hello") {
    request, response, callNextHandler in
    response.status(.OK).send("Hello, World!")
    callNextHandler()
}

/**
 $ curl 127.0.0.1:8090/hello
 */

/**
 5.2 Creating a Web Service
 */

// Code 5.2.1
var itemStrings = [String]()

// Code 5.2.2
import SwiftyJSON
func handleGetStringItems(
    request:         RouterRequest,
    response:        RouterResponse,
    callNextHandler: @escaping () -> Void
) throws {
    response.send( json: JSON(itemStrings) )
    callNextHandler()
}

// Code 5.2.3
router.all("/*", middleware: BodyParser())

// Code 5.2.4
let itemStringsLock = DispatchSemaphore(value: 1)

// Code 5.2.5
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

// Code 5.2.6
router.get ("/v1/string/item", handler: handleGetStringItems)
router.post("/v1/string/item", handler: handleAddStringItem)

/**
 Code 5.2.7
 
 Test your code with:
 
 $ curl -H "Content-Type: application/json" \
        -X POST \
        -d '{"item":"Reticulate Splines"}' \
        localhost:8090/v1/string/item
 Added 'Reticulate Splines'
 
 $ curl localhost:8090/v1/string/item
 ["Reticulate Splines"]
 */


/**
 5.3 Deploying your Application to Bluemix
 */

/**
 Code 5.3.1
 
 applications:
 - name: todolist
 memory: 256M
 instances: 2
 random-route: true
 buildpack: https://github.com/IBM-Swift/swift-buildpack.git
 
 */

/**
 Code 5.3.2
 web: Server
 */

// Code 5.3.3
import CloudFoundryEnv
do {
    let appEnv = try CloudFoundryEnv.getAppEnv()
    let port   = appEnv.port
    Kitura.addHTTPServer(onPort: port, with: router)
} catch CloudFoundryEnvError.InvalidValue {
    print("Oops, something went wrong... Server did not start!")
}

/**
 Code 5.3.4
 
 $ cf push
 */

/**
 Code 5.3.5
 
 $ curl https://<application name>.bluemix.net/v1/string/item
 
 */


/**
 5.4 More Elaborate To-Do Items
 */

// Code 5.4.1
var itemDictionaries = [[String: Any]]()
let itemDictionariesLock = DispatchSemaphore(value: 1)

// Code 5.4.2
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
    itemDictionaries.append( [ "id": UUID().uuidString,
                               "title": title ] )
    itemDictionariesLock.signal()

    response.send("Added '\(title)'\n")
    callNextHandler()
}

// Code 5.4.3
router.get ("/v1/dictionary/item",
            handler: handleGetItemDictionaries)
router.post("/v1/dictionary/item",
            handler: handleAddItemDictionary)

/**
 Code 5.4.4
 
 $ curl -H "Content-Type: application/json" \
        -X POST \
        -d '{"title: "Reticulate Splines"}'
 Added 'Reticulate Splines'
 
 $ curl localhost:8090/v1/dictionary/item
 [
    {
        "id" : "2A6BF4C7-2773-4FC9-884C-957F205F940A",
        "title" : "Reticulate Splines"
    }
 ]
 */

// Code 5.4.5
struct Item {
    let id:    UUID
    let title: String
}
var itemStructs = [Item]()
let itemStructsLock = DispatchSemaphore(value: 1)

// Code 5.4.6
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


// Code 5.4.7
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

// Code 5.4.8
router.get ("/v1/struct/item", handler: handleGetItemStructs)
router.post("/v1/struct/item", handler: handleAddItemStruct)

/**
 Code 5.4.9
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
 5.5 Adding Authentication
 */

// Code 5.5.1
let credentials = Credentials()
let facebookCredentialsPlugin = CredentialsFacebookToken()
credentials.register(facebookCredentialsPlugin)
router.all("/v1/*/item", middleware: credentials)

/**
 5.6 Setting up the Database
 */
    
/**
 Code 5.6.1
 
 {
     "_id": "_design/tododesign",
     "_views" : {
        "all_todos" : {
            "map" :
            "function(doc) { emit(doc._id, [doc._id, doc.title]); }"
        }
     }
 }
 */
    
/**
 Code 5.6.2
 
 $ curl -X PUT http://127.9.0.1:5984/todolist
 */
    
/**
 Code 5.6.3
 
 $ curl -X PUT http://127.0.0.1:5984/todolist/_design/tododesign \
        --data-dinary @todolist_design.json
 */
    
/**
 Code 5.6.4
 
 $ curl http://127.0.0.1:5984/todolist/_design/tododesign \
    /_views/all_todos
 */
    
/**
 Code 5.6.5
 
 $ curl http://127.0.0.1:5984/todolist/<UUID goes here> \
    -d '{ "title": "Reticulate Splines" }'
 */
    
/**
 5.7 Connecting to the Database
 */

// Code 5.7.1
.Package(url: "https://github.com/davidungar/miniPromiseKit",
         majorVersion: 4, minor: 1)

// Code 5.7.2
extension URLSession {
    func dataTaskPromise(with url: URL) -> Promise<Data> {
        return Promise { fulfill, reject in
            let dataTask =
                URLSession(configuration: .default).dataTask(
                with: url) {
                    data, response, error in
                    if let d = data { fulfill(d) }
                    else            { reject(error!) }
            }
            dataTask.resume()
        }
    }
}

// Code 5.7.3
let queue = DispatchQueue(label: "com.todolist.controller",
                          qos: .userInitiated,
                          attributes: .concurrent)

// Code 5.7.4
func getAllItems() -> Promise<[Item]> {
    return firstly {
        URLSession().dataTaskPromise(with: url)
    }
    .then(on: queue) { dataResult in
        return try dataToItems(data: dataResult)
    }
}

// Code 5.7.5
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

// Code 5.7.6
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

// Code 5.7.7
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

// Code 5.7.8
router.get ( "/v1/couch/item", handler: handleGetCouchDBItems )
router.post( "/v1/couch/item", handler: handleAddCouchDBItem )

/**
 Code 5.7.9
 
 $ curl -H "Content-Type: application/json" \
        -X POST \
        -d '{"title":"Finish book!"}' localhost:8090/v1/couch/item
 Added 'Item(id: 054879B8-B798-4462-AF0B-79B20F9617F4,
        title: "Finish book!")'
 
 $ curl localhost:8090/v1/couch/item
 [
    {
        "id" : "054879B8-B798-4462-AF0B-79B20F9617F4",
        "title" : Finish book!
    }
 ]
 */
