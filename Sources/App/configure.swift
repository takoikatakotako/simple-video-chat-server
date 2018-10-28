import Vapor
import Leaf
import MySQL
import FluentMySQL

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(LeafProvider())
    try services.register(MySQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    /// Use Leaf for rendering views
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    // Configure a MySQL database
    let mysql = MySQLDatabase(config: MySQLDatabaseConfig(
        hostname: HOST_NAME,
        port: PORT_NUMBER,
        username: USER_NAME,
        password: USER_PASSWORD,
        database: DATABASE))
    
    /// Register the configured MySQL database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: mysql, as: .mysql)
    services.register(databases)
    
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Room.self, database: .mysql)
    services.register(migrations)
    
    // WebSockets
    // Create a new NIO websocket server
    // wsta ws://localhost:3001
    
    let wss = NIOWebSocketServer.default()
    // Add WebSocket upgrade support to GET /echo
    wss.get("echo") { ws, req in
        // Add a new on text callback
        ws.onText { ws, text in
            // Simply echo any received text
            ws.send(text)
        }
    }
    
    wss.get("chat", String.parameter) { ws, req in
        let name = try req.parameters.next(String.self)
        ws.send("Welcome, \(name)!")
        
        // ...
    }
    
    wss.get("socket") { ws, req in
        print("----------")
        print(ws)
        print(type(of: ws))
        print("----------")
        ws.onText { ws_text, text in
            // Simply echo any received text
            print("@@@@@")
            print(ws_text)
            print(text)
            
            Room.query(on: req).all().map { data -> Void in
                print("All Datas")
                print(data)
                for room: Room in data {
                    print(room)
                }
            }
            let personalData: Data =  text.data(using: String.Encoding.utf8)!
            do {
                // パースする
                let items = try JSONSerialization.jsonObject(with: personalData) as! Dictionary<String, Any>
                print(items["type"] as! String) // メンバname Stringにキャスト
                // print(items["sdp"] as! String)
            } catch {
                print(error)
            }
            print("@@@@@")
        }
    }
     services.register(wss, as: WebSocketServer.self)
    
}
