import Vapor

func routes(_ app: Application) throws {
    app.get { req -> EventLoopFuture<View> in
        return req.view.render("welcome")
    }

    app.get("/", ":room") { req -> EventLoopFuture<View> in
        guard let room = req.parameters.get("room") else {
            return req.view.render("welcome")
        }
        if room.count < 4 {
            return req.view.render("welcome")
        }
        return req.view.render("index")
    }
    
    var websocketClients: [String: [WebSocket]] = [:]
    app.webSocket("socket", ":room") { req, ws in
        // Connected WebSocket.
        let room = req.parameters.get("room")!
        // roomがなければ初期化、既にある場合はcloseを削除
        if websocketClients[room] == nil {
            websocketClients[room] = []
        } else {
            websocketClients[room] = websocketClients[room]!.filter({
                !$0.isClosed
            })
        }
        
        websocketClients[room]!.append(ws)
        ws.onText { ws, text in
            for client in websocketClients[room]! {
                if client.isClosed {
                    return
                }
                if ws === client {
                    print("slip sender")
                } else {
                    // roomが一緒
                    client.send(text)
                }
            }
        }
    }
}
