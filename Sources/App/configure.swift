import Vapor
import Leaf

var websocketClients: Dictionary<String, [WebSocket]> = [:]

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(LeafProvider())

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

    // WebSockets
    let wss = NIOWebSocketServer.default()
    
    wss.get("socket", String.parameter) { ws, req in
        
        print("@@@@@@@");
        let str = try req.parameters.next(String.self)
        print(str)
        print("@@@@@@@");

        // closeしたのは消したい
        if websocketClients[str] == nil {
            websocketClients[str] = []
        }
        websocketClients[str]!.append(ws)
        ws.onText { ws, text in
            for client in websocketClients[str]! {
                if !client.isClosed {
                    if ws === client {
                        print("slip sender")
                    } else {
                        // かつ、roomが一緒
                        client.send(text)
                    }
                }
            }
        }
    }
    services.register(wss, as: WebSocketServer.self)
}
