import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Top
    router.get { req in
        return try req.view().render("welcome")
    }
 
    // romm
    router.get("/", String.parameter) { req -> Future<View> in
        let str = try req.parameters.next(String.self)
        print(str)
        if str.count < 4 {
            return try req.view().render("welcome")
        }
        return try req.view().render("index")
    }
}
