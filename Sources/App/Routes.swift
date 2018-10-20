import Vapor


struct User2: Content {
    var name: String
    var email: String
}

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // "It works" page
    router.get { req in
        return try req.view().render("index")
    }
    
    // Says hello
    router.get("hello", String.parameter) { req -> Future<View> in
        return try req.view().render("hello", [
            "name": req.parameters.next(String.self)
        ])
    }
    
    router.get("user") { req -> User2 in
        return User2(
            name: "Vapor User",
            email: "user@vapor.codes"
        )
    }
    
    struct MySQLVersion: Codable {
        let version: String
    }
    
    router.get("sql") { req in
        return req.withPooledConnection(to: .mysql) { conn in
            return conn.raw("SELECT @@version as version")
                .all(decoding: MySQLVersion.self)
            }.map { rows in
                return rows[0].version
        }
    }
    
    router.get("test") { req in
        return User2(
            name: "Vapor User",
            email: "user@vapor.codes"
        )
    }
    
    
    router.get("conoha") { req in
        return Room.query(on: req).range(..<50).all()
    }
    
    let helloController = HelloController()
    router.get("greet", use: helloController.greet)
    
    // MARK: - room
    let roomController: RoomController = RoomController()
    router.post("api/v0/make", use: roomController.make)
}
